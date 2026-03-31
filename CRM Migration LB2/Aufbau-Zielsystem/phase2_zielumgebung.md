# Phase 2: Aufbau der Zielumgebung (SOLL-System)

## 10. Ziel der Phase

Ziel dieser Phase war der Aufbau einer modernen, sicheren und skalierbaren Infrastruktur für das CRM-System. Dabei wurde die bestehende monolithische Architektur durch eine getrennte Serverstruktur ersetzt.

---

## 11. Architektur

| Komponente | Hostname | IP-Adresse |
|---|---|---|
| Webserver |  |  |
| Datenbankserver |  |  |

**Netzwerk:** Host-only (intern) + NAT (Internet)

**Begründung:** Die Trennung ermöglicht höhere Sicherheit, bessere Wartbarkeit und zukünftige Skalierbarkeit.

---

## 12. Installation & Vorbereitung

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install curl wget unzip -y
```

---

## 13. Netzwerkprobleme & Lösungen

### Problem 1: Kein Internetzugang

**Fehlermeldung:**
```
Network is unreachable
```

**Ursache:** Nur Host-only Netzwerk aktiv → kein Internet

**Lösung:** Zweiten Adapter hinzufügen (NAT) und Netplan konfigurieren:

```yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true
    ens37:
      dhcp4: true
```

```bash
sudo netplan apply
```

### Problem 2: Interface DOWN

```bash
ip a
# ens37 war DOWN
sudo ip link set ens37 up
```

### Problem 3: Keine DHCP-Adresse

**Lösung:** Netplan korrekt konfigurieren (`dhcp4: true`)

---

## 14. MariaDB Setup

```bash
sudo apt install mariadb-server -y
sudo mysql_secure_installation
```

### Datenbank erstellen

```sql
CREATE DATABASE vtiger;
CREATE USER 'vtigeruser'@'192.168.42.135' IDENTIFIED BY 'StrongPassword!';
GRANT ALL PRIVILEGES ON vtiger.* TO 'vtigeruser'@'192.168.42.135';
FLUSH PRIVILEGES;
```

### Problem: Remote-Zugriff nicht möglich

**Ursache:**
```
bind-address = 127.0.0.1
```

**Lösung:**

```ini
bind-address = 0.0.0.0
```

```bash
sudo systemctl restart mariadb
```

---

## 15. Firewall

```bash
sudo apt install ufw -y
sudo ufw allow OpenSSH
sudo ufw allow from 192.168.42.135 to any port 3306
sudo ufw enable
```

---

## 16. Webserver Setup

```bash
sudo apt install apache2 -y
sudo apt install php php-mysql php-cli php-curl php-xml php-mbstring php-gd php-zip libapache2-mod-php -y
```

```bash
sudo a2enmod rewrite
sudo systemctl restart apache2
```

### Problem: Apache-Seite nicht erreichbar

**Ursache:** Firewall oder Dienst nicht gestartet

**Lösung:**

```bash
sudo systemctl start apache2
sudo systemctl status apache2
```

---

## 17. VirtualHost

```apache
<VirtualHost *:80>
    ServerName crmserver.ch
    DocumentRoot /var/www/html/vtigercrm

    <Directory /var/www/html/vtigercrm>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

```bash
sudo a2dissite 000-default.conf
sudo a2ensite vtiger.conf
sudo systemctl reload apache2
```

---

## 18. DNS (hosts)

```
192.168.42.135 crmserver.ch
```

---

## 19. SFTP / SCP

```bash
scp -r vtigercrm user@server:/tmp/
sftp noah@192.168.42.135
```

### Problem: SCP-Fehler

**Fehlermeldung:**
```
no hostkey alg
```

**Ursache:** Alte SSH-Version auf dem alten Server

**Lösung:** Transfer vom neuen System oder PC starten, SSH-Optionen erweitern:

```bash
scp -O -P 2222 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  root@localhost:/var/www/html/vtigercrm noah@192.168.42.135:/tmp/
```

---

## 20. Verbindungstest

```bash
mysql -h 192.168.42.134 -u vtigeruser -p
```

---

## 21. Weitere Probleme & Lösungen

### Problem: Passwort vergessen (VM Login)

Während der Installation wurde das Benutzerpasswort vergessen, wodurch kein Login mehr möglich war.

**Lösung:** Wiederherstellung über den Recovery Mode:

1. VM starten und GRUB-Menü öffnen
2. „Advanced options for Ubuntu" auswählen
3. „Recovery Mode" starten
4. Root-Shell öffnen

```bash
mount -o remount,rw /
ls /home
passwd noah
reboot
```

---

### Problem: Copy/Paste in VM schwierig

**Lösung:** SSH zur komfortablen Administration verwenden:

```bash
ssh noah@192.168.42.135
ssh noah@192.168.42.134
```

SSH installieren und aktivieren:

```bash
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh
```

**Alternative Lösung:**

```bash
sudo apt install open-vm-tools -y
reboot
```

---

### Problem: Unterschiedliche Netzwerke

Webserver und Datenbankserver befanden sich initial in unterschiedlichen Netzwerken:

| Server | Netz |
|---|---|
| Webserver | 172.x.x.x |
| Datenbankserver | 192.168.x.x |

Dadurch war keine Kommunikation möglich.

**Lösung:** Beide VMs in dasselbe Netzwerk bringen (VMware):

- Adapter 1: NAT (Internet)
- Adapter 2: Host-only (intern)

---

### Problem: Kein Internetzugang (nach Umstellung)

**Fehlermeldung:**
```
Network is unreachable
```

**Ursache:** NAT-Interface war nicht aktiv

**Lösung:**

```bash
ip a
sudo ip link set ens37 up
sudo nano /etc/netplan/*.yaml
```

```yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true
    ens37:
      dhcp4: true
```

```bash
sudo netplan apply
ping 8.8.8.8
ping google.com
```

---

### Problem: SCP-Fehler (no hostkey alg)

**Fehlermeldung:**
```
no hostkey alg
```

**Ursache:** Alte SSH-Version auf dem alten Server

**Lösung:** Transfer vom neuen System oder Client starten:

```bash
scp -O -P 2222 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  root@localhost:/var/www/html/vtigercrm noah@192.168.42.135:/tmp/
```

---

### Problem: Datenbank nicht erreichbar

**Ursache:** MariaDB nur auf localhost gebunden

**Lösung:**

```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

```ini
bind-address = 0.0.0.0
```

```bash
sudo systemctl restart mariadb
```

Zugriff auf Webserver-IP einschränken:

```sql
CREATE USER 'vtigeruser'@'192.168.42.135' IDENTIFIED BY 'StrongPassword!';
GRANT ALL PRIVILEGES ON vtiger.* TO 'vtigeruser'@'192.168.42.135';
FLUSH PRIVILEGES;
```
