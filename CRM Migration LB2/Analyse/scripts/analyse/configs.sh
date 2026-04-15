# Netzwerk
cat /etc/sysconfig/network-scripts/ifcfg-eth0  # (Name anpassen)
 
# Firewall-Regeln (CentOS 6)
iptables -L -n -v
cat /etc/sysconfig/iptables
 
# Hosts-Datei
cat /etc/hosts
 
# Automatisch gemountete Laufwerke
cat /etc/fstab