# 10 WebApp / DB-Migration

**Autor:** Jann Neururer

---

## Ziel

vtigerCRM vollständig vom Altsystem auf das neue System migrieren inklusive Anwendungsdateien, Datenbank und Konfiguration. Danach wird vtigerCRM schrittweise auf die neueste verfügbare Version aktualisiert.

---

## Übersicht Migrationsvorgehen

1. Backup auf dem Altsystem erstellen
2. Datenbankexport (mysqldump)
3. Dateien übertragen (rsync/scp)
4. Datenbank importieren
5. Konfiguration anpassen (Datenbankverbindung)
6. Berechtigungen setzen
7. Funktionstest
8. vtigerCRM schrittweise aktualisieren

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
  administrator@10.10.20.10:/tmp/

scp -O -P 2222 -r \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  root@localhost:/var/www/html/vtigercrm \
  administrator@10.10.20.10:/var/www/html/
```

---

## Schritt 4: Datenbank importieren

```bash
# Auf dem Webserver:
mysql -h 10.10.20.11 -u vtigeruser -p vtiger < /tmp/vtigercrm_export.sql
```

Importierte Tabellen prüfen:

```bash
mysql -h 10.10.20.11 -u vtigeruser -p vtiger -e "SHOW TABLES;" | wc -l
# 147
```

Wichtige Tabellen manuell prüfen:

```bash
mysql -h 10.10.20.11 -u vtigeruser -p vtiger -e "SELECT count(*) FROM vtiger_users;"
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
$dbconfig['db_server'] = '10.10.20.11';
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
DB_HOST="10.10.20.11"
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

## Schritt 8: vtigerCRM schrittweise aktualisieren

vtigerCRM kann nicht direkt von Version 6.1 auf die neueste Version gesprungen werden. Jedes Minor-Release muss einzeln durchgeführt werden, da der eingebaute Migrate-Wizard jeweils nur den nächsten Schritt kennt. Das Grundprinzip ist bei jeder Version identisch:

1. Backup der aktuellen Installation (DB + Dateien)
2. ZIP von SourceForge herunterladen
3. ZIP entpacken und Dateien ins Web-Verzeichnis kopieren
4. Berechtigungen setzen
5. Im Browser `http://crm.local/migrate` aufrufen und den Wizard abschliessen

**Hinweis zu PHP:** Ältere vtigerCRM-Versionen (6.x) laufen mit PHP 5.6. Ab Version 7.x wird mindestens PHP 7.2 benötigt. Der PHP-Wechsel ist beim jeweiligen Versions-Upgrade dokumentiert.
Ich werde nur bist zu 7.3 updaten da dies die letzte voll Open Source version ist.

---

### Update 6.1 → 6.2

**Backup vor dem Update:**

```bash
mysqldump -h 10.10.20.11 -u vtigeruser -p vtiger > /tmp/vtiger_before_62.sql
sudo tar -czf /tmp/vtiger_files_before_62.tar.gz /var/www/html/vtigercrm/
```

**Paket herunterladen und entpacken:**

```bash
cd /tmp
wget https://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%206.2.0/Core%20Product/vtigercrm6.2.0.zip
unzip vtigercrm6.2.0.zip
```

**Dateien ins Web-Verzeichnis kopieren:**

```bash
sudo cp -r /tmp/vtigercrm/* /var/www/html/vtigercrm/
```

**Berechtigungen setzen:**

```bash
sudo chown -R www-data:www-data /var/www/html/vtigercrm
sudo find /var/www/html/vtigercrm -type d -exec chmod 755 {} \;
sudo find /var/www/html/vtigercrm -type f -exec chmod 644 {} \;
sudo chmod -R 775 /var/www/html/vtigercrm/cache
sudo chmod -R 775 /var/www/html/vtigercrm/storage
sudo chmod -R 775 /var/www/html/vtigercrm/user_privileges
```

**Migrate-Wizard aufrufen:**

Im Browser öffnen: `http://crm.local/migrate`

Der Wizard erkennt die bestehende Version automatisch und führt die notwendigen Datenbankschemas-Anpassungen durch. Alle Schritte mit „Next" bestätigen bis „Finish".

**Version prüfen:**

Nach dem Wizard erscheint in vtigerCRM unter `Admin → CRM Settings → Configuration`: Version 6.2.0

---

### Update 6.2 → 6.3

**Backup:**

```bash
mysqldump -h 10.10.20.11 -u vtigeruser -p vtiger > /tmp/vtiger_before_63.sql
sudo tar -czf /tmp/vtiger_files_before_63.tar.gz /var/www/html/vtigercrm/
```

**Paket herunterladen:**

```bash
cd /tmp
wget https://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%206.3.0/Core%20Product/vtigercrm6.3.0.zip
unzip vtigercrm6.3.0.zip
```

**Dateien kopieren:**

```bash
sudo cp -r /tmp/vtigercrm/* /var/www/html/vtigercrm/
```

**Berechtigungen:**

```bash
sudo chown -R www-data:www-data /var/www/html/vtigercrm
sudo find /var/www/html/vtigercrm -type d -exec chmod 755 {} \;
sudo find /var/www/html/vtigercrm -type f -exec chmod 644 {} \;
sudo chmod -R 775 /var/www/html/vtigercrm/cache
sudo chmod -R 775 /var/www/html/vtigercrm/storage
sudo chmod -R 775 /var/www/html/vtigercrm/user_privileges
```

**Migrate-Wizard:**

```
http://crm.local/migrate
```

Alle Schritte abschliessen. Version 6.3.0 erscheint in den Admin-Settings.

---

### Update 6.3 → 6.4

**Backup:**

```bash
mysqldump -h 10.10.20.11 -u vtigeruser -p vtiger > /tmp/vtiger_before_64.sql
sudo tar -czf /tmp/vtiger_files_before_64.tar.gz /var/www/html/vtigercrm/
```

**Paket herunterladen:**

```bash
cd /tmp
wget https://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%206.4.0/Core%20Product/vtigercrm6.4.0.zip
unzip vtigercrm6.4.0.zip
```

**Dateien kopieren + Berechtigungen:**

```bash
sudo cp -r /tmp/vtigercrm/* /var/www/html/vtigercrm/
sudo chown -R www-data:www-data /var/www/html/vtigercrm
sudo find /var/www/html/vtigercrm -type d -exec chmod 755 {} \;
sudo find /var/www/html/vtigercrm -type f -exec chmod 644 {} \;
sudo chmod -R 775 /var/www/html/vtigercrm/cache /var/www/html/vtigercrm/storage /var/www/html/vtigercrm/user_privileges
```

**Migrate-Wizard:**

```
http://crm.local/migrate
```

---

### Update 6.4 → 6.5

**Backup:**

```bash
mysqldump -h 10.10.20.11 -u vtigeruser -p vtiger > /tmp/vtiger_before_65.sql
sudo tar -czf /tmp/vtiger_files_before_65.tar.gz /var/www/html/vtigercrm/
```

**Paket herunterladen:**

```bash
cd /tmp
wget https://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%206.5.0/Core%20Product/vtigercrm6.5.0.zip
unzip vtigercrm6.5.0.zip
```

**Dateien kopieren + Berechtigungen:**

```bash
sudo cp -r /tmp/vtigercrm/* /var/www/html/vtigercrm/
sudo chown -R www-data:www-data /var/www/html/vtigercrm
sudo find /var/www/html/vtigercrm -type d -exec chmod 755 {} \;
sudo find /var/www/html/vtigercrm -type f -exec chmod 644 {} \;
sudo chmod -R 775 /var/www/html/vtigercrm/cache /var/www/html/vtigercrm/storage /var/www/html/vtigercrm/user_privileges
```

**Migrate-Wizard:**

```
http://crm.local/migrate
```

---

### Vorbereitung für 7.x: PHP-Upgrade

Ab vtigerCRM 7.0 wird PHP 5.6 nicht mehr unterstützt. Vor dem Update auf 7.0 muss PHP auf 7.2 gewechselt werden.

**PHP 7.2 installieren und aktivieren:**

```bash
sudo apt install php7.2 libapache2-mod-php7.2 \
  php7.2-mysql php7.2-gd php7.2-curl php7.2-xml \
  php7.2-mbstring php7.2-zip php7.2-soap php7.2-imap php7.2-json -y

sudo a2dismod php5.6
sudo a2enmod php7.2
sudo update-alternatives --set php /usr/bin/php7.2
sudo systemctl restart apache2
```

PHP-Version prüfen:

```bash
php -v
# PHP 7.2.x
```

---

### Update 6.5 → 7.0

**Backup:**

```bash
mysqldump -h 10.10.20.11 -u vtigeruser -p vtiger > /tmp/vtiger_before_70.sql
sudo tar -czf /tmp/vtiger_files_before_70.tar.gz /var/www/html/vtigercrm/
```

**Paket herunterladen:**

```bash
cd /tmp
wget https://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%207.0.0/Core%20Product/vtigercrm7.0.0.zip
unzip vtigercrm7.0.0.zip
```

**Dateien kopieren + Berechtigungen:**

```bash
sudo cp -r /tmp/vtigercrm/* /var/www/html/vtigercrm/
sudo chown -R www-data:www-data /var/www/html/vtigercrm
sudo find /var/www/html/vtigercrm -type d -exec chmod 755 {} \;
sudo find /var/www/html/vtigercrm -type f -exec chmod 644 {} \;
sudo chmod -R 775 /var/www/html/vtigercrm/cache /var/www/html/vtigercrm/storage /var/www/html/vtigercrm/user_privileges
```

**Migrate-Wizard:**

```
http://crm.local/migrate
```

Der Wizard migriert auch das Datenbankschema auf das neue Format. Dieser Schritt dauert etwas länger.

---

### Update 7.0 → 7.1

**Backup:**

```bash
mysqldump -h 10.10.20.11 -u vtigeruser -p vtiger > /tmp/vtiger_before_71.sql
sudo tar -czf /tmp/vtiger_files_before_71.tar.gz /var/www/html/vtigercrm/
```

**Paket herunterladen:**

```bash
cd /tmp
wget https://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%207.1.0/Core%20Product/vtigercrm7.1.0.zip
unzip vtigercrm7.1.0.zip
```

**Dateien kopieren + Berechtigungen:**

```bash
sudo cp -r /tmp/vtigercrm/* /var/www/html/vtigercrm/
sudo chown -R www-data:www-data /var/www/html/vtigercrm
sudo find /var/www/html/vtigercrm -type d -exec chmod 755 {} \;
sudo find /var/www/html/vtigercrm -type f -exec chmod 644 {} \;
sudo chmod -R 775 /var/www/html/vtigercrm/cache /var/www/html/vtigercrm/storage /var/www/html/vtigercrm/user_privileges
```

**Migrate-Wizard:**

```
http://crm.local/migrate
```

---

### Update 7.1 → 7.2

**Backup:**

```bash
mysqldump -h 10.10.20.11 -u vtigeruser -p vtiger > /tmp/vtiger_before_72.sql
sudo tar -czf /tmp/vtiger_files_before_72.tar.gz /var/www/html/vtigercrm/
```

**Paket herunterladen:**

```bash
cd /tmp
wget https://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%207.2.0/Core%20Product/vtigercrm7.2.0.zip
unzip vtigercrm7.2.0.zip
```

**Dateien kopieren + Berechtigungen:**

```bash
sudo cp -r /tmp/vtigercrm/* /var/www/html/vtigercrm/
sudo chown -R www-data:www-data /var/www/html/vtigercrm
sudo find /var/www/html/vtigercrm -type d -exec chmod 755 {} \;
sudo find /var/www/html/vtigercrm -type f -exec chmod 644 {} \;
sudo chmod -R 775 /var/www/html/vtigercrm/cache /var/www/html/vtigercrm/storage /var/www/html/vtigercrm/user_privileges
```

**Migrate-Wizard:**

```
http://crm.local/migrate
```

---

### Update 7.2 → 7.3 (neueste Open-Source-Version)

**Backup:**

```bash
mysqldump -h 10.10.20.11 -u vtigeruser -p vtiger > /tmp/vtiger_before_73.sql
sudo tar -czf /tmp/vtiger_files_before_73.tar.gz /var/www/html/vtigercrm/
```

**Paket herunterladen:**

```bash
cd /tmp
wget https://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%207.3.0/Core%20Product/vtigercrm7.3.0.zip
unzip vtigercrm7.3.0.zip
```

**Dateien kopieren + Berechtigungen:**

```bash
sudo cp -r /tmp/vtigercrm/* /var/www/html/vtigercrm/
sudo chown -R www-data:www-data /var/www/html/vtigercrm
sudo find /var/www/html/vtigercrm -type d -exec chmod 755 {} \;
sudo find /var/www/html/vtigercrm -type f -exec chmod 644 {} \;
sudo chmod -R 775 /var/www/html/vtigercrm/cache /var/www/html/vtigercrm/storage /var/www/html/vtigercrm/user_privileges
```

**Migrate-Wizard:**

```
http://crm.local/migrate
```

Alle Wizard-Schritte abschliessen. Version 7.3.0 wird in den Admin-Settings angezeigt.

---

## Upgrade-Übersicht

| Von | Nach | PHP | Besonderheit |
|-----|------|-----|--------------|
| 6.1 | 6.2 | 5.6 | – |
| 6.2 | 6.3 | 5.6 | – |
| 6.3 | 6.4 | 5.6 | – |
| 6.4 | 6.5 | 5.6 | – |
| 6.5 | 7.0 | **7.2** | PHP-Upgrade nötig vor diesem Schritt |
| 7.0 | 7.1 | 7.2 | – |
| 7.1 | 7.2 | 7.2 | – |
| 7.2 | 7.3 | 7.2 | letzte freie Version |

---

## Ergebnis

- Alle Tabellen (147) erfolgreich importiert
- Benutzerdaten übereinstimmend geprüft (3 User)
- vtigerCRM läuft auf neuem System ohne Fehler
- Migration ist als Skript automatisiert und reproduzierbar
- vtigerCRM wurde schrittweise von 6.1 auf 7.3 aktualisiert
