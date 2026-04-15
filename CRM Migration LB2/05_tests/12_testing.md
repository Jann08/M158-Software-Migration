# 12 Testing

**Autor:** Jann Neururer

---

## Ziel

Nachweisen, dass die Migration vollständig und korrekt durchgeführt wurde. Testkonzept mit breiter Abdeckung – Netzwerk, Dienste, Applikation, Datenbank, Sicherheit.

---

## Testkonzept

| # | Bereich | Testfall | Erwartetes Ergebnis | Status |
|---|---------|----------|---------------------|--------|
| 1 | Netzwerk | Ping von crmweb auf crm-db | Antwort < 1ms | ✅ |
| 2 | Netzwerk | Ping von Host auf crm.local | Antwort vorhanden | ✅ |
| 3 | Netzwerk | Namensauflösung crm.local | → 10.10.20.10 | ✅ |
| 4 | Netzwerk | Namensauflösung crm-db.local | → 10.10.20.11 | ✅ |
| 5 | Webserver | HTTP-Request auf Port 80 | HTTP 200 oder 302 | ✅ |
| 6 | Webserver | Apache VirtualHost aktiv | crm.local zeigt vtigerCRM | ✅ |
| 7 | Webserver | ServerTokens Prod | Kein Apache-Version in Header | ✅ |
| 8 | PHP | PHP-Version | 5.6.x | ✅ |
| 9 | PHP | PHP-Extension mysql | vorhanden | ✅ |
| 10 | Datenbank | Remote-Verbindung von .10 | Login erfolgreich | ✅ |
| 11 | Datenbank | Tabellenanzahl | 147 Tabellen | ✅ |
| 12 | Datenbank | Benutzeranzahl in vtiger_users | 3 (identisch mit Altsystem) | ✅ |
| 13 | Datenbank | Zugriff von ausserhalb .10 | Verbindung verweigert | ✅ |
| 14 | Applikation | vtigerCRM Login | Erfolgreich mit admin/Passwort | ✅ |
| 15 | Applikation | Kontakte laden | Alle Kontakte vorhanden | ✅ |
| 16 | Applikation | Accounts laden | Alle Accounts vorhanden | ✅ |
| 17 | Sicherheit | Port 3306 von aussen | Nicht erreichbar (Firewall) | ✅ |
| 18 | Sicherheit | SSH root-Login per Passwort | Deaktiviert | ✅ |
| 19 | Backup | Backup-Skript manuell | Dateien erstellt, Log korrekt | ✅ |
| 20 | Backup | Restore der Datenbank | Import funktioniert, Tabellen korrekt | ✅ |

---

## Testdurchführung

### Test 1–4: Netzwerk

```bash
# Vom Webserver:
ping -c 3 crm-db.local
# 3 packets transmitted, 3 received

ping -c 3 crm.local
# 3 packets transmitted, 3 received

nslookup crm.local
# → 10.10.20.10 (aus /etc/hosts)
```

### Test 5–7: Webserver

```bash
curl -I http://crm.local
# HTTP/1.1 302 Found
# Server: Apache
# (keine Versionsangabe → ServerTokens Prod aktiv)
```

### Test 8–9: PHP

```bash
php -v
# PHP 5.6.40-60+ubuntu22.04.1+deb.sury.org+1

php -m | grep mysql
# mysql
# mysqli
# pdo_mysql
```

### Test 10–13: Datenbank

```bash
# Verbindung vom Webserver:
mysql -h crm-db.local -u vtigeruser -p vtiger -e "SHOW TABLES;" | wc -l
# 147

mysql -h crm-db.local -u vtigeruser -p vtiger -e "SELECT count(*) FROM vtiger_users;"
# 3

# Verbindungsversuch von aussen (sollte scheitern):
mysql -h 10.10.20.11 -u vtigeruser -p
# ERROR 2003 (HY000): Can't connect to MySQL server (Firewall blockiert)
```

### Test 17: Firewall

```bash
# Vom Host-PC:
nmap -p 3306 10.10.20.11
# PORT     STATE    SERVICE
# 3306/tcp filtered mysql
```

Port ist gefiltert – Firewall funktioniert.

### Test 18: SSH-Sicherheit

```bash
sudo grep "PermitRootLogin" /etc/ssh/sshd_config
# PermitRootLogin no
```

### Test 19–20: Backup

```bash
sudo /usr/local/bin/vtiger_backup.sh
ls /var/backups/vtiger/db/
# vtiger_db_20260311_0930.sql.gz

# Restore testen:
gunzip -c /var/backups/vtiger/db/vtiger_db_20260311_0930.sql.gz | \
  mysql -h crm-db.local -u vtigeruser -p vtiger_test
mysql -h crm-db.local -u vtigeruser -p vtiger_test -e "SELECT count(*) FROM vtiger_users;"
# 3 ✅
```

---

## Automatisiertes Test-Skript

```bash
#!/bin/bash
# vtiger_test.sh – Smoke-Test nach Migration

ERRORS=0

check() {
  if eval "$2" &>/dev/null; then
    echo "✅ $1"
  else
    echo "❌ $1"
    ERRORS=$((ERRORS+1))
  fi
}

check "Apache läuft" "systemctl is-active apache2"
check "MariaDB erreichbar" "mysql -h crm-db.local -u vtigeruser -pV7!gSecure#2026 vtiger -e 'SELECT 1'"
check "vtigerCRM erreichbar" "curl -s -o /dev/null -w '%{http_code}' http://crm.local | grep -E '200|302'"
check "PHP Version 5.6" "php -v | grep 'PHP 5.6'"
check "Backup-Skript vorhanden" "test -f /usr/local/bin/vtiger_backup.sh"

echo ""
echo "Tests abgeschlossen. Fehler: $ERRORS"
```

```bash
sudo chmod +x /usr/local/bin/vtiger_test.sh
sudo /usr/local/bin/vtiger_test.sh
# ✅ Apache läuft
# ✅ MariaDB erreichbar
# ✅ vtigerCRM erreichbar
# ✅ PHP Version 5.6
# ✅ Backup-Skript vorhanden
# Tests abgeschlossen. Fehler: 0
```

---

## Ergebnis

Alle 20 Testfälle bestanden. Die Migration ist vollständig und korrekt durchgeführt.
