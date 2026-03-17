# Migrationsvarianten: Vtiger vs. OpenERP/Odoo

**Datum:** 17.03.2026  
**Version:** 1.0  
**Ersteller:** [Jann]

## 1. Ausgangslage

Aktuelles System: **vtigercrm** auf CentOS 6.6 mit MySQL 5.1  
Datenbank: vtigercrm (Grösse unbekannt, aber produktiv im Einsatz)

---

## 2. Variante A: Vtiger neueste Version

### 2.1 Was ist Vtiger?
Vtiger ist eine Open-Source-CRM-Software, die speziell für kleine und mittlere Unternehmen entwickelt wurde. Funktionen umfassen Kontaktmanagement, Verkaufsautomation, Support-Tickets und E-Mail-Integration.

### 2.2 Technische Anforderungen (Vtiger 7.x)
| Komponente | Anforderung |
|------------|-------------|
| OS | Ubuntu 20.04/22.04, CentOS 7/8 |
| Webserver | Apache 2.4 oder Nginx |
| PHP | 7.4 - 8.1 (je nach Version) |
| Datenbank | MySQL 5.7 / 8.0 oder MariaDB 10.x |
| Speicher | Mind. 2 GB RAM, 10 GB Festplatte |

### 2.3 Migrationsprozess
1. Backup der bestehenden Vtiger-Datenbank und -Dateien
2. Installation neuer Vtiger-Version auf Zielsystem
3. Datenbank-Update mit Vtiger-eigenem Upgrade-Skript
4. Konfigurationsdateien anpassen
5. Tests und Validierung

### 2.4 Vor- und Nachteile

| Vorteile | Nachteile |
|----------|-----------|
| ✓ Gleiche Benutzeroberfläche – keine Schulung nötig | ✗ Vtiger-Entwicklung in letzter Zeit eher ruhig |
| ✓ Datenstruktur bleibt identisch | ✗ Nicht alle Erweiterungen kompatibel |
| ✓ Geringstes Risiko für Datenverlust | ✗ Limitierte Anpassungsmöglichkeiten |
| ✓ Schnellste Migration (Stunden) | ✗ |
| ✓ Bewährter Prozess (Dokumentation vorhanden) | ✗ |

## 3. Variante B: OpenERP / Odoo

### 3.1 Was ist Odoo?
Odoo (früher OpenERP) ist eine umfassende Open-Source-ERP-Suite mit integrierten CRM-Modulen. Es bietet neben CRM auch Buchhaltung, Lagerverwaltung, E-Commerce und vieles mehr.

### 3.2 Technische Anforderungen (Odoo 16/17)
| Komponente | Anforderung |
|------------|-------------|
| OS | Ubuntu 20.04/22.04, Debian 11 |
| Webserver | Nginx (empfohlen) oder Apache |
| Python | 3.8 - 3.10 |
| Datenbank | PostgreSQL 12 - 14 |
| Speicher | Mind. 4 GB RAM, 20 GB Festplatte |

### 3.3 Migrationsprozess
1. Backup der bestehenden Vtiger-Datenbank
2. Installation Odoo auf Zielsystem
3. Datenexport aus Vtiger (CSV/Excel)
4. Daten-Mapping Vtiger → Odoo (manuelle Zuordnung)
5. Datenimport in Odoo (mit Import-Tools)
6. Anpassung der Odoo-Konfiguration
7. Tests und Validierung

**Herausforderung:** Vtiger und Odoo haben komplett unterschiedliche Datenstrukturen. Felder wie "Firma", "Kontakt", "Adresse" müssen manuell zugeordnet werden.

### 3.4 Vor- und Nachteile

| Vorteile | Nachteile |
|----------|-----------|
| ✓ Modernere Technologie (Python/PostgreSQL) | ✗ Komplett neue Benutzeroberfläche – Schulung nötig |
| ✓ Aktiv weiterentwickelt (grosse Community) | ✗ Sehr hohes Risiko für Datenverlust/Fehler |
| ✓ Integrierte ERP-Funktionen | ✗ Daten-Mapping aufwändig (50+ Felder) |
| ✓ Besser skalierbar | ✗ Lange Migrationszeit (Tage bis Wochen) |
| ✓ | ✗ PostgreSQL statt MySQL – kompletter DB-Wechsel |