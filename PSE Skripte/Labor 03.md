# Labor 03: Spiellogik für Pong mit Zustandsautomat, Leben und Punkten (Basys 3, VHDL)

## Ziel

In diesem Labor erweitert ihr euer dynamisches Pong aus Labor 02 um eine einfache Spiellogik:

1. Zustandsautomat für Titelbildschirm, Spiel mit 3/2/1 Leben und Game-Over
2. Leben werden über die Board-LEDs ausgegeben
3. Punkte werden auf der Sieben-Segment-Anzeige ausgegeben
4. Ein Leben geht verloren, wenn der Ball nicht zurückgespielt wird und rechts aus dem Bild läuft (der Ball muss nicht zurückgesetzt werden, der X-Wert läuft über und der Ball kommt von links wieder ins Bild)
5. Ein Punkt wird gezählt, wenn der Ball am Schläger abprallt (Erkennung über Richtungswechsel)

Ihr arbeitet auf Basis des Projekts 03_pong_game.

## Teil A: Ports und Signalfluss für Leben und Punkte

In der Top-Level Entity müssen neue Ports für die Ausgabe der Leben auf den LEDs und der Punkte auf der 7-Segment-Anzeige ergänzt werden. Diese Signale kommen aus PONG1. Für die 7-Segment Ausgabe soll das Pojekt (`08_sseg`) aus der Vorlesung als Komponente eingebunden werden. Da die Punkte nicht direkt nach außen verbunden werden, sondern in die 7-Segment-Anzeige, muss hierfür ein Signal angelegt werden.

### A1: Ports in `PONG1`

In `pong.vhd` hat `PONG1` zusätzlich zu Grafikports bereits Ausgänge für Leben und Punkte:

1. `LIVES : out std_logic_vector(2 downto 0)`
2. `POINTS : out UNSIGNED(11 downto 0)`

Prüft, dass diese Ports in eurer Version vorhanden sind und mit der Top-Level-Verschaltung übereinstimmen.

### A2: Top-Level-Verschaltung

In `pong_top.vhd` wird `PONG1` so angebunden, dass:

1. `LIVES` direkt auf `LED` geht: `LIVES => LED`
2. `POINTS` auf `POINTS_sig` geht: `POINTS => POINTS_sig`
3. `sseg` bekommt `POINTS_sig` als `num`

Damit ist die Ausgabe bereits klar getrennt:

1. Spielmodul `PONG1` entscheidet, was Leben und Punktestand sind
2. Anzeige-Module `LED` und `sseg` visualisieren nur

## Teil B: Zustandsautomat für den Spielablauf

### B1: Zustände definieren

In `pong.vhd` wird ein Enum-Typ `state_type` definiert und als Register geführt:

1. `type state_type is (TITLE_1, TITLE_2, LIVES_3, LIVES_2, LIVES_1, GAME_OVER_1, GAME_OVER_2);`
2. `signal STATE_REG, STATE_NEXT : state_type := TITLE_1;`

Warum gibt es `TITLE_1` und `TITLE_2` (und analog `GAME_OVER_1`, `GAME_OVER_2`)?
Das sind Zwischenzustände zur "Button-Release-Logik":

1. `TITLE_1` wartet darauf, dass beide Taster losgelassen sind
2. `TITLE_2` wartet darauf, dass ein Tastendruck kommt, um ins Spiel zu wechseln

So verhindert ihr, dass ein bereits gedrückter Taster sofort den nächsten Zustand auslöst.

### B2: Übergangslogik als Kombinatorik

Die Zustandsübergänge erfolgen in einem kombinatorischen Prozess wie `state_transition`.

In der gegebenen Struktur werden Übergänge so modelliert:

1. Von `TITLE_1` nach `TITLE_2`, wenn `BTN_U = '0'` und `BTN_D = '0'`
2. Von `TITLE_2` nach `LIVES_3`, wenn `BTN_U = '1'` oder `BTN_D = '1'`
3. Von `LIVES_3` nach `LIVES_2`, wenn der Ball rechts aus dem Bild läuft (die nächsten beiden Bedingungen sind identisch)
4. Von `LIVES_2` nach `LIVES_1`, wenn der Ball erneut rechts aus dem Bild läuft
5. Von `LIVES_1` nach `GAME_OVER_1`, wenn der Ball erneut rechts aus dem Bild läuft
6. Von `GAME_OVER_1` nach `GAME_OVER_2`, wenn beide Taster losgelassen sind
7. Von `GAME_OVER_2` nach `TITLE_1`, wenn eine Taste gedrückt wird

Achtet darauf, dass auch wenn die Bedingung nicht zutrifft, `STATE_NEXT` zugewiesen werden muss, sonst wird ein Latch erzeugt.

Für den "Ball ist raus"-Trigger wird im Referenzstand geprüft:
`BALL_X_L_REG >= MAX_X and BALL_X_L_REG <= MAX_X+BALL_SPEED`

Das entspricht praktisch "Ball hat die rechte Bildgrenze erreicht/überschritten" und beachtet, dass immer genau 1 Leben abgezogen wird:
- Der Ball fliegt mit unterschiedlichen Geschwindigkeiten. Bei `BALL_X_L_REG = MAX_X` kann der Wert "überflogen" werden.
- Bei `BALL_X_L_REG > MAX_X` wird mit jedem Frame nach verlassen des Bildschirms ein Leben abgezogen.

### B3: Zustandsregister synchron updaten

Wichtig ist, dass `STATE_REG` nur synchron aktualisiert wird (im Registerprozess mit Takt `CLK`, der hier `VSYNC_sig` ist).

Typisches Muster:

1. Wenn `RST = '1'`, dann `STATE_REG <= TITLE_1`
2. Sonst bei `rising_edge(CLK)`: `STATE_REG <= STATE_NEXT`

Prüft, dass ihr genau diese Trennung habt:

1. Kombinatorik berechnet `STATE_NEXT`
2. Register übernimmt `STATE_NEXT` nach `STATE_REG` pro Frame

### B4: Ballbewegung an Zustand knüpfen

Der Ball soll sich nur in den Zuständen `LIVES_3`, `LIVES_2` oder `LIVES_1` bewegen. Ansonsten (Bei Titelbildschirm und Game Over) kann er auf die Reset-Standardwerte gesetzt werden.

Dies kann durch ein if-Statement erreicht werden, dass die gesamte Bewegungslogik des Balls umschließt.

## Teil C: Leben auf LEDs ausgeben

### C1: Leben aus Zustand ableiten

In `pong.vhd` wird `LIVES` rein aus `STATE_REG` erzeugt, z. B. in `proc_lives`.

Beispielhafte Codierung (wie im Projekt):

1. `LIVES <= "111"` für `LIVES_3`
2. `LIVES <= "011"` für `LIVES_2`
3. `LIVES <= "001"` für `LIVES_1`
4. `LIVES <= "000"` für `GAME_OVER_1` und `GAME_OVER_2`
5. Für `TITLE_1` und `TITLE_2` ebenfalls `LIVES <= "111"` (Anzeige "bereit mit 3 Leben")

Damit ist das LED-Verhalten eindeutig und vollständig durch den Spielzustand bestimmt.

### C2: Reset-Verhalten

Überlegt bewusst, was ihr bei Reset zeigen wollt:
Im Reset-Zustand wird `STATE_REG` initial auf `TITLE_1` gesetzt, damit zeigen die LEDs direkt "3 Leben".

## Teil D: Punkte zählen bei zurückgespieltem Ball

### D1: Idee

Ein Punkt soll gezählt werden, wenn der Ball erfolgreich zurückgespielt wird. Im Projekt wird das über den Richtungswechsel des Balls erkannt:

Punkt-Event ist `rising_edge(BALL_LEFT_REG)`

Interpretation:
Wenn `BALL_LEFT_REG` von `0` auf `1` wechselt, hat der Ball seine Richtung von "nach rechts" auf "nach links" geändert. Das passiert typischerweise bei der Schlägerkollision.

### D2: Umsetzung im Projekt

Im Projekt gibt es:

1. `signal sig_POINTS : unsigned(11 downto 0) := to_unsigned(0,12);`
2. Einen Prozess `proc_points`, der
   2.1 bei `STATE_REG = TITLE_1` die Punkte auf 0 setzt
   2.2 bei `rising_edge(BALL_LEFT_REG)` um 1 erhöht
3. Danach `POINTS <= sig_POINTS`

### D3: Technischer Hinweis

`rising_edge(...)` ist eigentlich für Clock-Signale gedacht. Es funktioniert in manchen Simulationen auch für Daten-Signale, ist aber als Designstil heikel.

Sauberere Variante (empfohlen als optionale Verbesserung):

1. Ein verzögertes Register `BALL_LEFT_REG_D` mit `CLK`
2. Event, wenn `BALL_LEFT_REG = '1'` und `BALL_LEFT_REG_D = '0'`
3. Dann Punkte erhöhen

Ihr könnt das als Bonusaufgabe implementieren, wenn ihr es "richtig" machen wollt.

## Teil E: Sieben-Segment-Anzeige anbinden

### E1: Top-Level

Im Top-Level `pong_top.vhd` wird bereits:

1. `POINTS_sig` von `PONG1` abgeholt
2. an `sseg` übergeben: `num => POINTS_sig`
3. `sseg` erzeugt `AN` und `SEG`

Damit müsst ihr im Pong-Modul nur sicherstellen, dass `POINTS` korrekt hochzählt und sinnvoll zurückgesetzt wird.

### E2: Wertebereich und Darstellung

`POINTS` ist `UNSIGNED(11 downto 0)`, also 0 bis 4095. Die Sieben-Segment-Anzeige kann vier Dezimalstellen zeigen, was gut passt.

Wenn euer `sseg`-Modul aus dem letzten Semester stammt, prüft:

1. Erwartet `sseg` `UNSIGNED` oder `STD_LOGIC_VECTOR`?
2. Im Projekt des letzten Semesters wird `sseg` direkt mit Binärwert `num` gefüttert und die BCD-Wandlung intern gemacht (über `bin_bcd`).

## Teil F: Erwartetes Verhalten als Testplan

### F1: Titelbildschirm

1. Nach Reset ist der Zustand `TITLE_1`
2. LEDs zeigen 3 Leben
3. Punkte sind 0
4. Erst wenn beide Taster losgelassen wurden (Übergang `TITLE_1` -> `TITLE_2`) und danach ein Tastendruck erfolgt (Übergang `TITLE_2` -> `LIVES_3`), startet das Spiel

### F2: Spiel mit Leben

1. Ball läuft, Schläger ist steuerbar
2. Wenn der Ball rechts aus dem Bild läuft, sinkt der Zustand:
   `LIVES_3` -> `LIVES_2` -> `LIVES_1` -> `GAME_OVER_1`
3. LEDs aktualisieren sich entsprechend

### F3: Punkte

1. Immer wenn der Ball am Schläger abprallt und Richtung nach links wechselt, steigt `POINTS` um 1
2. Beim Zurückkehren in `TITLE_1` werden Punkte zurückgesetzt

### F4: Game Over und Neustart

1. In `GAME_OVER_1`/`GAME_OVER_2` bleiben die Leben auf 0
2. Neustart erfolgt über die Release/Press-Sequenz:
   `GAME_OVER_1` wartet auf Loslassen
   `GAME_OVER_2` wartet auf Tastendruck
   dann zurück nach `TITLE_1`

## Abgabe

Euer Stand 03_pong_game enthält:

1. Zustandsautomat mit `STATE_REG` und `STATE_NEXT` und Zuständen `TITLE_1`, `TITLE_2`, `LIVES_3`, `LIVES_2`, `LIVES_1`, `GAME_OVER_1`, `GAME_OVER_2`
2. Leben als `LIVES` auf `LED`
3. Punkte als `POINTS` auf `sseg` über `POINTS_sig`
4. Punkte werden bei "Return" gezählt (im Projekt: `rising_edge(BALL_LEFT_REG)`)
5. Leben gehen verloren, wenn `BALL_X_L_REG` die rechte Grenze erreicht/überschreitet

