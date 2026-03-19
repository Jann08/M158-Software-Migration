# Risikoanalyse: CRM-Migration

**Projekt:** CRM-Migration
**Datum:** 19.03.2026  
**Version:** 1.1

## Risikomatrix

| Wahrsch. \ Auswirkung | Gering | Mittel | Hoch |
|----------------------|--------|--------|------|
| **Hoch** | | | R3 |
| **Mittel** | R4 | R2 | R1 |
| **Gering** | | R5 | |

## Detailanalyse

### R1: Datenverlust bei Migration
| Feld | Beschreibung |
|------|--------------|
| **Risiko** | Bei der Migration gehen Daten verloren (Kunden, Produkte, Einstellungen) |
| **Wahrscheinlichkeit** | Mittel |
| **Auswirkung** | Hoch |
| **Risikowert** | **Hoch** |
| **Eintrittsdatum** | Migrationstag |
| **Erkennung** | Nach DB-Import: Prüfung der Datensatzanzahl, Stichproben |

**Massnahmen:**
- ✅ Mindestens 3 unabhängige Backups vor Migration
- ✅ Backup-Restore vorab in Testumgebung üben
- ✅ Export als SQL-Dump mit Daten-Prüfsumme
- ✅ Nach Import: Automatischer Vergleich der Datensatzanzahl pro Tabelle

**Verantwortlich:** Administrator  
**Deadline:** Vor Migrationsbeginn

---

### R2: Inkompatibilität PHP/Vtiger
| Feld | Beschreibung |
|------|--------------|
| **Risiko** | Vtiger ist nicht kompatibel mit PHP 8.1 oder neueren MySQL-Versionen |
| **Wahrscheinlichkeit** | Mittel |
| **Auswirkung** | Mittel |
| **Risikowert** | **Mittel** |
| **Eintrittsdatum** | Nach Migration |
| **Erkennung** | CRM startet nicht oder zeigt Fehler |

**Massnahmen:**
- ✅ Vtiger-Dokumentation prüfen (min. PHP-Version)
- ✅ Vtiger-Upgrade auf neueste Version vor Migration
- ✅ Testumgebung mit identischer Konfiguration
- ✅ Falls nötig: PHP 7.4 als Alternative bereithalten

**Verantwortlich:** Administrator  
**Deadline:** Vor Testmigration

---

### R3: Ausfall länger als geplant
| Feld | Beschreibung |
|------|--------------|
| **Risiko** | Die Migration dauert länger als 4 Stunden, System ist nicht verfügbar |
| **Wahrscheinlichkeit** | Hoch |
| **Auswirkung** | Hoch |
| **Risikowert** | **Hoch** |
| **Eintrittsdatum** | Go-Live-Tag |
| **Erkennung** | Zeitplan wird überschritten |

**Massnahmen:**
- ✅ Detaillierter Zeitplan mit Puffer (2h extra)
- ✅ Alle Schritte vorab in Testumgebung geübt
- ✅ Klare Abbruchkriterien definieren
- ✅ Rollback-Plan vorbereitet
- ✅ Kommunikation an Kunde: Wartungsfenster grosszügig ansetzen

**Verantwortlich:** Projektleiter  
**Deadline:** Vor Go-Live

---

### R4: Firewall blockiert Zugriff
| Feld | Beschreibung |
|------|--------------|
| **Risiko** | Nach Migration sind Dienste nicht erreichbar wegen Firewall |
| **Wahrscheinlichkeit** | Mittel |
| **Auswirkung** | Gering |
| **Risikowert** | **Gering** |
| **Eintrittsdatum** | Nach Deployment |
| **Erkennung** | Website/SSH nicht erreichbar |

**Massnahmen:**
- Firewall-Regeln vorab dokumentieren (aus IST-System)
- Checkliste für benötigte Ports (22, 80, 443, 3306)
- Nach Deployment: Port-Scan durchführen

**Verantwortlich:** Administrator  
**Deadline:** Nach Installation

---

### R5: Backup-Wiederherstellung fehlschlägt
| Feld | Beschreibung |
|------|--------------|
| **Risiko** | Im Notfall kann das Backup nicht eingespielt werden |
| **Wahrscheinlichkeit** | Gering |
| **Auswirkung** | Mittel |
| **Risikowert** | **Gering** |
| **Eintrittsdatum** | Bei Notfall |
| **Erkennung** | Restore-Prozess bricht ab |

**Massnahmen:**
- Backup-Restore vorab in Testumgebung testen
- Backup-Skript dokumentieren
- Integritätsprüfung der Backup-Dateien
- Zwei verschiedene Backup-Methoden (Dump + Dateisystem)

**Verantwortlich:** Administrator  
**Deadline:** Vor Go-Live

---

## Risiko-Übersicht

| ID | Risiko | Wahrsch. | Auswirkung | Risikowert | Massnahme |
|----|--------|----------|------------|------------|-----------|
| R1 | Datenverlust | Mittel | Hoch | **Hoch** | 3-fach Backup, Test-Restore |
| R2 | Inkompatibilität | Mittel | Mittel | **Mittel** | Kompatibilität prüfen, Testumgebung |
| R3 | Ausfall zu lang | Hoch | Hoch | **Hoch** | Puffer, Übung, Rollback |
| R4 | Firewall | Mittel | Gering | **Gering** | Ports dokumentieren, Check |
| R5 | Backup fehlschlägt | Gering | Mittel | **Gering** | Restore testen |


## Abbruchkriterien

Die Migration wird abgebrochen und ein Rollback durchgeführt bei:

1. Datenverlust von > 10 Datensätzen
2. Ausfallzeit > 6 Stunden
3. Kritische CRM-Funktionen arbeiten nicht
4. Sicherheitslücken im neuen System

## Rollback-Plan

1. DNS auf altes System zurücksetzen (TTL beachten!)
2. Alte VM wieder starten
3. Funktion prüfen
4. Kunde informieren
5. Fehleranalyse im Testsystem
