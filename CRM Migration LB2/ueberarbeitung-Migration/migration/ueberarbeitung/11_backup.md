# 11 Backup

**Autor:** Jann Neururer

---

## Ziel

Automatisiertes, zeitgesteuertes Backup für Datenbank und Anwendungsdateien einrichten. Alte Backups sollen automatisch bereinigt werden (Aufbewahrungskonzept).

---

## Backup-Konzept

| Was | Wie | Wo | Aufbewahrung |
|-----|-----|----|--------------|
| Datenbank (MariaDB) | mysqldump | `/var/backups/vtiger/db/` | 14 Tage |
| Anwendungsdateien | tar.gz | `/var/backups/vtiger/files/` | 7 Tage |
| Konfigurationen | tar.gz | `/var/backups/vtiger/config/` | 30 Tage |

---

## Backup-Skript erstellen

```bash
sudo nano /usr/local/bin/vtiger_backup.sh
```

```bash
#!/bin/bash
# vtiger_backup.sh – tägliches Backup für vtigerCRM
# Autor: Jann Neururer

set -e

DATUM=$(date +%Y%m%d_%H%M)
BACKUP_BASE="/var/backups/vtiger"
DB_HOST="192.168.42.134"
DB_USER="vtigeruser"
DB_PASS=""
DB_NAME="vtiger"
WEB_DIR="/var/www/html/vtigercrm"
LOG="/var/log/vtiger_backup.log"

# Verzeichnisse erstellen
mkdir -p "$BACKUP_BASE/db" "$BACKUP_BASE/files" "$BACKUP_BASE/config"

echo "[$DATUM] Backup gestartet" >> "$LOG"

# --- Datenbank-Backup ---
DB_FILE="$BACKUP_BASE/db/vtiger_db_$DATUM.sql.gz"
mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" \
  --single-transaction \
  --routines \
  --triggers \
  "$DB_NAME" | gzip > "$DB_FILE"

echo "[$DATUM] DB-Backup erstellt: $DB_FILE" >> "$LOG"

# --- Dateien-Backup ---
FILES_FILE="$BACKUP_BASE/files/vtiger_files_$DATUM.tar.gz"
tar -czf "$FILES_FILE" -C /var/www/html vtigercrm \
  --exclude=vtigercrm/cache

echo "[$DATUM] Dateien-Backup erstellt: $FILES_FILE" >> "$LOG"

# --- Konfigurations-Backup ---
CONFIG_FILE="$BACKUP_BASE/config/vtiger_config_$DATUM.tar.gz"
tar -czf "$CONFIG_FILE" \
  /etc/apache2/sites-available/vtiger.conf \
  /var/www/html/vtigercrm/config.inc.php \
  /etc/php/5.6/apache2/php.ini

echo "[$DATUM] Konfig-Backup erstellt: $CONFIG_FILE" >> "$LOG"

# --- Alte Backups bereinigen ---
find "$BACKUP_BASE/db/"    -name "*.sql.gz" -mtime +14 -delete
find "$BACKUP_BASE/files/" -name "*.tar.gz" -mtime +7  -delete
find "$BACKUP_BASE/config/" -name "*.tar.gz" -mtime +30 -delete

echo "[$DATUM] Alte Backups bereinigt" >> "$LOG"
echo "[$DATUM] Backup abgeschlossen" >> "$LOG"
```

```bash
sudo chmod +x /usr/local/bin/vtiger_backup.sh
```

---

## Manueller Test

```bash
sudo /usr/local/bin/vtiger_backup.sh
```

Ergebnis prüfen:

```bash
ls -lh /var/backups/vtiger/db/
# -rw-r--r-- 1 root root 1.1M Mär 10 17:45 vtiger_db_20260310_1745.sql.gz

ls -lh /var/backups/vtiger/files/
# -rw-r--r-- 1 root root 28M Mär 10 17:45 vtiger_files_20260310_1745.tar.gz

cat /var/log/vtiger_backup.log
# [20260310_1745] Backup gestartet
# [20260310_1745] DB-Backup erstellt: ...
# [20260310_1745] Dateien-Backup erstellt: ...
# [20260310_1745] Konfig-Backup erstellt: ...
# [20260310_1745] Alte Backups bereinigt
# [20260310_1745] Backup abgeschlossen
```

---

## Zeitgesteuertes Backup (Cron)

```bash
sudo crontab -e
```

Backup täglich um 03:00 Uhr:

```cron
0 3 * * * /usr/local/bin/vtiger_backup.sh
```

---

## Restore-Prozedur

Datenbank wiederherstellen:

```bash
gunzip -c /var/backups/vtiger/db/vtiger_db_20260310_1745.sql.gz | \
  mysql -h 192.168.42.134 -u vtigeruser -p vtiger
```

Dateien wiederherstellen:

```bash
sudo tar -xzf /var/backups/vtiger/files/vtiger_files_20260310_1745.tar.gz \
  -C /var/www/html/
sudo chown -R www-data:www-data /var/www/html/vtigercrm
```

---

## Ergebnis

- Backup läuft automatisch täglich um 03:00 Uhr
- Datenbank, Dateien und Konfiguration werden gesichert
- Alte Backups werden automatisch gelöscht
- Restore-Prozedur ist dokumentiert und getestet
