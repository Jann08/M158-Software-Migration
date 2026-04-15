# 04 DNS

**Datum:** 05.03.2026  
**Autor:** Jann Neururer

---

## Ziel

Die Server sollen nicht nur über IP-Adressen, sondern auch über sprechende Namen erreichbar sein. Da kein eigener DNS-Server aufgebaut wird, erfolgt die Namensauflösung über die `hosts`-Datei auf allen beteiligten Systemen.

---

## Umsetzung – hosts-Datei

### Auf dem Webserver (`crmweb`)

```bash
sudo nano /etc/hosts
```

Einträge hinzufügen:

```text
127.0.0.1       localhost
127.0.1.1       crmweb
10.10.20.10     crm.local
10.10.20.11     crm-db.local
```

### Auf dem Datenbankserver (`crm-db`)

```bash
sudo nano /etc/hosts
```

```text
127.0.0.1       localhost
127.0.1.1       crm-db
10.10.20.10     crm.local
10.10.20.11     crm-db.local
```

### Auf dem Host-PC (Windows)

Damit auch vom eigenen Rechner aus `http://crm.local` aufgerufen werden kann:

```
C:\Windows\System32\drivers\etc\hosts
```

Datei mit Administratorrechten öffnen und eintragen:

```text
10.10.20.10     crm.local
10.10.20.11     crm-db.local
```

DNS-Cache leeren, damit die Änderungen sofort greifen:

```cmd
ipconfig /flushdns
```

---

## Tests

**Ping auf crm.local vom Webserver:**

```bash
ping -c 3 crm.local
# PING crm.local (10.10.20.10): 56 bytes from 10.10.20.10
```

**Ping auf crm-db.local vom Webserver:**

```bash
ping -c 3 crm-db.local
# PING crm-db.local (10.10.20.11): 56 bytes from 10.10.20.11
```

**Aufruf im Browser (vom Host):**

```
http://crm.local/
```

→ Apache-Standardseite erscheint. DNS-Auflösung funktioniert.

---

## Ergebnis

Die Namensauflösung funktioniert auf allen drei Systemen (Webserver, DB-Server, Host-PC). Damit kann die restliche Dokumentation und Konfiguration konsequent mit Hostnamen statt IP-Adressen arbeiten, was die Lesbarkeit und Wartbarkeit deutlich verbessert.

Ein eigener BIND-DNS-Server wurde bewusst nicht aufgebaut – für diese Projektgrösse ist die hosts-Datei ausreichend und einfacher zu warten.
