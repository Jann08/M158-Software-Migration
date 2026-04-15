# 10 WebApp / DB-Migration

**Autor:** Jann Neururer

---

## Ziel

vtigerCRM vollständig vom Altsystem auf das neue System migrieren inklusive Anwendungsdateien, Datenbank und Konfiguration. Die Migration soll reproduzierbar und so dokumentiert sein, dass sie bei Bedarf wiederholt werden kann.

---

## Übersicht Migrationsvorgehen

1. Backup auf dem Altsystem erstellen
2. Datenbankexport (mysqldump)
3. Dateien übertragen (rsync/scp)
4. Datenbank importieren
5. Konfiguration anpassen (Datenbankverbindung)
6. Berechtigungen setzen
7. Funktionstest

---

## Schritt 1: Backup Altsystem

Vor jeder Migration zuerst sichern:

```bash
# Auf dem Altsystem (CentOS 6.6):
mysqldump -u admin -p vtigercrm > /tmp/vtigercrm_backup_$(date +%Y%m%d).sql
tar -czf /tmp/vtigercrm_files_$(date +%Y%m%d).tar.gz /var/www/html/vtigercrm/
```

---

## Schritt 2: Datenbankexport vom Altsystem

```bash
# Auf dem Altsystem:
mysqldump -u admin -p \
  --single-transaction \
  --routines \
  --triggers \
  vtigercrm > /tmp/vtigercrm_export.sql
```

Exportdatei prüfen:

```bash
wc -l /tmp/vtigercrm_export.sql
# 48231 /tmp/vtigercrm_export.sql

head -5 /tmp/vtigercrm_export.sql
# -- MySQL dump 10.13  Distrib 5.1.73
# -- Host: localhost    Database: vtigercrm
```

---

## Schritt 3: Dateien übertragen

```bash
# Vom Host-PC oder neuen Webserver aus:
scp -O -P 2222 \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  root@localhost:/tmp/vtigercrm_export.sql \
  administrator@192.168.42.135:/tmp/

scp -O -P 2222 -r \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  root@localhost:/var/www/html/vtigercrm \
  administrator@192.168.42.135:/var/www/html/
```

---

## Schritt 4: Datenbank importieren

```bash
# Auf dem Webserver:
mysql -h 192.168.42.134 -u vtigeruser -p vtiger < /tmp/vtigercrm_export.sql
```

Importierte Tabellen prüfen:

```bash
mysql -h 192.168.42.134 -u vtigeruser -p vtiger -e "SHOW TABLES;" | wc -l
# 147
```

Wichtige Tabellen manuell prüfen:

```bash
mysql -h 192.168.42.134 -u vtigeruser -p vtiger -e "SELECT count(*) FROM vtiger_users;"
# +----------+
# | count(*) |
# +----------+
# |        3 |
# +----------+
```

---

## Schritt 5: Konfiguration anpassen

Die vtigerCRM-Konfigurationsdatei zeigt noch auf die alte MySQL-Instanz. Anpassen auf neuen MariaDB-Server:

```bash
sudo nano /var/www/html/vtigercrm/config.inc.php
```

Folgende Werte ändern:

```php
// Alte Werte (Altsystem):
// $dbconfig['db_server'] = 'localhost';
// $dbconfig['db_username'] = 'root';
// $dbconfig['db_name'] = 'vtigercrm';

// Neue Werte:
$dbconfig['db_server'] = '192.168.42.134';
$dbconfig['db_port'] = '3306';
$dbconfig['db_username'] = 'vtigeruser';
$dbconfig['db_password'] = '';
$dbconfig['db_name'] = 'vtiger';
```

Ausserdem den `site_URL` anpassen:

```php
$site_URL = 'http://crm.local';
$root_directory = '/var/www/html/vtigercrm/';
```

---

## Schritt 6: Berechtigungen setzen

```bash
sudo chown -R www-data:www-data /var/www/html/vtigercrm
sudo find /var/www/html/vtigercrm -type d -exec chmod 755 {} \;
sudo find /var/www/html/vtigercrm -type f -exec chmod 644 {} \;

# Cache-Verzeichnisse brauchen Schreibrechte:
sudo chmod -R 775 /var/www/html/vtigercrm/cache
sudo chmod -R 775 /var/www/html/vtigercrm/storage
sudo chmod -R 775 /var/www/html/vtigercrm/user_privileges
```

---

## Problem: Seite lädt, aber Login funktioniert nicht

Nach der Migration erschien die vtigerCRM-Loginseite, aber nach dem Einloggen kam ein Datenbankfehler.

**Fehler im Log:**

```
Unknown database 'vtigercrm' on line 42
```

**Ursache:** In `config.inc.php` war noch der alte Datenbankname `vtigercrm` statt `vtiger` eingetragen (hatte die DB auf dem neuen System `vtiger` genannt).

**Lösung:** `db_name` in `config.inc.php` auf `vtiger` korrigiert. Danach funktionierte der Login.

---

## Schritt 7: Funktionstest

```bash
curl -I http://crm.local
# HTTP/1.1 302 Found
# Location: http://crm.local/index.php?module=Users&action=Login
```

→ Redirect zum Login: vtigerCRM läuft.

Login im Browser:
- URL: `http://crm.local`
- Benutzer: `admin`
- Passwort: (aus Altsystem übernommen)

Login erfolgreich, Dashboard lädt, Kontakte und Accounts sind vorhanden.

---

## Migrationsskript (automatisiert)

Für die finale Migration wurde ein Bash-Skript erstellt, das alle Schritte automatisch durchführt:

```bash
#!/bin/bash
# migrate.sh – vtigerCRM Migration

set -e

ALTSYSTEM_IP="10.0.2.10"
ALTSYSTEM_PORT="2222"
DB_HOST="192.168.42.134"
DB_USER="vtigeruser"
DB_NAME="vtiger"
WEB_DIR="/var/www/html/vtigercrm"
BACKUP_DIR="/tmp/migration_$(date +%Y%m%d_%H%M)"

mkdir -p "$BACKUP_DIR"

echo "=== 1. Datenbankexport vom Altsystem ==="
ssh -p $ALTSYSTEM_PORT \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  root@localhost \
  "mysqldump -u root -proot vtigercrm" > "$BACKUP_DIR/vtigercrm.sql"

echo "=== 2. Dateien übertragen ==="
rsync -avz \
  -e "ssh -p $ALTSYSTEM_PORT -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa" \
  root@localhost:/var/www/html/vtigercrm/ \
  "$WEB_DIR/"

echo "=== 3. Datenbank importieren ==="
mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME < "$BACKUP_DIR/vtigercrm.sql"

echo "=== 4. Berechtigungen setzen ==="
chown -R www-data:www-data "$WEB_DIR"
find "$WEB_DIR" -type d -exec chmod 755 {} \;
find "$WEB_DIR" -type f -exec chmod 644 {} \;
chmod -R 775 "$WEB_DIR/cache" "$WEB_DIR/storage" "$WEB_DIR/user_privileges"

echo "=== Migration abgeschlossen ==="
```

---

## Kommunikation mit Benutzern

Vor der finalen Migration wurden alle CRM-Nutzer informiert:

**E-Mail (1 Woche vorher):**
> Betreff: Wartungsfenster CRM-System – Samstag 14.03.2026, 22:00–04:00 Uhr  
> Das CRM-System wird in der Nacht von Samstag auf Sonntag auf einen neuen Server migriert. Das System ist in dieser Zeit nicht erreichbar. Die URL und Zugangsdaten bleiben unverändert.

**E-Mail (nach Migration):**
> Das CRM-System ist wieder vollständig verfügbar. Bitte meldet euch bei Problemen.

---

## Ergebnis

- Alle Tabellen (147) erfolgreich importiert
- Benutzerdaten übereinstimmend geprüft (3 User)
- vtigerCRM läuft auf neuem System ohne Fehler
- Migration ist als Skript automatisiert und reproduzierbar
