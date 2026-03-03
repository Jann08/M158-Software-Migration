# Software-Migration kompakt

## 1. Wann ist eine migration nötig?
- Technische Limitierung: Das alte System erfüllt neue Leistungs-, Sicherheits- oder Funktionsanforderungen nicht mehr.
- Wirtschaftlichkeit: Eine Neuentwicklung ist zu teuer die migration ist die kostengünstigere Alternative.

## 2. Definition
- Übertragung eines Systemteils in ein anderes. Alle Daten werden verschoben, ohne die Funktionalität zu verändern.  
- Vorteil: Keine Neuinstallation der Daten nötig.

## 3. Bereich im Software-Engineering
Gehört zur Software-Erhaltung (Maintenance) – also Aktivitäten nach der ersten Software-Freigabe.

## 4. Zusammenhang Hard- & Software-Migration
Beide prozesse gehen oft miteinander einher:
- Neue Hardware erfordert meist eine aktualisierte Software, um lauffähig zu bleiben zb bei Servern.

## 5. Wichtige Regel
Keine funktionalen Änderungen während der Migration!
- Grund: Nur ein funktional identisches System kann korrekt gegen das ursprüngliche getestet werden.
- Änderungen gehören nach der Migration.

## 6. Reengineering vs. Migration
- Reengineering: Verbesserung der Software-Qualität in der bisherigen Umgebung (Architektur/Code).
- Migration: Überführung des Systems in eine neue Umgebung.

## 7. Reverse Engineering
Ableiten/Nachdokumentieren von Informationen über ein bestehendes System (z. B. Diagramme, Text).  
Das System bleibt unverändert.

Zwecke:
- Wettbewerbsanalyse
- Erkennen von Differenzierungsmöglichkeiten
- Grundlage für Migration/Weiterentwicklung