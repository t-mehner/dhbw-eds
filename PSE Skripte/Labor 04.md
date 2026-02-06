# Labor 04: Nicht-rechteckige Formen mit Sprites

## Ziel

In diesem Labor ersetzt ihr einfache Rechtecke durch Sprite-basierte Darstellung.

1. Runder Ball als Sprite statt Rechteck
2. Textdarstellung aus ASCII-Sprites in Block-RAM (ROM)
3. Aufräumen der Architektur durch Auslagerung in eine Text-Komponente
4. Texte variabler Länge über Typdefinition in einem Package
5. Mehrere Texte je nach Spielzustand, inklusive RAM-Zugriffskontrolle
6. Ausblick auf eigenständige Erweiterungen in der nächsten Vorlesung

Ihr arbeitet auf Basis von `03_pong_game`.

---

## Teil 1: Runder Ball

### 1.1 Was ist ein Sprite

Ein Sprite ist eine kleine Bitmap (z. B. 8×8 oder 8×16). Für jeden Pixel wird entschieden, ob er "Teil des Objekts" ist oder Hintergrund bleibt.

Prinzip beim Rendern (pro Pixel):

1. Liegt der aktuelle Pixel (`PIX_X`, `PIX_Y`) im Bounding-Box-Rechteck des Sprites
2. Falls ja: berechne lokale Koordinaten im Sprite (`sx`, `sy`)
3. Hole das Sprite-Bit an Position (`sx`, `sy`)
4. Wenn Bit = 1: Objektpixel, sonst transparent

Damit bekommt ihr automatisch nicht-rechteckige Formen, weil das Sprite-Bitmap beliebige Muster haben kann.

### 1.2 Sprite-Idee auf den Ball übertragen

Beim Rechteck-Ball war `BALL_ON` einfach "Pixel liegt zwischen `BALL_X_L_REG`/`BALL_X_R_REG` und `BALL_Y_O_REG`/`BALL_Y_U_REG`".

Beim runden Ball bleibt die Bounding-Box gleich, aber innerhalb der Box wird über ein Sprite-Muster entschieden, ob der Pixel sichtbar ist.

Ihr könnt dafür ein 8×8-Sprite benutzen, das grob einen Kreis darstellt.

Beispiel: 8×8-Kreis-Maske (1 = sichtbar, 0 = transparent)

```vhdl
type sprite_type  is array (0 to 7) of std_logic_vector(7 downto 0);
constant ball_sprite : sprite_type := (
   "00111100",
   "01111110",
   "11111111",
   "11111111",
   "11111111",
   "11111111",
   "01111110",
   "00111100" );
```

### 1.3 Umsetzung: `BALL_ON` mit Sprite-Bit statt Rechteck

Nehmt euren bisherigen Ball-Bounding-Box-Test (das ist weiter sinnvoll), und ergänzt das Sprite-Bit.

Idee:

1. Wenn Pixel nicht in der Box: `BALL_ON <= '0'`
2. Wenn in der Box:
   2.1 `sx = PIX_X - BALL_X_L_REG`
   2.2 `sy = PIX_Y - BALL_Y_O_REG`
   2.3 Sprite-Bit aus `BALL_SPRITE` auswählen
   2.4 `BALL_ON <= sprite_bit`

Beispielcode (Prinzip, nicht 1:1 Copy-Paste)

```vhdl
ball_on_proc: process(PIX_X, PIX_Y, BALL_X_L_REG, BALL_X_R_REG, BALL_Y_O_REG, BALL_Y_U_REG)
begin
    if (PIX_X >= BALL_X_L_REG) and (PIX_X < BALL_X_R_REG) and
       (PIX_Y >= BALL_Y_O_REG) and (PIX_Y < BALL_Y_U_REG) then
        BALL_ON <= ball_sprite
            (to_integer(PIX_X(3 downto 0)-BALL_X_L_REG(3 downto 0)))
            (to_integer(PIX_Y(3 downto 0)-BALL_Y_O_REG(3 downto 0)));
    else
        BALL_ON <= '0';
    end if;    
end process ball_on_proc;
```

Hinweis: Kollisionen bleiben erstmal auf Bounding-Box-Basis wie vorher. Das ist "good enough" und spart euch teure Kreis-Geometrie.

---

## Teil 2: Textdarstellung mit ASCII-Sprites aus BRAM (ROM)

### 2.1 Konzept: Vom Ball-Sprite zum Text-Sprite

Der Ball war "ein einziges Sprite". Text ist "viele Sprites hintereinander":

1. Jeder Buchstabe ist ein Sprite (Glyph), z. B. 8×16
2. Ein Text ist eine Reihe von Glyphen
3. Der aktuelle Pixel entscheidet:
   3.1 welcher Buchstabe gerade aktiv ist (`char_idx`)
   3.2 welche Zeile im Glyph (`row_in_char`)
   3.3 welches Bit innerhalb der Zeile (`col_in_char`)
   
Zusätzlich führen wir jetzt eine Skalierung (Streckung) ein:

4. Pong wird mit Faktor 4 gestreckt dargestellt (Skalierung um 2 Bits).
   4.1 Das bedeutet: Ein Sprite-Pixel wird als 4×4 "Block" auf dem Bildschirm dargestellt.
   4.2 Die lokalen Sprite-Koordinaten werden daher aus den Bildschirmkoordinaten gebildet, indem man durch 4 teilt.

Merke:
- Bildschirmkoordinate → Spritekoordinate: `sprite_x = screen_x >> 2`, `sprite_y = screen_y >> 2`
- Spritekoordinate → Bildschirmgröße: `screen_width = sprite_width << 2`, `screen_height = sprite_height << 2`


### 2.2 Woher kommen die Buchstaben-Sprites

Ihr nutzt ein ASCII-Font-ROM. Im Projekt findet ihr bereits `ascii.coe` (aus `vhdl_to_coe`). Dieses ist folgendermaßen aufgebaut:

1. 128 Zeichen (ASCII)
2. pro Zeichen 16 Zeilen
3. jede Zeile 8 Bit breit

Speicherlayout:

1. Adresse = `ASCII_CODE & ROW`
2. `ASCII_CODE` ist 7 Bit
3. `ROW` ist 4 Bit (0..15)
4. Gesamtadresse 11 Bit, Datenbreite 8 Bit

Genau dafür ist die COE-Datei ideal: ein Block Memory Generator IP kann daraus eine initialisierte ROM machen.

### 2.3 BRAM-IP als ROM instantiieren

In Vivado:

1. IP Catalog öffnen
2. `Block Memory Generator` hinzufügen
3. Konfiguration
   3.1 Memory Type: `Single Port ROM` (oder Simple Dual Port, siehe Zugriffskontrolle später)
   3.2 Read Width: 8
   3.3 Depth: 2048
   3.4 Load Init File: `ascii.coe`
4. IP generieren
5. IP in pong.vhd instantiieren

Ports (typisch):

1. `clka`
2. `addra`
3. `douta`
4. optional `ena`, für uns reicht always enabled

Im Pong-Kontext könnt ihr eure Signale z. B. `ROM_ADDR`, `ROM_INPUT`, `ROM_ACCESS` nennen.

### 2.4 Welche Clock für das ROM

Wichtig: Xilinx BRAM ist standardmässig synchron gelesen. Das bedeutet:

1. Ihr legt `addra` an
2. erst mit der nächsten aktiven Clock-Flanke erscheint `douta` stabil

Daraus folgt:

1. Wenn ihr pro Pixel ein Font-Bit braucht, ist die schnellste `CLK` (100MHz) die natürliche Wahl
2. Dann ist eure Daten-Latenz schneller als der Pixel-Takt, wodurch ihr keine Delays beachten müsst

Diskussion der Optionen:

1. 60 Hz Frame-Takt
   1.1 zu langsam, ihr bekämt nur 60 Updates pro Sekunde für Daten, nicht pro Pixel
   1.2 ungeeignet für per-pixel Text
2. 25 MHz Pixel-Takt
   2.1 erfordert 1-Pixel-Pipeline wegen BRAM-Latenz
3. 100 MHz System-Takt
   3.1 ideal, da hier keine Acht auf Verzögerungen genommen werden muss.

### 2.5 Umsetzung: Titeltext "Pong"

Ihr rendert "Pong" nur in den Zuständen `TITLE_1` und `TITLE_2`.

Vorgehen:

1. Implementiert ähnlich zum Ball einen Prozess für den Text Pong, der `TEXT_ON` liefert
2. Dafür benötigt ihr:
   2.1 Position (`X_L`, `X_R`, `Y_O`, `Y_U`)
   2.2 `TEXT` als Array von ASCII-Codes
   2.3 ROM-Schnittstelle: `ROM_ADDR`, `ROM_INPUT`, `ROM_ACCESS`
3. Wenn `STATE_REG` ist `TITLE_1` oder `TITLE_2`, dann aktivieren und in den Farb-Mux integrieren

Beispiel für "Pong" als ASCII-Codes:

1. 'P' = 80 = `x"50"`
2. 'o' = 111 = `x"6F"`
3. 'n' = 110 = `x"6E"`
4. 'g' = 103 = `x"67"`

---

## Teil 3: Optimierung durch Auslagerung und Package für variable Textlängen

### 3.1 Problem: der Code wird schnell unübersichtlich

Wenn ihr Text direkt in `PONG1` rendert, passieren mehrere Dinge gleichzeitig:

1. Pixel-Logik (Koordinaten, Bounding-Box)
2. ROM-Adressberechnung
3. Pipeline für BRAM-Latenz
4. Mehrere Texte an verschiedenen Stellen

Das wird schwer wartbar. Lösung: Text-Rendering in eine Komponente auslagern.

### 3.2 `TEXT_DISPLAY` als Komponente

Ziel von `TEXT_DISPLAY`:

1. Eingänge: `PIX_X`, `PIX_Y`, `TEXT_IN`
2. ROM-Interface: `ROM_ADDR`, `ROM_INPUT`, `ROM_ACCESS`
3. Ausgang: `TEXT_ON`

Dann kann `PONG1` einfach mehrere Text-Komponenten instantiieren und nur noch entscheiden, welche gerade angezeigt wird.

### 3.3 Neue Technik: Text variabler Länge braucht einen Typ

In VHDL kann ein Port zwar einfach "beliebig langer String" sein, aber die Indizierung dessen wird schnell schwierig.

Stattdessen macht ihr:

1. Ein fest definierter Elementtyp pro Zeichen, z. B. `std_logic_vector(6 downto 0)` für ASCII
2. Ein Array daraus, z. B. `text_array_t(0 to LENGTH-1)`
3. Das Array wird als Porttyp benutzt

Damit `text_array_t` überall bekannt ist, gehört diese Typdefinition in ein Package.

Warum Package:

1. Typen müssen an mehreren Stellen identisch sein (Top-Level, `PONG1`, `TEXT_DISPLAY`)
2. Wenn ihr den Typ nur in einer Architektur definiert, ist er ausserhalb nicht sichtbar
3. Package ist die saubere, modulare "Header-Datei" in VHDL

### 3.4 Package erstellen: `text_types_pkg.vhd`

Legt eine neue Datei an, z. B. `text_types_pkg.vhd`:

```vhdl
library ieee;
use ieee.std_logic_1164.all;

package text_types_pkg is
    subtype ascii_t is std_logic_vector(7 downto 0);
    type text_array_t is array (natural range <>) of ascii_t;
end package;
```

Wichtig:

1. `natural range <>` macht den Array "unconstrained"
2. Unconstrained bedeutet: die Länge wird beim Verwenden festgelegt (durch Generics)
3. Das erlaubt `text_array_t(0 to 3)` für "Pong", oder `text_array_t(0 to 8)` für "Game Over"

Einbindung:

1. In jeder Datei, die den Typ nutzt:

```vhdl
library work;
use work.text_types_pkg.all;
```

---

## Teil 4: Umsetzung mehrerer Texte und RAM-Zugriffskontrolle

### 4.1 Mehrere Texte

Ihr wollt mindestens:

1. "Pong" im Titel (`TITLE_1`, `TITLE_2`)
2. "Game Over" im Game Over (`GAME_OVER_1`, `GAME_OVER_2`)
3. "Punkte:" dauerhaft in einer Ecke

Vorgehen:

1. Instanziert mehrere `TEXT_DISPLAY`
2. Gebt jeder Instanz eigene `X_L`, `Y_O`, `LENGTH`
3. Berechnet daraus `X_R` und `Y_U`
4. Jede Instanz bekommt ein eigenes `TEXT_IN` Signal

Beispielsignale in `PONG1`:

1. `TEXT_PONG : text_array_t(0 to 3)`
2. `TEXT_GAMEOVER : text_array_t(0 to 8)` (inkl. Leerzeichen)
3. `TEXT_POINTS : text_array_t(0 to 6)` für "Punkte:"

### 4.2 Zustandsabhängige Anzeige

In `PONG1` entscheidet ihr, welche Text-Ausgänge in den Farb-Mux eingehen.

Beispiel-Logik:

1. `TITLE_1` und `TITLE_2`: nur `TEXT_PONG_ON`
2. `GAME_OVER_1` und `GAME_OVER_2`: nur `TEXT_GAMEOVER_ON`
3. `LIVES_3`, `LIVES_2`, `LIVES_1`: `TEXT_POINTS_ON` (und später zusätzlich die Zahl)

### 4.3 Zugriffskontrolle auf das ASCII-ROM

Wenn mehrere `TEXT_DISPLAY` gleichzeitig existieren, wollen sie alle das gleiche ROM lesen. Das geht nicht mit einem Single-Port-ROM ohne Arbitration.

Drei saubere Optionen:

Option A: Nur ein Text aktiv pro Pixel (Priority-Mux)

1. Jede `TEXT_DISPLAY` liefert `ROM_ACCESS_?` und `ROM_ADDR_?`
2. Ihr muxed:
   2.1 Wenn `ROM_ACCESS_title = '1'` nutze dessen Adresse
   2.2 sonst wenn `ROM_ACCESS_points = '1'` nutze dessen Adresse
   2.3 sonst wenn `ROM_ACCESS_gameover = '1'` nutze dessen Adresse
   2.4 beachte, dass Title und Game Over an der gleichen Stelle zu unterschiedlichen Zeiten dargestellt werden. Das muss in den Access einbezogen werden.
3. `ROM_INPUT` geht an alle Instanzen, aber nur die mit aktivem `ROM_ACCESS_i` wertet sie aus

Das funktioniert, solange Texte nicht (gleichzeitig) überlappen und ihr eine klare Priorität habt. Falls ihr das möchtet: Dual-Port ROM

---

## Teil 5: Ausblick auf weitere Verbesserungen

### 5.1 Notwendige Erweiterung in der nächsten Vorlesung

1. Punktzahl als Zahl darstellen (nicht nur "Punkte:")
2. Leben als Zahl oder Symbole darstellen (zusätzlich zu LEDs oder statt LEDs)

Konzept dafür:

1. Zahl in ASCII umwandeln (z. B. Bin2BCD von 7-Segment-Anzeige)
2. ASCII-Ziffern wie normale Textzeichen über `TEXT_DISPLAY` ausgeben

### 5.2 Weitere sinnvolle Erweiterungen (Ideen)

1. Schwierigkeitsgrad: Ball wird schneller nach jedem erfolgreichen Return (Punkt)
1. Winkel am Schläger: Auftreffpunkt bestimmt `BALL_UP_REG` bzw. eine diskrete Steigung
1. Zweiter Spieler: linker Schläger über andere Tasten, Ball prallt an beiden Schlägern
1. Partikel-Effekt: bei Schlägerkontakt ein kurzes Sprite-Overlay (kleine Funken)
1. Pause-Funktion: Zustand `PAUSE`, Ball und Schläger stehen, Text "Pause"
1. Scoreboard: Highscore im BRAM/Registers, Anzeige im Titelbildschirm

---

## Ergebniskontrolle am Ende von Labor 4

Euer Stand 04_pong_pretty enthält:

1. Runden Ball als Sprite (sichtbar nicht-rechteckig)
2. ASCII-ROM aus BRAM (COE geladen) mit geeigneter Clock (empfohlen `PIX_CLK`) und passender Pipeline
3. Titeltext "Pong" über `TEXT_DISPLAY`
4. Code-Struktur mit ausgelagerter Text-Komponente
5. Typdefinition in einem Package `text_types_pkg` und Verwendung von `text_array_t`
6. Mindestens zwei unterschiedliche Texte abhängig von `STATE_REG` (Titel und Game Over oder Punkte-Label)
