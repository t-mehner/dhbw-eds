# Labor 02: Vom statischen zum dynamischen Pong

## Ziel

In diesem Labor erweitert ihr euer statisches Pong (`01_pong_stat`) zu einem dynamischen Pong (`02_pong_dyn`):

1. Der Schläger lässt sich mit Tastern bewegen und bleibt immer vollständig im sichtbaren Bereich.
2. Der Ball bewegt sich selbstständig.
3. Der Ball prallt ab
   1. oben und unten am Bildschirmrand
   2. links an der Wand
   3. rechts am Schläger (nur bei Kollision)

Am Ende habt ihr ein spielbares „Endlos-Pong“ ohne Punkte/Leben (das kommt in Labor 03).

## Voraussetzungen

Ihr startet von eurem funktionierenden Projekt `01_pong_stat` mit VGA-Ausgabe.

Empfohlene Parameter (wie im späteren Referenzdesign)
Auflösung 640×480@60 Hz
Schlägerbreite 8 px, Schlägerhöhe 64 px, Schläger-x rechts bei ca. 600
Ballgröße 8×8 px
Geschwindigkeit (Ball und Schläger) zunächst 2 px pro Frame

## Grundidee der Erweiterung

Im statischen Pong sind Ball- und Schlägerpositionen Konstanten bzw. einmalig gesetzte Signale. Für Bewegung braucht ihr:

1. Register (REG) für den aktuellen Zustand, z. B. BAR_Y_O_REG, BALL_X_L_REG
2. Next-State-Signale (NEXT), die im Kombinatorik-Teil berechnet werden
3. Einen synchronen Prozess, der pro „Frame“ die NEXT-Werte in die REG-Werte übernimmt
4. Kollisionserkennung, die Richtungsbits umschaltet (Ball links/rechts, Ball hoch/runter)

Wichtig: Ihr wollt nicht bei jedem 100 MHz-Takt bewegen. Eine einfache Lösung ist, nur einmal pro Frame zu updaten, also synchron zur VSYNC-Flanke.

## Schritt 1: Top-Level um Taster erweitern und Frame-Takt erzeugen

Öffnet euer Top-Level (z. B. pong_top.vhd).

1. Ergänzt Ports für BTN_U und BTN_D (Basys 3: Up/Down-Taster).
2. Gebt VSYNC nicht nur nach außen aus, sondern nutzt es intern als „Frame-Takt“ für die Spiel-Logik.
   Idee: VGA-Sync erzeugt VSYNC_sig, dieses Signal taktet eure Pong-Logik.

Minimaler Umbau (Prinzip):

* VGA_SYNC liefert VSYNC_sig
* PONG-Entity bekommt zusätzlich BTN_U, BTN_D, CLK und RST
* CLK für die Bewegung ist VSYNC_sig (oder ein daraus abgeleiteter Enable)

Hinweis zur Flanke: In vielen VGA-Sync-Implementierungen ist VSYNC aktiv-low. Für die Bewegung ist nur wichtig, dass ihr eine eindeutige Flanke als „einmal pro Frame“-Ereignis nutzt (typisch rising_edge auf ein registriertes VSYNC).

## Schritt 2: Constraints (XDC) für die Taster setzen

In eurer XDC-Datei ergänzt ihr Ports für BTN_U und BTN_D und mappt sie auf die Basys-3 Pins.

Beispiel (Basys-3-typisch):

* BTN_U auf T18
* BTN_D auf U17

Achtet darauf, dass die Portnamen exakt zu euren Entity-Ports passen.

## Schritt 3: Entity/Portliste der Grafik-Logik erweitern

In eurer Pong-Logik (z. B. pong.vhd, Entity PONG1):

1. Fügt Eingänge hinzu:
   BTN_U, BTN_D : in std_logic
   RST, CLK : in std_logic

2. Behaltet VIDEO_ON, PIX_X, PIX_Y und GRAPH_RGB wie gehabt.

Ziel: Die Grafik-Logik bekommt Taster und einen langsamen Takt (Frame-Takt) und kann damit Positionen updaten.

## Schritt 4: Aus Konstanten werden Register

Im statischen Design waren die Objekte effektiv „fest“. Jetzt braucht ihr für Ball und Schläger REG/NEXT-Signale.

Schläger (Beispielstruktur)

* BAR_Y_O_REG, BAR_Y_U_REG als aktuelle Grenzen
* BAR_Y_O_NEXT, BAR_Y_U_NEXT als berechneter nächster Zustand
* BAR_X_L und BAR_X_R können Konstanten bleiben (Schläger bewegt sich nur vertikal)

Ball (Beispielstruktur)

* BALL_X_L_REG, BALL_X_R_REG, BALL_Y_O_REG, BALL_Y_U_REG
* dazu NEXT-Signale
* zwei Richtungsbits als Register:
  BALL_LEFT_REG (1 bedeutet „Ball bewegt sich nach links“)
  BALL_UP_REG (1 bedeutet „Ball bewegt sich nach oben“)

Parameter als Konstanten

* BAR_SPEED (z. B. 2)
* BALL_SPEED (z. B. 2)
* Bildschirmgrenzen: X 0..639, Y 0..479

## Schritt 5: Synchroner Prozess für Zustandsregister (Frame-Update)

Erstellt einen Prozess, der bei Reset initialisiert und sonst pro rising_edge(CLK) (Frame-Takt) die NEXT-Werte übernimmt.

Prinzip:

* if RST = '1' then
  setze Startpositionen für Ball/Schläger und Richtungen
* elsif rising_edge(CLK) then
  REG <= NEXT

Didaktischer Hinweis: Das ist die wichtigste Strukturänderung gegenüber Labor 01. Ab hier ist eure Logik ein klassischer „Zustandsautomat“ auf Signalebene (auch wenn ihr noch keine Spielzustände habt).

## Schritt 6: Schlägerbewegung mit Begrenzung

Jetzt berechnet ihr BAR_Y_**NEXT aus BAR_Y**_REG und den Tastern.

Vorgaben:

* BTN_U bewegt nach oben, BTN_D nach unten
* Der Schläger darf den Bildschirm nicht verlassen

Konkrete Begrenzung (bei Höhe 64 px):

* Oberkante minimal 0
* Oberkante maximal 480 - 64

Typischer Ansatz:

1. Wenn BTN_U = '1' und BAR_Y_O_REG > BAR_SPEED, dann BAR_Y_O_NEXT = BAR_Y_O_REG - BAR_SPEED
2. Wenn BTN_D = '1' und BAR_Y_O_REG < 480-64-BAR_SPEED, dann BAR_Y_O_NEXT = BAR_Y_O_REG + BAR_SPEED
3. Sonst BAR_Y_O_NEXT = BAR_Y_O_REG
4. BAR_Y_U_NEXT immer als BAR_Y_O_NEXT + 64

Hinweis: Wenn beide Taster gleichzeitig gedrückt sind, definiert ihr ein Verhalten (z. B. keine Bewegung oder Priorität). Für den Anfang ist „keine Bewegung“ ok.

## Schritt 7: Ballbewegung und Kollisionen

Ihr berechnet BALL_**NEXT aus BALL**_REG, den Richtungsbits und den Kollisionen.

7.1 Kollision oben/unten
Wenn BALL_UP_REG = '1', geht der Ball nach oben:

* Wenn BALL_Y_O_REG > BALL_SPEED, dann weiter nach oben
* Sonst: an der Kante bleiben und BALL_UP_NEXT auf '0' setzen (Richtung wechseln)

Wenn BALL_UP_REG = '0', geht der Ball nach unten:

* Wenn BALL_Y_U_REG <= 480 - BALL_SPEED, dann weiter nach unten
* Sonst: an der Kante bleiben und BALL_UP_NEXT auf '1' setzen

7.2 Kollision links (Wand)
Ihr habt im statischen Design schon eine Wand an der linken Seite. Nutzt deren X-Grenzen.
Wenn BALL_LEFT_REG = '1' (Ball nach links):

* Wenn BALL_X_L_REG noch größer als WALL_X_R + BALL_SPEED ist, weiter nach links
* Sonst: an der Wand „absetzen“ und BALL_LEFT_NEXT auf '0' setzen (Richtung wechseln)

7.3 Kollision rechts (Schläger)
Wenn BALL_LEFT_REG = '0' (Ball nach rechts), gibt es zwei Fälle:

Fall A: Ball trifft den Schläger
Kollisionsbedingung (Axis-Aligned Bounding Box):

* BALL_X_R_REG >= BAR_X_L
* BALL_X_L_REG <  BAR_X_R
* BALL_Y_O_REG <  BAR_Y_U_REG
* BALL_Y_U_REG >  BAR_Y_O_REG

Dann:

* Setzt BALL_LEFT_NEXT auf '1' (Ball geht wieder nach links)
* Position könnt ihr entweder einfrieren oder leicht zurücksetzen, um „kleben“ zu vermeiden

Fall B: Kein Treffer
Dann bewegt sich der Ball normal nach rechts und BALL_LEFT_NEXT bleibt '0'.

Hinweis: In Labor 03 wird „kein Treffer“ relevant, weil dann ein Leben verloren geht. In Labor 02 ist es okay, wenn der Ball einfach weiter nach rechts aus dem Bild läuft. Wenn ihr schon jetzt eine saubere Demo wollt, könnt ihr alternativ bei X > 639 den Ball zurücksetzen. Entscheidet euch bewusst, weil das Verhalten später in Labor 03 geändert wird.

## Schritt 8: Rendering an die REG-Signale anbinden

Im statischen Design prüft ihr bei BAR_ON und BALL_ON gegen feste Koordinaten. Das muss jetzt auf die REG-Signale zeigen.

Beispiele:

* BAR_ON nutzt BAR_Y_O_REG und BAR_Y_U_REG
* BALL_ON nutzt BALL_X_L_REG, BALL_X_R_REG, BALL_Y_O_REG, BALL_Y_U_REG

Die Farbausgabe (Multiplexing Wand/Schläger/Ball/Hintergrund) bleibt konzeptionell gleich.

## Schritt 9: Simulation und Hardwaretest

9.1 Schneller Check in der Simulation

* Prüft, dass BAR_Y_O_REG auf BTN_U/BTN_D reagiert und in den Grenzen bleibt
* Prüft, dass BALL_X_* und BALL_Y_* pro Frame laufen und Richtungen an den Kanten wechseln
* Prüft die Schlägerkollision (mindestens einmal gezielt „Ball trifft Schläger“)

9.2 Hardwaretest auf Basys 3

* VGA anschließen, Bitstream laden
* BTN_U/BTN_D bewegen den Schläger
* Ball bewegt sich flüssig (nicht extrem schnell). Wenn zu schnell, nutzt wirklich VSYNC als Bewegungstakt oder baut einen Zähler-Enable ein.

## Typische Fehlerbilder und Debug-Hinweise

1. Ball bewegt sich viel zu schnell
   Ursache: Ihr taktet mit 100 MHz statt mit Frame-Rate. Lösung: VSYNC-Enable oder Divider.

2. Schläger verlässt den Bildschirm
   Ursache: Grenzen falsch (480 vs 479) oder falsches Signal verglichen. Lösung: konsequent Oberkante begrenzen, Unterkante als Oberkante+Höhe.

3. Ball „klebt“ am Schläger oder flackert
   Ursache: Nach Kollision bleibt der Ball in überlappender Position und triggert sofort wieder. Lösung: bei Treffer Ball minimal zurücksetzen oder X so setzen, dass er knapp links vom Schläger liegt.

4. Kollisionen wirken „unlogisch“
   Ursache: Bounding-Box-Test falsch (>, >= vertauscht) oder ihr nutzt NEXT statt REG. Lösung: Kollisionen immer mit REG berechnen, NEXT daraus ableiten.

## Abgabe

Euer Projektstand 02_pong_dyn enthält:

* Pong mit beweglichem Schläger (BTN_U/BTN_D) und Begrenzung
* Ballbewegung
* Abprallen an Wand links, Bildschirmrand oben/unten, Schläger rechts
* Sauberen Register/Next-State-Aufbau mit synchronem Frame-Update

## Erweiterungsaufgaben (optional)

1. Variiert BALL_SPEED und BAR_SPEED und bewertet Spielbarkeit.
2. Implementiert eine zweite Wand oben/unten als eigene Objekte (wie linke Wand), statt nur über Bildschirmgrenzen.
3. Baut einen „Serve“ ein: Ball startet erst nach Tastendruck.
