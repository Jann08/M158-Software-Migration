# 08 phpMyAdmin / Adminer

**Datum:** 07.03.2026  
**Autor:** Jann Neururer

---

## Ziel

Webbasierten Datenbankzugriff für SQL-Abfragen, Datenverwaltung und Migration bereitstellen. Anstelle von phpMyAdmin wurde Adminer verwendet gleicher Funktionsumfang, aber als einzelne PHP-Datei einfacher zu deployen.

---

## Warum Adminer statt phpMyAdmin?

phpMyAdmin benötigt eine eigene Datenbank, mehrere Konfigurationsdateien und ist deutlich aufwändiger zu installieren. Adminer besteht aus einer einzigen `index.php`-Datei und funktioniert sofort. Für dieses Projekt ist das ausreichend.

---

## Installation auf dem Webserver

```bash
sudo mkdir -p /var/www/html/vtigercrm/adminer
cd /var/www/html/vtigercrm/adminer
sudo wget https://www.adminer.org/latest.php -O index.php
```

Berechtigungen setzen:

```bash
sudo chown -R www-data:www-data /var/www/html/vtigercrm/adminer
```

---

## Problem: Adminer lädt, aber Login schlägt fehl

Beim Versuch, sich mit den MariaDB-Daten einzuloggen:

```
Server: 10.10.20.11
Benutzer: vtigeruser
Passwort: ****
Datenbank: vtiger
```

Fehlermeldung: `SQLSTATE[HY000] [1045] Access denied for user 'vtigeruser'@'...'`

**Ursache:** Der PHP-Request vom Webserver geht als `10.10.20.10` raus, aber der MariaDB-User war auf genau diese IP beschränkt. Das stimmte eigentlich nach erneutem Test funktionierte es. Ich habe mich einfach einige male beim pw vertippt.

---

## Zugriff

```
http://crm.local/adminer
```

Login-Felder:
- **Server:** `10.10.20.11` (oder `crm-db.local`)
- **Benutzer:** `vtigeruser`
- **Passwort:** (gesetzt beim DB-Setup)
- **Datenbank:** `vtiger`

---

## Adminer absichern

Da Adminer öffentlich auf dem Webserver liegt, wurde der Zugriff mit einem HTTP-Passwort gesichert:

```bash
sudo apt install apache2-utils -y
sudo htpasswd -c /etc/apache2/.adminer_htpasswd admin
# Passwort eingeben und bestätigen
```

VirtualHost erweitern:

```bash
sudo nano /etc/apache2/sites-available/vtiger.conf
```

Abschnitt hinzufügen:

```apache
<Directory /var/www/html/vtigercrm/adminer>
    AuthType Basic
    AuthName "Adminer – nur für Admins"
    AuthUserFile /etc/apache2/.adminer_htpasswd
    Require valid-user
</Directory>
```

```bash
sudo systemctl reload apache2
```

Jetzt erscheint beim Aufruf von `/adminer` ein Browser-Login-Dialog.

---

## Export- und Migrationsskripte

### Datenbank exportieren (vom Webserver aus)

```bash
mysqldump -h 10.10.20.11 -u vtigeruser -p vtiger > /tmp/vtiger_migration.sql
```

Prüfung der Datei:

```bash
ls -lh /tmp/vtiger_migration.sql
# -rw-r--r-- 1 administrator administrator 4.2M Mär 10 17:32 /tmp/vtiger_migration.sql

head -20 /tmp/vtiger_migration.sql
# -- MariaDB dump ...
# -- Host: 10.10.20.11    Database: vtiger
```

### Datenbank importieren

```bash
mysql -h 10.10.20.11 -u vtigeruser -p vtiger < /tmp/vtiger_migration.sql
```

Ergebnis prüfen:

```bash
mysql -h 10.10.20.11 -u vtigeruser -p vtiger -e "SHOW TABLES;" | wc -l
# 147
```

---

## Ergebnis

- Adminer läuft und ist über Browser erreichbar
- Login mit HTTP-Passwort geschützt
- Export/Import der Datenbank per CLI funktioniert
- Skripte für Migration vorbereitet und getestet
