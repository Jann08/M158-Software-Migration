# 06 PHP

**Datum:** 06.03.2026  
**Autor:** Jann Neururer

---

## Ziel

Eine PHP-Version installieren, die mit vtigerCRM 6.1 kompatibel ist. Das System soll sauber dokumentiert sein, sodass ein Versionswechsel jederzeit reproduzierbar ist.

---

## Problem: PHP 7.4 inkompatibel

Bei der ersten Installation wurde PHP 7.4 aus den Ubuntu-Standardquellen installiert:

```bash
sudo apt install php libapache2-mod-php php-mysql -y
```

Beim Aufruf von `http://crm.local` erschien sofort ein HTTP 500-Fehler.

Im Apache-Log (`/var/log/apache2/vtiger_error.log`) war folgendes zu sehen:

```
PHP Fatal error: Cannot use 'string' as class name as it is reserved in
/var/www/html/vtigercrm/include/utils/CommonUtils.php on line 14

PHP Deprecated: Methods with the same name as their class will not be
constructors in a future version of PHP in /var/www/html/vtigercrm/...
```

**Ursache:** vtigerCRM 6.1 wurde für PHP 5.x entwickelt und ist nicht kompatibel mit PHP 7.x wegen deprecated und entfernter Funktionen (z.B. `ereg`, `mysql_*`-Funktionen, Konstruktoren mit gleichem Namen wie Klasse).

---

## Lösung: PHP 5.6 installieren

Da PHP 5.6 nicht in den Standard-Ubuntu-Repositories verfügbar ist, wird das PPA von Ondřej Surý verwendet:

```bash
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
```

PHP 5.6 mit den für vtigerCRM benötigten Extensions installieren:

```bash
sudo apt install php5.6 libapache2-mod-php5.6 \
  php5.6-mysql php5.6-gd php5.6-curl php5.6-xml \
  php5.6-mbstring php5.6-zip php5.6-soap \
  php5.6-imap php5.6-json -y
```

---

## PHP-Version umschalten

PHP 7.4 deaktivieren, PHP 5.6 für Apache aktivieren:

```bash
sudo a2dismod php7.4
sudo a2enmod php5.6
sudo systemctl restart apache2
```

Aktive PHP-Version prüfen:

```bash
php -v
# PHP 5.6.40-60+ubuntu22.04.1+deb.sury.org+1 (cli)
```

---

## php.ini anpassen

```bash
sudo nano /etc/php/5.6/apache2/php.ini
```

Folgende Werte wurden angepasst (vtigerCRM-Empfehlungen):

```ini
memory_limit = 256M
upload_max_filesize = 20M
post_max_size = 20M
max_execution_time = 300
date.timezone = Europe/Zurich
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = Off
log_errors = On
error_log = /var/log/php5.6_errors.log
```

```bash
sudo systemctl restart apache2
```

---

## Test mit phpinfo

Temporäre Testdatei erstellen:

```bash
sudo nano /var/www/html/vtigercrm/info.php
```

```php
<?php phpinfo(); ?>
```

Aufruf: `http://crm.local/info.php`

Ergebnis: PHP 5.6 wird angezeigt, alle benötigten Extensions (`mysql`, `gd`, `curl`, `xml`, `mbstring`) als aktiv aufgeführt.

Testdatei danach wieder löschen (Sicherheit):

```bash
sudo rm /var/www/html/vtigercrm/info.php
```

---

## Parallelinstallation

Da PHP 5.6 und 7.4 parallel installiert sind, kann bei Bedarf jederzeit gewechselt werden:

```bash
# Wechsel zu PHP 7.4:
sudo a2dismod php5.6
sudo a2enmod php7.4
sudo update-alternatives --set php /usr/bin/php7.4
sudo systemctl restart apache2

# Zurück zu PHP 5.6:
sudo a2dismod php7.4
sudo a2enmod php5.6
sudo update-alternatives --set php /usr/bin/php5.6
sudo systemctl restart apache2
```

Das ist praktisch für spätere Tests mit neueren vtigerCRM-Versionen, die PHP 7.x benötigen.

---

## Ergebnis

- PHP 5.6.40 läuft stabil unter Apache
- Alle benötigten Extensions sind aktiv
- vtigerCRM 6.1 startet fehlerfrei
- Parallelinstallation ist dokumentiert und reproduzierbar
