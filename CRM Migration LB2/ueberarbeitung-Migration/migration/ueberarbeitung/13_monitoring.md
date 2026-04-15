# 13 Monitoring

**Autor:** Jann Neururer

---

## Ziel

Überwachung der wichtigsten Dienste (Apache, MariaDB, SSH) mit Logging und E-Mail-Alarmierung. Bei Ausfall soll ein automatischer Neustart versucht werden (Watchdog).

---

## Monitoring-Skript mit Alarmierung

```bash
sudo nano /usr/local/bin/vtiger_monitor.sh
```

```bash
#!/bin/bash
# vtiger_monitor.sh – Monitoring für vtigerCRM-Umgebung
# Autor: Jann Neururer

LOG="/var/log/vtiger_monitor.log"
MAIL_TO="admin@example.ch"
DB_HOST="192.168.42.134"
DB_USER="vtigeruser"
DB_PASS=""
DB_NAME="vtiger"
DATUM=$(date '+%Y-%m-%d %H:%M:%S')

log() {
  echo "[$DATUM] $1" >> "$LOG"
}

alert() {
  log "ALARM: $1"
  echo "[$DATUM] ALARM: $1 – Bitte prüfen!" | mail -s "vtigerCRM Monitor: $1" "$MAIL_TO"
}

restart_service() {
  log "Versuche Neustart: $1"
  systemctl restart "$1"
  sleep 5
  if systemctl is-active "$1" &>/dev/null; then
    log "Neustart erfolgreich: $1"
  else
    alert "Neustart fehlgeschlagen: $1"
  fi
}

# --- Apache prüfen ---
if ! systemctl is-active apache2 &>/dev/null; then
  alert "Apache ist ausgefallen"
  restart_service apache2
else
  log "Apache: OK"
fi

# --- HTTP-Check ---
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://crm.local)
if [[ "$HTTP_CODE" != "200" && "$HTTP_CODE" != "302" ]]; then
  alert "HTTP-Check fehlgeschlagen (Code: $HTTP_CODE)"
else
  log "HTTP-Check: OK (Code: $HTTP_CODE)"
fi

# --- MariaDB prüfen ---
if ! mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT 1" &>/dev/null; then
  alert "MariaDB nicht erreichbar"
  # MariaDB läuft auf anderem Server – nur Alarm, kein lokaler Neustart
else
  log "MariaDB: OK"
fi

# --- SSH prüfen ---
if ! systemctl is-active sshd &>/dev/null; then
  alert "SSH-Dienst ausgefallen"
  restart_service sshd
else
  log "SSH: OK"
fi

# --- Festplattenauslastung ---
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$DISK_USAGE" -gt 85 ]; then
  alert "Festplatte fast voll: ${DISK_USAGE}% belegt"
else
  log "Festplatte: ${DISK_USAGE}% belegt – OK"
fi
```

```bash
sudo chmod +x /usr/local/bin/vtiger_monitor.sh
```

---

## E-Mail-Versand einrichten

```bash
sudo apt install mailutils postfix -y
# Bei der Konfiguration: "Internet Site" wählen
# System mail name: crm.local
```

Test:

```bash
echo "Test Monitoring" | mail -s "Monitor-Test" jann.account@pm.me
```

---

## Cron – alle 5 Minuten überwachen

```bash
sudo crontab -e
```

```cron
*/5 * * * * /usr/local/bin/vtiger_monitor.sh
```

---

## Log-Ausgabe

```
[2026-03-11 10:00:01] Apache: OK
[2026-03-11 10:00:01] HTTP-Check: OK (Code: 302)
[2026-03-11 10:00:02] MariaDB: OK
[2026-03-11 10:00:02] SSH: OK
[2026-03-11 10:00:02] Festplatte: 18% belegt – OK
```

---

## Watchdog – automatischer Neustart

Der Watchdog ist bereits im Monitoring-Skript enthalten: Bei einem ausgefallenen Dienst wird `systemctl restart` versucht. Zusätzlich wurde systemd so konfiguriert, dass Apache bei einem Absturz selbst neu startet:

```bash
sudo mkdir -p /etc/systemd/system/apache2.service.d/
sudo nano /etc/systemd/system/apache2.service.d/restart.conf
```

```ini
[Service]
Restart=always
RestartSec=10
```

```bash
sudo systemctl daemon-reload
```

Damit startet Apache bei einem unerwarteten Absturz nach 10 Sekunden automatisch neu – unabhängig vom Monitoring-Skript.

---

## Ergebnis

- Alle 5 Minuten werden Apache, HTTP, MariaDB, SSH und Disk überwacht
- Bei Ausfall wird automatisch versucht, den Dienst neu zu starten
- E-Mail-Alarmierung ist eingerichtet
- Watchdog via systemd für Apache aktiv
- Logs werden in `/var/log/vtiger_monitor.log` geschrieben
