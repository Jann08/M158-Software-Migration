# Projektplan: CRM-Migration crmserver.sample.ch

**Projekt:** Migration des bestehenden CRM-Systems auf Ubuntu 22.04 LTS  
**Auftraggeber:** Perret Pascal (M158 Kompetenznachweis)  
**Projektleiter:** [Jann]  
**Datum:** 17.03.2026  
**Version:** 1.0

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
- ✅ IST-Analyse des bestehenden Systems (CentOS 6.6)
- ✅ Aufbau einer Testumgebung
- ✅ Installation und Konfiguration von Ubuntu 22.04 LTS
- ✅ Webserver (Apache 2.4)
- ✅ PHP 8.1 mit allen benötigten Modulen
- ✅ MariaDB 10.6
- ✅ PhpMyAdmin/Adminer
- ✅ SFTP-Zugang
- ✅ Migration der vtigercrm-Datenbank
- ✅ Migration der vtigercrm-Dateien
- ✅ Backup-Strategie
- ✅ Testing
- ✅ Monitoring
- ✅ Deployment mit minimaler Ausfallzeit

### Nicht im Umfang enthalten:
- ❌ Migration auf OpenERP/Odoo (Variante B)
- ❌ Anpassungen am CRM-Funktionsumfang
- ❌ Hardware-Beschaffung

## 3. Migrationsvariante

**Ausgewählte Variante: A - Vtiger neueste Version auf Ubuntu 22.04 LTS**

Begründung:
- Geringstes Risiko für Datenverlust
- Minimale Ausfallzeit
- Keine Einarbeitung in neues System nötig
- Kostengünstigste Lösung
- Bewährte Technologie

## 4. Zeitplan (8 Tage)

| Tag | Datum | Phase | Meilenstein |
|-----|-------|-------|-------------|
| 1 | 17.03. | Analyse | IST-Analyse abgeschlossen, Projektplan genehmigt |
| 2 | 18.03. | Planung | Architekturdiagramme, Testumgebung bereit |
| 3 | 19.03. | Testumgebung | Basis-OS, Webserver, PHP installiert |
| 4 | 20.03. | Testumgebung | DB, PhpMyAdmin, SFTP einsatzbereit |
| 5 | 21.03. | Migration | Daten exportiert/importiert, erste Tests |
| 6 | 22.03. | Migration | CRM-Upgrade erfolgreich, Validierung |
| 7 | 23.03. | Backup/Testing | Backup läuft, Tests abgeschlossen |
| 8 | 24.03. | Deployment | Go-Live erfolgreich, Abnahme |

## 5. Ressourcen

### Hardware/Software
| Ressource | Spezifikation | Bemerkung |
|-----------|---------------|-----------|
| IST-System | CentOS 6.6 VM | Vorhanden |
| Testsystem | Ubuntu 22.04 VM | Neu zu erstellen |
| Zielsystem | Ubuntu 22.04 VM | Produktiv |
| Backup-Speicher | 50 GB | Extern |

### Personal
| Rolle | Name | Verantwortlichkeiten |
|-------|------|---------------------|
| Projektleiter | [Jann] | Gesamtkoordination, Dokumentation |
| Administrator | [Jann] | Technische Umsetzung |
| Tester | [Jann] | Qualitätssicherung |