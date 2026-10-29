# BordBar 🛎️🍹

Bordkarte scannen → Getränk wählen → das iPhone klingelt wie eine Service-Glocke
und ruft laut aus, was gewünscht ist („Einen Aperol Spritz, bitte!“). Danach zeigt das
Display die Bestellung groß an, damit der Getränkebote weiß, was er holen soll.

## Ablauf

1. App öffnen, Barcode der Bordkarte vor die Kamera halten.
2. Pop-up „Welches Getränk?“ → Kaffee, Bier, Aperol Spritz, Gin Tonic, Ice Rosé.
3. *Ding-Ding!* plus Sprachansage, groß angezeigt mit **Nochmal klingeln** / **Erledigt – Prost!**

Gelesen werden alle gängigen Barcodes (QR, PDF417, Aztec, Data Matrix, Code 128/39/93,
EAN, ITF). Die App wertet den Inhalt nicht aus – der Code dient nur als Auslöser und wird
zur Orientierung angezeigt. Zum Testen zu Hause reicht also jeder Barcode, z. B. auf einer
Milchtüte.

Die Klingel spielt auch bei aktivem **Stummschalter**. Die Lautstärke regelt weiterhin
die Lautstärketaste.

## Aufs iPhone bringen

Voraussetzung: Mac mit **Xcode 16 oder neuer**, iPhone mit **iOS 17 oder neuer**.

1. `BordBar/BordBar.xcodeproj` in Xcode öffnen.
2. Target **BordBar** → *Signing & Capabilities* → unter *Team* die eigene Apple-ID wählen.
   Falls der Bundle Identifier `de.lajtho.BordBar` schon vergeben ist, einfach ändern.
3. iPhone per Kabel anschließen und oben als Ziel auswählen.
4. Auf dem iPhone einmalig *Einstellungen → Datenschutz & Sicherheit → Entwicklermodus*
   aktivieren (iOS fragt beim ersten Start danach).
5. ▶︎ (Cmd+R) – fertig.

> **Achtung Kreuzfahrtdauer:** Mit einer kostenlosen Apple-ID läuft die App nach
> **7 Tagen** ab und muss neu aus Xcode installiert werden. Für längere Reisen hilft das
> Apple Developer Program (99 €/Jahr): Dann ist die App ein Jahr gültig, oder man
> verteilt sie per TestFlight (90 Tage).

Im **Simulator** gibt es keine Kamera – dort erscheint stattdessen ein Button „Test-Scan“.

## Anpassen

| Was | Wo |
| --- | --- |
| Getränke, Emojis, Ansagetext | `BordBar/Drink.swift` → `Drink.menu` |
| Klingelton | `BordBar/Klingel.wav` durch eine eigene Datei ersetzen (`Klingel.wav`, `.m4a`, `.mp3` oder `.caf`) |
| Eingebauten Ton neu erzeugen/tunen | `python3 Tools/klingel.py` |

Neue Dateien im Ordner `BordBar/BordBar/` landen automatisch im Xcode-Projekt.

## Build-Check

Der Workflow `.github/workflows/build-bordbar.yml` baut die App bei jeder Änderung unter
`BordBar/` auf einem macOS-Runner für den Simulator (ohne Signierung).
