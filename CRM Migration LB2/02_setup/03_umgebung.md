# 03 Umgebung aufbauen / einrichten

**Datum:** 05.03.2026  
**Autor:** Jann Neururer

---

## Ziel

Zwei Ubuntu Server VMs aufsetzen, die als Webserver und Datenbankserver dienen. Beide VMs sollen über ein internes Netz miteinander kommunizieren können und Internetzugang für Updates haben.

---

## VM-Konfiguration

Beide VMs wurden in VMware Workstation erstellt.

| Eigenschaft | Webserver (`crmweb`) | Datenbankserver (`crm-db`) |
|-------------|----------------------|---------------------------|
| OS | Ubuntu Server 22.04 LTS | Ubuntu Server 22.04 LTS |
| RAM | 2 GB | 2 GB |
| CPU | 2 vCores | 2 vCores |
| Disk | 30 GB | 30 GB |
| Adapter 1 | NAT (Internet) | NAT (Internet) |
| Adapter 2 | Host-only (intern) | Host-only (intern) |
| Interne IP | `10.10.20.10` | `10.10.20.11` |

---

## Grundinstallation

Nach der Ubuntu-Installation wurden beide Systeme aktualisiert:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install curl wget unzip net-tools -y
```

---

## Netzwerkkonfiguration

### Problem: Kein Internetzugang nach Installation

Nach dem ersten Start war der zweite Netzwerkadapter (NAT) nicht aktiv. Prüfung mit:

```bash
ip a
```

Ausgabe zeigte `ens37` als `DOWN`.

**Lösung – Netplan anpassen:**

```bash
sudo nano /etc/netplan/00-installer-config.yaml
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
```

Danach war das Interface aktiv und Internetverbindung vorhanden:

```bash
ping -c 3 8.8.8.8
# PING 8.8.8.8: 64 bytes from 8.8.8.8: icmp_seq=1 ttl=118 time=8.3 ms
```

### Problem: Interface bleibt DOWN nach Reboot

Beim nächsten Neustart war `ens37` wieder inaktiv.

**Ursache:** Das Interface wurde nicht persistent aktiviert.

**Lösung:** Netplan-Konfiguration mit `optional: true` und korrektem Interface-Namen:

```bash
ip link show
# → ens33, ens37
sudo nano /etc/netplan/00-installer-config.yaml
```

```yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true
      optional: true
    ens37:
      dhcp4: true
      optional: true
```

```bash
sudo netplan apply
sudo reboot
```

Nach Neustart beide Interfaces aktiv.

---

## SSH-Zugang einrichten

Für komfortables Arbeiten wurde SSH auf beiden VMs installiert und aktiviert:

```bash
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh
```

**Verbindungstest vom Host:**

```bash
ssh administrator@10.10.20.10
ssh administrator@10.10.20.11
```

Ab dann wurde die gesamte Konfiguration per SSH vorgenommen – keine Copy/Paste-Probleme mehr durch das VM-Terminal.

---

## Snapshot-Strategie

An folgenden Meilensteinen wurden VM-Snapshots erstellt:

| Snapshot | Zeitpunkt |
|----------|-----------|
| `base-install` | Nach Grundinstallation, vor jeder weiteren Konfiguration |
| `network-ok` | Nach erfolgreicher Netzwerkkonfiguration |
| `services-installed` | Nach Installation von Apache, PHP, MariaDB |
| `migration-done` | Nach erfolgreicher Migration, vor Go-Live |

Snapshots wurden über VMware Workstation erstellt: `VM → Snapshot → Take Snapshot`

---

## Verbindungstest zwischen VMs

Vom Webserver aus wurde die Erreichbarkeit des Datenbankservers getestet:

```bash
ping -c 3 10.10.20.11
# 64 bytes from 10.10.20.11: icmp_seq=1 ttl=64 time=0.42 ms
```

Verbindung steht. Damit ist die Basis für den nächsten Schritt (MariaDB-Installation und Verbindung) gegeben.

---

## Problem: Webserver und DB in unterschiedlichen Netzen

In einem ersten Versuch war der Webserver im Netz `172.x.x.x` und die DB im Netz `10.x.x.x`, weil die Host-only Adapter unterschiedlich konfiguriert waren.

**Ursache:** In VMware war für beide VMs ein anderes virtuelles Netzwerk ausgewählt.

**Lösung:** In VMware unter `VM → Settings → Network Adapter` bei beiden VMs denselben Host-only Adapter auswählen (`VMnet1` oder `VMnet2`). Danach waren beide VMs im selben Netz und konnten sich gegenseitig anpingen.
