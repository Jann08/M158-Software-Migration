# 05 Webserver

**Datum:** 06.03.2026  
**Autor:** Jann Neururer

---

## Ziel

Apache Webserver auf `crmweb` installieren, einen VirtualHost für vtigerCRM einrichten und die Sicherheit sowie Performance grundlegend konfigurieren.

---

## Installation

```bash
sudo apt update
sudo apt install apache2 -y
```

Dienst prüfen:

```bash
sudo systemctl status apache2
# ● apache2.service - The Apache HTTP Server
#      Active: active (running)
```

---

## VirtualHost konfigurieren

Neue Konfigurationsdatei erstellen:

```bash
sudo nano /etc/apache2/sites-available/vtiger.conf
```

Inhalt:

```apache
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
```

Standard-Site deaktivieren, neue aktivieren:

```bash
sudo a2dissite 000-default.conf
sudo a2ensite vtiger.conf
sudo a2enmod rewrite headers expires
sudo systemctl reload apache2
```

---

## Problem: Apache-Seite nicht erreichbar

Nach der Konfiguration war `http://crm.local` nicht erreichbar.

**Ursache:** UFW-Firewall blockierte HTTP-Anfragen.

**Prüfung:**

```bash
sudo ufw status
# Status: active
```

**Lösung:**

```bash
sudo ufw allow 'Apache Full'
sudo ufw status
# Apache Full       ALLOW IN    Anywhere
```

Danach war die Seite erreichbar.

---

## Sicherheitskonfiguration

Directory Listing deaktivieren und ServerTokens minimieren:

```bash
sudo nano /etc/apache2/conf-available/security.conf
```

```apache
ServerTokens Prod
ServerSignature Off
TraceEnable Off

<Directory />
    Options -Indexes
    AllowOverride None
</Directory>
```

```bash
sudo a2enconf security
sudo systemctl reload apache2
```

---

## Dateirechte

Die vtigerCRM-Dateien müssen dem Apache-Benutzer (`www-data`) gehören:

```bash
sudo chown -R www-data:www-data /var/www/html/vtigercrm
sudo find /var/www/html/vtigercrm -type d -exec chmod 755 {} \;
sudo find /var/www/html/vtigercrm -type f -exec chmod 644 {} \;
```

---

## Load-Balancing konzept vorbereitet

Für spätere Skalierung wurde ein Load-Balancer-Konzept dokumentiert. Falls ein zweiter Webserver hinzugefügt wird, kann folgende Konfiguration aktiviert werden:

```bash
sudo a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests
```

```apache
<Proxy "balancer://vtigercluster">
    BalancerMember "http://10.10.20.10"
    BalancerMember "http://10.10.20.12"
    ProxySet lbmethod=byrequests
</Proxy>

ProxyPass "/" "balancer://vtigercluster/"
ProxyPassReverse "/" "balancer://vtigercluster/"
```

Aktuell nicht aktiv – dokumentiert für mögliche spätere Erweiterung sofern genug Zeit.

---

## Test

```bash
curl -I http://crm.local
# HTTP/1.1 200 OK
# Server: Apache
# (kein detaillierter Versions-String dank ServerTokens Prod)
```

Apache läuft, VirtualHost ist aktiv, Sicherheitseinstellungen greifen.
