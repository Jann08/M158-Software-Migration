# 07 MySQL / MariaDB Datenbankserver

**Autor:** Jann Neururer

---

## Ziel

MariaDB auf dem Datenbankserver (`crm-db`) installieren, absichern und für den Zugriff vom Webserver einrichten.

---

## Installation

```bash
sudo apt update
sudo apt install mariadb-server -y
```

Dienst prüfen:

```bash
sudo systemctl status mariadb
# ● mariadb.service - MariaDB 10.6.12 database server
#      Active: active (running)
```

---

## Absicherung mit mysql_secure_installation

```bash
sudo mysql_secure_installation
```

Folgende Optionen wurden gesetzt:

```
Enter current password for root (enter for none): [ENTER]
Set root password? [Y/n] Y
New password:
Remove anonymous users? [Y/n] Y
Disallow root login remotely? [Y/n] Y
Remove test database and access to it? [Y/n] Y
Reload privilege tables now? [Y/n] Y
```

---

## Datenbank und Benutzer erstellen

```bash
sudo mysql -u root -p
```

```sql
CREATE DATABASE vtiger CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE USER 'vtigeruser'@'10.10.20.10' IDENTIFIED BY 'V7!gSecure#2026';

GRANT ALL PRIVILEGES ON vtiger.* TO 'vtigeruser'@'10.10.20.10';

FLUSH PRIVILEGES;

EXIT;
```

Benutzer prüfen:

```sql
SELECT user, host FROM mysql.user;
-- vtigeruser | 10.10.20.10
-- root       | localhost
```

---

## Problem: Remote-Verbindung schlägt fehl

Beim Test der Verbindung vom Webserver aus:

```bash
mysql -h 10.10.20.11 -u vtigeruser -p vtiger
# ERROR 2003 (HY000): Can't connect to MySQL server on '10.10.20.11'
```

**Ursache prüfen:**

```bash
sudo cat /etc/mysql/mariadb.conf.d/50-server.cnf | grep bind
# bind-address = 127.0.0.1
```

MariaDB hört nur auf localhost.

**Lösung:**

```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

```ini
# bind-address = 127.0.0.1
bind-address = 0.0.0.0
```

```bash
sudo systemctl restart mariadb
```

Erneuter Test:

```bash
mysql -h 10.10.20.11 -u vtigeruser -p vtiger
# Welcome to the MariaDB monitor.
```

---

## Firewall

Zugriff auf Port 3306 nur vom Webserver erlauben:

```bash
sudo ufw allow OpenSSH
sudo ufw allow from 10.10.20.10 to any port 3306
sudo ufw enable
```

Status prüfen:

```bash
sudo ufw status
# Status: active
# 22/tcp                 ALLOW IN    Anywhere
# 3306                   ALLOW IN    10.10.20.10
```

---

## MariaDB-Konfiguration optimieren

```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

```ini
[mysqld]
# Zeichensatz
character-set-server = utf8
collation-server = utf8_general_ci

# Performance
innodb_buffer_pool_size = 512M
max_connections = 100
query_cache_size = 32M
query_cache_type = 1

# Logging (Slow Query für Optimierung)
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
```

```bash
sudo systemctl restart mariadb
```

---

## Test Verbindung vom Webserver

```bash
mysql -h crm-db.local -u vtigeruser -p vtiger
# Welcome to the MariaDB monitor.
# MariaDB [vtiger]>
```

Tabellen prüfen (nach Migration):

```sql
SHOW TABLES;
-- vtiger_users, vtiger_account, vtiger_contactdetails, ...
```

---

## Ergebnis

- MariaDB 10.6 läuft stabil auf `crm-db`
- Remote-Zugriff vom Webserver funktioniert
- Zugriff auf Webserver-IP eingeschränkt (kein öffentlicher DB-Zugang)
- Firewall klar definiert
- Konfiguration für Performance und Sicherheit optimiert
