# 09 SFTP / FTPS-Zugang

**Autor:** Jann Neururer

---

## Ziel

Sicheren Dateitransfer zwischen Altsystem und neuem Webserver einrichten, und diesen für die Migration der vtigerCRM-Dateien nutzen.

---

## Entscheid: SFTP über SSH

FTPS (FTP über TLS) würde einen separaten FTP-Server (z.B. vsftpd) erfordern. Da SSH ohnehin auf beiden Systemen läuft, ist SFTP die einfachere und sicherere Wahl gleiche Verschlüsselung, kein zusätzlicher Port, kein zusätzlicher Dienst.

---

## SFTP-Zugang testen

SSH ist auf dem Webserver bereits aktiv. SFTP funktioniert ohne weitere Konfiguration:

```bash
sftp administrator@crm.local
# Connected to crm.local.
# sftp>
```

Dateien hochladen:

```bash
sftp> put /tmp/vtiger_migration.sql /tmp/vtiger_migration.sql
# Uploading /tmp/vtiger_migration.sql to /tmp/vtiger_migration.sql
# vtiger_migration.sql    100% 4.2MB   2.1MB/s   00:02
sftp> exit
```

---

## Dateimigration vom Altsystem

### Problem: SCP-Fehler wegen alter SSH-Version

Beim Versuch, Dateien direkt vom Altsystem (CentOS 6.6, OpenSSH 5.3) zu kopieren:

```bash
scp -r root@localhost:/var/www/html/vtigercrm /tmp/
# no hostkey alg
```

**Ursache:** OpenSSH 5.3 auf dem alten Server unterstützt keine modernen Key-Algorithmen, die der neue Client erwartet.

**Lösung:** SCP mit expliziten Algorithmus-Optionen aufrufen:

```bash
scp -O -P 2222 \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  root@localhost:/var/www/html/vtigercrm \
  administrator@192.168.42.135:/tmp/
```


**Alternative** (Transfer vom neuen System aus initiieren):

```bash
# Auf dem neuen Webserver:
scp -O -P 2222 \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  root@10.0.2.10:/var/www/html/vtigercrm /tmp/vtigercrm_backup/
```

---

## rsync für automatisierte/wiederholbare Migration

Für mehrfache Übertragungen (z.B. Testing, dann finale Migration) wurde `rsync` verwendet, weil nur geänderte Dateien übertragen werden:

```bash
rsync -avz --delete \
  -e "ssh -p 2222 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa" \
  root@localhost:/var/www/html/vtigercrm/ \
  administrator@192.168.42.135:/tmp/vtigercrm/
```

Ausgabe (Auszug):

```
sending incremental file list
vtigercrm/
vtigercrm/index.php
vtigercrm/config.inc.php
...
sent 81,234,521 bytes  received 4,512 bytes  2,341,432.65 bytes/sec
```

---

## Automatisierung per Cron (optionale Synchronisierung)

Für regelmässige Synchronisierung kann ein Cron-Job eingerichtet werden:

```bash
crontab -e
```

```cron
0 2 * * * /usr/bin/rsync -avz --delete \
  -e "ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa" \
  root@10.0.2.10:/var/www/html/vtigercrm/ \
  /var/www/html/vtigercrm/ >> /var/log/vtiger_sync.log 2>&1
```

---

## SFTP-Benutzer einschränken (optional, für produktiven Betrieb)

Damit ein SFTP-Benutzer nur auf bestimmte Verzeichnisse zugreifen kann (Chroot):

```bash
sudo nano /etc/ssh/sshd_config
```

```
Match User sftpuser
    ChrootDirectory /var/www/html/vtigercrm
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
```

```bash
sudo systemctl restart sshd
```

---

## Ergebnis

- SFTP funktioniert über SSH auf Port 22
- Dateitransfer vom Altsystem gelöst (HostKeyAlgorithms-Workaround)
- rsync für wiederholbare Übertragungen eingesetzt
- Migration der Anwendungsdateien erfolgreich abgeschlossen
