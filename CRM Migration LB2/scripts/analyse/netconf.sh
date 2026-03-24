# IP-Adressen der Netzwerkschnittstellen
ip addr show
# oder (älterer Befehl, aber oft noch vorhanden)
ifconfig
 
# Routing-Tabelle (Standard-Gateway)
ip route show
route -n
 
# DNS-Konfiguration
cat /etc/resolv.conf
 
# Hostname
hostname
cat /etc/sysconfig/network