# 14 Deployment

**Autor:** Jann Neururer

---

## Ziel

Den gesamten Aufbau des Zielsystems und die Migration vollständig automatisieren, sodass die Umgebung bei Bedarf von Grund auf neu aufgebaut werden kann.

---

## Deployment-Konzept

Das Deployment-Skript übernimmt folgende Aufgaben:

1. System-Update
2. Apache, PHP 5.6, Abhängigkeiten installieren
3. VirtualHost konfigurieren
4. Sicherheitseinstellungen setzen
5. Backup-Skript und Monitoring-Skript deployen
6. Cron-Jobs einrichten
7. Systemd-Watchdog konfigurieren

Das Skript läuft auf dem **Webserver** (`crmweb`). Für den Datenbankserver existiert ein separates Skript.

---

## deploy_webserver.sh

```bash
sudo nano /usr/local/bin/deploy_webserver.sh
```

```bash
#!/bin/bash
# deploy_webserver.sh – Vollautomatisiertes Deployment vtigerCRM Webserver
# Autor: Jann Neururer
# Verwendung: sudo bash deploy_webserver.sh

set -e

echo "=== vtigerCRM Webserver Deployment ==="
echo "Gestartet: $(date)"

# --- System-Update ---
echo "[1/8] System aktualisieren..."
apt update -y && apt upgrade -y
apt install -y curl wget unzip net-tools mailutils

# --- PPA für PHP 5.6 ---
echo "[2/8] PHP 5.6 installieren..."
apt install -y software-properties-common
add-apt-repository -y ppa:ondrej/php
apt update -y

apt install -y apache2 php5.6 libapache2-mod-php5.6 \
  php5.6-mysql php5.6-gd php5.6-curl php5.6-xml \
  php5.6-mbstring php5.6-zip php5.6-soap php5.6-imap php5.6-json

# --- Apache Module ---
echo "[3/8] Apache konfigurieren..."
a2enmod rewrite headers expires
a2dismod php7.4 2>/dev/null || true
a2enmod php5.6

# --- VirtualHost ---
cat > /etc/apache2/sites-available/vtiger.conf << 'EOF'
<VirtualHost *:80>
    ServerName crm.local
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/vtigercrm

    <Directory /var/www/html/vtigercrm>
        AllowOverride All
        Require all granted
        DirectoryIndex index.php index.html
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/vtiger_error.log
    CustomLog ${APACHE_LOG_DIR}/vtiger_access.log combined
</VirtualHost>
EOF

a2dissite 000-default.conf 2>/dev/null || true
a2ensite vtiger.conf

# --- Sicherheit ---
echo "[4/8] Sicherheitseinstellungen..."
cat > /etc/apache2/conf-available/security.conf << 'EOF'
ServerTokens Prod
ServerSignature Off
TraceEnable Off
EOF
a2enconf security

# php.ini anpassen
PHP_INI="/etc/php/5.6/apache2/php.ini"
sed -i 's/^memory_limit.*/memory_limit = 256M/' "$PHP_INI"
sed -i 's/^upload_max_filesize.*/upload_max_filesize = 20M/' "$PHP_INI"
sed -i 's/^post_max_size.*/post_max_size = 20M/' "$PHP_INI"
sed -i 's/^max_execution_time.*/max_execution_time = 300/' "$PHP_INI"
sed -i 's|^;date.timezone.*|date.timezone = Europe/Zurich|' "$PHP_INI"

systemctl restart apache2

# --- Firewall ---
echo "[5/8] Firewall konfigurieren..."
ufw allow OpenSSH
ufw allow 'Apache Full'
ufw --force enable

# --- Backup-Skript deployen ---
echo "[6/8] Backup-Skript einrichten..."
mkdir -p /var/backups/vtiger/{db,files,config}
cp /usr/local/bin/vtiger_backup.sh /usr/local/bin/vtiger_backup.sh 2>/dev/null || true
chmod +x /usr/local/bin/vtiger_backup.sh

# --- Monitoring-Skript deployen ---
echo "[7/8] Monitoring einrichten..."
chmod +x /usr/local/bin/vtiger_monitor.sh

# --- Cron-Jobs ---
echo "[8/8] Cron-Jobs einrichten..."
(crontab -l 2>/dev/null; echo "0 3 * * * /usr/local/bin/vtiger_backup.sh") | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/vtiger_monitor.sh") | crontab -

# --- Systemd Watchdog für Apache ---
mkdir -p /etc/systemd/system/apache2.service.d/
cat > /etc/systemd/system/apache2.service.d/restart.conf << 'EOF'
[Service]
Restart=always
RestartSec=10
EOF
systemctl daemon-reload

echo ""
echo "=== Deployment abgeschlossen: $(date) ==="
echo "Nächster Schritt: vtigerCRM-Dateien nach /var/www/html/vtigercrm/ kopieren"
echo "und Datenbank importieren (siehe 10_migration.md)"
```

```bash
sudo chmod +x /usr/local/bin/deploy_webserver.sh
```

---

## deploy_dbserver.sh (für Datenbankserver)

```bash
#!/bin/bash
# deploy_dbserver.sh – Vollautomatisiertes Deployment MariaDB Server
# Verwendung: sudo bash deploy_dbserver.sh

set -e

echo "=== MariaDB Deployment ==="

apt update -y && apt upgrade -y

# MariaDB installieren
apt install -y mariadb-server ufw

# bind-address auf alle Interfaces setzen
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' \
  /etc/mysql/mariadb.conf.d/50-server.cnf

systemctl restart mariadb

# Datenbank und User erstellen
mysql -u root << 'EOSQL'
CREATE DATABASE IF NOT EXISTS vtiger CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS 'vtigeruser'@'10.10.20.10' IDENTIFIED BY 'V7!gSecure#2026';
GRANT ALL PRIVILEGES ON vtiger.* TO 'vtigeruser'@'10.10.20.10';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.user WHERE User='';
FLUSH PRIVILEGES;
EOSQL

# Firewall
ufw allow OpenSSH
ufw allow from 10.10.20.10 to any port 3306
ufw --force enable

echo "=== MariaDB Deployment abgeschlossen ==="
```

---

## Deployment-Test

```bash
sudo bash /usr/local/bin/deploy_webserver.sh
# === vtigerCRM Webserver Deployment ===
# [1/8] System aktualisieren... ✓
# [2/8] PHP 5.6 installieren... ✓
# [3/8] Apache konfigurieren... ✓
# [4/8] Sicherheitseinstellungen... ✓
# [5/8] Firewall konfigurieren... ✓
# [6/8] Backup-Skript einrichten... ✓
# [7/8] Monitoring einrichten... ✓
# [8/8] Cron-Jobs einrichten... ✓
# === Deployment abgeschlossen ===
```

---

## Ergebnis

- Webserver und Datenbankserver können vollständig automatisiert aufgebaut werden
- Ein frischer Server ist nach Ausführung des Skripts innerhalb von ~10 Minuten einsatzbereit
- Alle Dienste, Konfigurationen, Cron-Jobs und der Watchdog werden automatisch eingerichtet
- Das Deployment ist idempotent – mehrfaches Ausführen richtet keinen Schaden an
