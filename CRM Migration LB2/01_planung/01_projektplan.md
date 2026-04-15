# 01 Projektplan – CRM-Migration

**Projekt:** Migration vtigerCRM  
**Datum:** 03.03.2026  
**Version:** 6.0  
**Autor:** Jann Neururer

---

## Ausgangslage

Der bestehende CRM-Server (`crmserver.sample.ch`) läuft auf einer veralteten CentOS 6.6 VM. Darauf betrieben wird vtigerCRM mit Apache 2.2, PHP 5.3 und MySQL 5.1 – alles seit Jahren nicht mehr aktualisiert. Der Auftrag lautet: Migration auf ein modernes System mit sauberer Trennung von Web- und Datenbankserver, aktuelle Softwarestände und erhöhter Sicherheit.

---

## Ziele

- Altsystem analysieren und dokumentieren
- Neue Zielumgebung aufbauen (zwei getrennte VMs)
- Daten und Applikation vollständig migrieren
- Ausfallzeit so gering wie möglich halten
- Sicherheit gegenüber IST-System verbessern

---

## Projektphasen und Meilensteine

| # | Phase | Aufgaben | Aufwand | Datum |
|---|-------|----------|---------|-------|
| 1 | Analyse | IST-System dokumentieren, Logs auswerten, Diagramm zeichnen | 1 Tag | 03.03.2026 |
| 2 | Planung | Projektplan, Variantenentscheid, Zielsystem definieren | 0.5 Tage | 04.03.2026 |
| 3 | Umgebung | Zwei VMs aufsetzen, Netzwerk konfigurieren, Snapshots | 1 Tag | 14.04.2026 |
| 4 | Zielsystem | Apache, PHP, MariaDB, DNS einrichten | 1 Tag | 06.03.2026 |
| 5 | Migration | Dateien und DB übertragen, Konfiguration anpassen | 1 Tag | 10.03.2026 |
| 6 | Tests & Abschluss | Testing, Monitoring, Backup, Deployment dokumentieren | 1 Tag | 11.03.2026 |

---

## Migrationsvarianten

Gemäss Auftrag wurden zwei Varianten evaluiert:

**Variante A – Migration auf neuste Vtiger-Version**  
- Vorteile: bekannte Software, Community, einfacher Einstieg  
- Nachteile: Vtiger neuere Versionen teilweise kostenpflichtig, Kompatibilität prüfen  

**Variante B – Wechsel auf alternatives Open-Source-ERP (z.B. Odoo)**  
- Vorteile: moderner, aktiv entwickelt  
- Nachteile: Datenmigration aufwändig, neues System lernen, höheres Risiko  

**Entscheid:** Variante A – Vtiger 6.1 auf neuem System. Der Aufwand bleibt überschaubar, die Daten bleiben kompatibel, und das Risiko ist tiefer. Vtiger 6.1 ist die letzte vollständig freie Version.

---

## Migrationsfenster

Das System wird Mo–Sa aktiv genutzt. Geplantes Migrationsfenster:

> **Samstagnacht, 22:00 – 04:00 Uhr**

In diesem Zeitfenster wird die finale Migration durchgeführt. Nutzer werden vorgängig informiert (siehe Kommunikationsplan).

---

## Kommunikationsplan

| Zeitpunkt | Massnahme |
|-----------|-----------|
| 1 Woche vor Migration | E-Mail an alle Nutzer: Ankündigung Wartungsfenster |
| 2 Tage vorher | Erinnerung per E-Mail |
| Am Migrationsabend | Kurzmeldung: System ab 22:00 nicht erreichbar |
| Nach Migration | Bestätigung: System wieder online, ggf. neue URL |

---

## Risiken

| Risiko | Wahrscheinlichkeit | Massnahme |
|--------|--------------------|-----------|
| Datenverlust bei Migration | tief | Backup vor Migration, Testlauf vorab |
| PHP-Kompatibilität | mittel | PHP 5.6 parallel installieren, testen |
| Netzwerkprobleme | tief | Snapshots, Rollback-Plan |
| Längerer Ausfall | tief | Migration vorab im Testbetrieb durchgespielt |

---

## Critical Path

```
IST-Analyse → Umgebung aufbauen → Zielsystem installieren → Migration → Test → Go-Live
```

Jede Phase ist Voraussetzung für die nächste. Engpass ist die Migrationsphase, da dort Daten und Applikation konsistent übertragen werden müssen.

---

## Zeitaufwand Schätzung

| Aufgabe | Geschätzter Aufwand |
|---------|---------------------|
| IST-Analyse | 4 Stunden |
| VM-Setup und Netzwerk | 3 Stunden |
| Webserver, PHP, MariaDB | 4 Stunden |
| DNS, SFTP, phpMyAdmin | 2 Stunden |
| Migration (Dateien + DB) | 3 Stunden |
| Testing und Monitoring | 3 Stunden |
| Backup und Deployment | 2 Stunden |
| Dokumentation | 3 Stunden |
| **Total** | **~24 Stunden** |
