# Systemdokumentation: CRM-Server (CentOS 6.6)

## 1. Allgemeine Informationen
- **Hostname**: crmserver.sample.ch
- **IP-Adresse**: 10.0.2.10/24
- **Betriebssystem**: CentOS 6.6 Final (64-bit)
- **Kernel-Version**: 2.6.32-504.el6.x86_64
- **Letzter Neustart**: 10. März 2026, 15:56 Uhr (aus `uptime` / System.log)
- **Virtualisierung**: KVM Hypervisor (virtuelle Maschine)

## 2. Hardware
- **CPU**: 13th Gen Intel(R) Core(TM) i7-1370P, 2 virtuelle Kerne (aus `lscpu`)
- **RAM**: Gesamt: 1956 MB | Frei: 1685 MB (~86%) | Cache: 86 MB (aus `free -m`)
- **Festplatten** (aus `df -h`):
  - `/` (Root): 27 GB gesamt, 2.3 GB belegt (10%)
  - `/boot`: 477 MB gesamt, 33 MB belegt (8%)
  - `/dev/sda` gesamt: 33.1 GB

## 3. Netzwerk
- **Schnittstellen**:
  - `eth0`: 10.0.2.10/24 (MAC: 08:00:27:83:76:5E)
  - `lo`: 127.0.0.1/8
- **Gateway**: 10.0.2.2
- **DNS-Server**: 8.8.8.8, 8.8.4.4
- **Hosts-Eintrag**: `10.0.2.10 crmserver crmserver.sample.ch`
- **Firewall-Regeln** (`iptables -L -n -v`):

```
Chain INPUT (policy ACCEPT)
ACCEPT     all  --  anywhere      anywhere     state ESTABLISHED,RELATED
ACCEPT     icmp --  anywhere      anywhere
ACCEPT     all  --  anywhere      anywhere
ACCEPT     tcp  --  anywhere      anywhere     state NEW tcp dpt:ssh
ACCEPT     tcp  --  anywhere      anywhere     tcp dpt:http
ACCEPT     tcp  --  anywhere      anywhere     tcp dpt:8181
REJECT     all  --  anywhere      anywhere     reject-with icmp-host-prohibited
```

## 4. Dienste
| Dienst    | Status  | Port     | Beschreibung                  |
|-----------|---------|----------|-------------------------------|
| sshd      | running | 22       | SSH-Server                    |
| httpd     | running | 80, 443  | Apache Webserver              |
| mysqld    | running | 3306     | MySQL Datenbank               |
| postfix   | running | 25       | Mail Transfer Agent (SMTP)    |
| crond     | running | –        | Cron-Daemon                   |
| cupsd     | running | 631      | Druckerdienst (nur localhost) |
| rpcbind   | running | 111      | RPC Portmapper                |
| abrtd     | running | –        | Automatisches Bug-Reporting   |

## 5. Datenbank
- **Typ**: **MySQL** *(hervorgehoben)*
- **Version**: MySQL 5.1.73
- **PID**: mysqld läuft mit PID 1442 (Wrapper: mysqld_safe PID 1337)
- **Datenbanken**:
  - `information_schema`
  - `mysql`
  - `test`
  - `vtigercrm`
- **Konfigurationsdatei**: `/etc/my.cnf` (Suchreihenfolge: `/etc/mysql/my.cnf` → `/etc/my.cnf` → `~/.my.cnf`)
- **Log-Datei**: `/var/log/mysqld.log`
- **Backup-Status**: Nicht dokumentiert – keine Backup-Konfiguration in den Logs ersichtlich

## 6. Wichtige Konfigurationsdateien
- `/etc/sysconfig/network-scripts/ifcfg-eth0`: Netzwerkkonfiguration (statische IP)
- `/etc/sysconfig/iptables`: Firewall-Regeln
- `/etc/resolv.conf`: DNS-Konfiguration
- `/etc/hosts`: Hostname-Auflösung
- `/etc/fstab`: Dateisystem-Tabelle
- `/etc/my.cnf`: MySQL-Konfiguration
- `/var/log/mysqld.log`: MySQL-Datenbank-Log
- `/var/log/messages`: System-Logs

## 7. Installierte Schlüssel-Anwendungen
- **CRM-Software**: vtigerCRM (Datenbank `vtigercrm` vorhanden)
- **Webserver**: Apache 2.2.15 (`httpd`)
- **Datenbank**: MySQL 5.1.73 (`mysql-server`)
- **PHP**: PHP 5.3.3 – Module: `php-cli`, `php-common`, `php-gd`, `php-mysql`, `php-pdo`, `php-xml`, `php-pear`
- **Java**: OpenJDK 1.6.0 und 1.7.0
- **Tomcat**: Tomcat 6.0.24
- **Sonstiges**: PostgreSQL 8.4.20 (installiert, aber nicht als Dienst aktiv)

## 8. Storage-Konfiguration (LVM)
| Volume                              | Grösse    | Typ   | Mountpoint |
|-------------------------------------|-----------|-------|------------|
| `/dev/mapper/vg_crmserver-lv_root`  | 29.2 GB   | ext4  | `/`        |
| `/dev/mapper/vg_crmserver-lv_swap`  | 3305 MB   | swap  | –          |
| `/dev/sda1`                         | 477 MB    | ext4  | `/boot`    |

## 9. Offene Netzwerk-Ports
| Port        | Protokoll | Dienst     | Details                    |
|-------------|-----------|------------|----------------------------|
| 22          | TCP       | sshd       | SSH (alle Schnittstellen)  |
| 25          | TCP       | postfix    | SMTP (nur localhost)       |
| 80          | TCP       | httpd      | HTTP (alle Schnittstellen) |
| 111         | TCP/UDP   | rpcbind    | RPC Portmapper             |
| 443         | TCP       | httpd      | HTTPS (alle Schnittstellen)|
| 631         | TCP/UDP   | cupsd      | Drucker (nur localhost)    |
| 3306        | TCP       | mysqld     | MySQL (alle Schnittstellen)|
| 750         | UDP       | rpcbind    | RPC                        |
| 42325/47748 | UDP       | rpc.statd  | NFS Status                 |

## 10. Notizen / Besonderheiten

### Autostart-Dienste (Runlevel 3)
`httpd`, `mysqld`, `sshd`, `postfix`, `crond`, `iptables`, `network`, `acpid`

### YUM / Repositories
- Aktive Repos: `base`, `c6-media`, `extras`, `updates`
- `c6-media` (lokales DVD/CD-ROM): 6'518 Pakete verfügbar
- Internet-Repositories nicht erreichbar (DNS-Problem bei `mirrorlist.centos.org`)

### System-Log Auffälligkeiten
- `10.03.2026 15:56:50` – System gestartet (Kernel-Boot)
- `10.03.2026 15:57:01` – `automount`: NIS+ Tabelle `auto.master` nicht gefunden
- MySQL-Logs zeigen mehrere normale Shutdowns und Starts zwischen 02.03. und 10.03.2026

### Sicherheitshinweise
- **MySQL Port 3306** ist auf allen Schnittstellen offen → mögliches Sicherheitsrisiko
- **Apache** hört auf allen Schnittstellen (Port 80 und 443)
- **Port 8181** in der Firewall erlaubt – Verwendungszweck unbekannt (evtl. Tomcat?)
- **Keine Backup-Strategie** dokumentiert
- **vtigerCRM-Konfiguration** nicht vollständig erfasst