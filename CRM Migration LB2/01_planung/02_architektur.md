# 02 Architekturdiagramm IST / SOLL

**Datum:** 03.03.2026  
**Autor:** Jann Neururer

---

## IST-Analyse

### Überblick

Das bestehende System läuft als einzelne virtuelle Maschine auf einem lokalen Host. Alle Dienste – Webserver, Applikation und Datenbank – sind auf derselben Maschine installiert. Zugriff von aussen erfolgt über Port-Forwarding.

### Systemdaten IST

| Eigenschaft | Wert |
|-------------|------|
| Hostname | `crmserver.sample.ch` |
| IP-Adresse | `10.0.2.10/24` |
| Gateway | `10.0.2.2` |
| DNS | `8.8.8.8`, `8.8.4.4` |
| Betriebssystem | CentOS 6.6 Final (64-bit) |
| Kernel | `2.6.32-504.el6.x86_64` |
| Virtualisierung | KVM |
| CPU | Intel Core i7-1370P, 2 vCores |
| RAM | 1956 MB gesamt, ~1685 MB frei |
| Festplatte | 33.1 GB (`/dev/sda`), Root: 27 GB (10% belegt) |

### Installierte Software

| Komponente | Version | Status |
|------------|---------|--------|
| Apache httpd | 2.2.15 | End-of-Life |
| PHP | 5.3.3 | End-of-Life |
| MySQL | 5.1.73 | End-of-Life |
| OpenSSH | 5.3p1 | veraltet |
| Postfix | 2.6.6 | aktiv |
| Tomcat | 6.0.24 | installiert, kaum genutzt |
| PostgreSQL | 8.4.20 | installiert, kein aktiver Dienst |
| vtigerCRM | unbekannte Version | aktiv |
| CentOS | 6.6 | End-of-Life (2020) |

### Datenbank IST

Datenbanktyp: **MySQL 5.1.73**  
PID: 1442 (Wrapper: mysqld_safe PID 1337)  
Socket: `/var/lib/mysql/mysql.sock`  
Port: **3306 (offen auf allen Interfaces – Sicherheitsrisiko)**  
Konfiguration: `/etc/my.cnf`  
Log: `/var/log/mysqld.log`

Vorhandene Datenbanken:
- `information_schema`
- `mysql`
- `test` ← sollte gelöscht werden
- `vtigercrm` ← produktive Datenbank

Zentrale Tabellen in `vtigercrm`:
- `vtiger_users`
- `vtiger_account`
- `vtiger_contactdetails`
- `vtiger_leaddetails`
- `vtiger_troubletickets`
- `vtiger_crmentity`

**Datenbankgrösse prüfen:**
```sql
SELECT table_schema AS 'Datenbank',
  ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Grösse (MB)'
FROM information_schema.tables
WHERE table_schema = 'vtigercrm'
GROUP BY table_schema;
```

### Netzwerk und Firewall IST

Aktive Schnittstellen:
- `eth0`: `10.0.2.10/24` (MAC: `08:00:27:83:76:5E`)
- `lo`: `127.0.0.1/8`

Offene Ports:

| Port | Protokoll | Dienst |
|------|-----------|--------|
| 22 | TCP | SSH |
| 25 | TCP | Postfix (nur localhost) |
| 80 | TCP | Apache HTTP |
| 443 | TCP | Apache HTTPS |
| 631 | TCP/UDP | CUPS (nur localhost) |
| 3306 | TCP | MySQL (alle Interfaces!) |
| 111 | TCP/UDP | RPC |
| 8181 | TCP | unbekannt (Firewall-Regel vorhanden) |

Auffälligkeit: Port 3306 ist auf `0.0.0.0` gebunden, d.h. von aussen erreichbar – ein klares Sicherheitsrisiko.

### Sicherheitsbewertung IST

- Gesamtes System End-of-Life (CentOS 6.6 seit Nov. 2020 ohne Support)
- Schwaches Root-Passwort (`123456`)
- MySQL Port öffentlich erreichbar
- Keine dokumentierte Backup-Strategie
- Monolithische Architektur: Kompromittierung einer Komponente betrifft alle
- `test`-Datenbank vorhanden (MySQL-Standard, sollte entfernt werden)
- Apache Directory-Listing möglicherweise aktiv

---

## Architekturdiagramm IST

```
┌─────────────────────────────────────────┐
│           Host (Hypervisor KVM)         │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │    VM: crmserver.sample.ch       │   │
│  │    IP: 10.0.2.10                 │   │
│  │    OS: CentOS 6.6                │   │
│  │                                  │   │
│  │  ┌──────────┐  ┌──────────────┐  │   │
│  │  │ Apache   │  │   MySQL      │  │   │
│  │  │ 2.2.15   │  │   5.1.73     │  │   │
│  │  │ Port 80  │  │   Port 3306  │  │   │
│  │  └────┬─────┘  └──────────────┘  │   │
│  │       │                          │   │
│  │  ┌────▼──────────────────────┐   │   │
│  │  │   vtigerCRM               │   │   │
│  │  │   PHP 5.3.3               │   │   │
│  │  │   /var/www/html/vtigercrm │   │   │
│  │  └───────────────────────────┘   │   │
│  └──────────────────────────────────┘   │
│                                         │
│  Port Forwarding:                       │
│  :8181 → :80 (HTTP)                    │
│  :2222 → :22 (SSH)                     │
└─────────────────────────────────────────┘
         │
    Benutzer (Browser/SSH)
```

---

## SOLL-Architektur

### Konzept

Das neue System trennt Web- und Datenbankserver auf zwei separate VMs. Das erhöht die Sicherheit (DB nicht direkt öffentlich), verbessert die Wartbarkeit und ermöglicht spätere Skalierung (z.B. zusätzliche Webserver).

### Systemdaten SOLL

| Komponente | Hostname | IP-Adresse | Rolle |
|------------|----------|------------|-------|
| Webserver | `crmweb` | `10.10.20.10` | Apache, PHP 5.6, vtigerCRM 6.1 |
| Datenbankserver | `crm-db` | `10.10.20.11` | MariaDB (aktuell) |

**Netzwerk:**
- Host-only Netzwerk für interne Kommunikation (Web ↔ DB): `10.10.20.0/24`
- NAT-Interface für Internetzugang (Updates, Downloads)

**DNS/Hosts:**
- `crm.local` → `10.10.20.10`
- `crm-db.local` → `10.10.20.11`

### Software SOLL

| Komponente | Version | Begründung |
|------------|---------|------------|
| Ubuntu Server | 22.04 LTS | Langzeit-Support bis 2027 |
| Apache | 2.4.x (aktuell) | Sicherheitsupdates, aktiv gewartet |
| PHP | 5.6 (kompatibel mit Vtiger 6.1) | Kompatibilitätsanforderung |
| MariaDB | 10.6.x | Drop-in-Ersatz für MySQL, aktiv |
| vtigerCRM | 6.1 → schrittweise auf aktuelle Version | letzte vollständig freie Version als Startpunkt |

---

## Architekturdiagramm SOLL

```
┌─────────────────────────────────────────────────────────┐
│                   Host (VMware)                          │
│                                                          │
│  ┌─────────────────────────┐  ┌────────────────────────┐ │
│  │   VM: crmweb            │  │   VM: crm-db           │ │
│  │   IP: 10.10.20.10       │  │   IP: 10.10.20.11      │ │
│  │   OS: Ubuntu 22.04      │  │   OS: Ubuntu 22.04     │ │
│  │                         │  │                        │ │
│  │  ┌─────────────────┐    │  │  ┌──────────────────┐  │ │
│  │  │ Apache 2.4      │    │  │  │ MariaDB 10.6     │  │ │
│  │  │ Port 80/443     │    │  │  │ Port 3306        │  │ │
│  │  └────────┬────────┘    │  │  │ (nur intern)     │  │ │
│  │           │             │  │  └──────────────────┘  │ │
│  │  ┌────────▼────────┐    │  │                        │ │
│  │  │ vtigerCRM 6.1   │────┼──┼──► DB-Verbindung      │ │
│  │  │ PHP 5.6         │    │  │   10.10.20.11:3306     │ │
│  │  └─────────────────┘    │  │                        │ │
│  │  ┌─────────────────┐    │  │  ┌──────────────────┐  │ │
│  │  │ UFW Firewall    │    │  │  │ UFW Firewall     │  │ │
│  │  │ Port 22, 80     │    │  │  │ Port 22 (SSH)    │  │ │
│  │  └─────────────────┘    │  │  │ Port 3306        │  │ │
│  └─────────────────────────┘  │  │ (nur von .10)    │  │ │
│                                │  └──────────────────┘  │ │
│                                └────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
         │
    Benutzer (http://crm.local)
```

---

## Vergleich IST vs. SOLL

| Bereich | IST | SOLL |
|---------|-----|------|
| Architektur | Monolithisch (1 VM) | Getrennt (2 VMs) |
| Betriebssystem | CentOS 6.6 (EOL) | Ubuntu 22.04 LTS |
| Webserver | Apache 2.2.15 (EOL) | Apache 2.4.x |
| PHP | 5.3.3 (EOL) | 5.6 (kompatibel) |
| Datenbank | MySQL 5.1.73 (EOL) | MariaDB 10.6 |
| DB-Zugriff | öffentlich (0.0.0.0:3306) | nur intern (10.10.20.10) |
| Passwörter | schwach (123456) | sicher |
| Firewall | teilweise, Lücken | UFW klar definiert |
| Backups | keine | automatisiert |
| Monitoring | keines | Cronjob + Logs |
| Skalierbarkeit | keine | vorbereitet (LB) |
