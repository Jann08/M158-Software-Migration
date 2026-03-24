# Betriebssystem, Kernel und Architektur (zeigt CentOS 6.6)
cat /etc/redhat-release
uname -a
 
# CPU-Informationen (Anzahl Kerne, Modell)
lscpu
cat /proc/cpuinfo | grep "model name" | head -1
 
# Arbeitsspeicher (Gesamt, belegt, frei)
free -m
 
# Festplatten und Partitionen
df -h
fdisk -l | grep "Disk /dev"