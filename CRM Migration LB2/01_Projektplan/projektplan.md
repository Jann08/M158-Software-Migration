# Projektplan: CRM-Migration crmserver.sample.ch

**Projekt:** Migration des bestehenden CRM-Systems auf Ubuntu 22.04 LTS  
**Auftraggeber:** Perret Pascal (M158 Kompetenznachweis)  
**Projektleiter:** Jann  
**Datum:** 19.03.2026  
**Version:** 1.1

## 1. Projektziele

| Ziel | Beschreibung | Priorität |
|------|--------------|-----------|
| Z1 | Migration des bestehenden CRM-Systems auf Ubuntu 22.04 LTS | Hoch |
| Z2 | Vollständige Übernahme aller Daten (kein Datenverlust) | Hoch |
| Z3 | Minimale Ausfallzeit (< 4 Stunden) | Hoch |
| Z4 | Erhöhung der Systemsicherheit durch moderne Software | Mittel |
| Z5 | Vollständige Dokumentation aller Schritte | Mittel |

## 2. Projektumfang

### Im Umfang enthalten:
- IST-Analyse des bestehenden Systems (CentOS 6.6)
- Aufbau einer Testumgebung
- Installation und Konfiguration von Ubuntu 22.04 LTS
- Webserver (Apache 2.4)
- PHP 8.1 mit allen benötigten Modulen
- MariaDB 10.6
- PhpMyAdmin/Adminer
- SFTP-Zugang
- Migration der vtigercrm-Datenbank
- Migration der vtigercrm-Dateien
- Backup-Strategie
- Testing
- Monitoring
- Deployment mit minimaler Ausfallzeit

### Nicht im Umfang enthalten:
- Migration auf OpenERP/Odoo (Variante B)
- Anpassungen am CRM-Funktionsumfang
- Hardware-Beschaffung

## 3. Migrationsvariante

**Ausgewählte Variante: A - Vtiger neueste Version auf Ubuntu 22.04 LTS**

Begründung:
- Geringstes Risiko für Datenverlust
- Minimale Ausfallzeit
- Keine Einarbeitung in neues System nötig
- Kostengünstigste Lösung
- Bewährte Technologie

## 5. Ressourcen

### Hardware/Software
| Ressource | Spezifikation | Bemerkung |
|-----------|---------------|-----------|
| IST-System | CentOS 6.6 VM | Vorhanden |
| Testsystem | Ubuntu 22.04 VM | Neu zu erstellen |
| Zielsystem | Ubuntu 22.04 VM | Produktiv |
| Backup-Speicher | 50 GB | Extern |
