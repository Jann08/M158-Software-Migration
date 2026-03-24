# Alle laufenden Prozesse anzeigen
ps aux
 
# Alle konfigurierten Dienste und ihr Status (CentOS 6 typisch)
chkconfig --list | grep "3:on"  # Dienste, die im Runlevel 3 (Mehrbenutzer-Modus) starten
 
# Status einzelner wichtiger Dienste (Beispiele - passe sie an)
service httpd status        # Apache Webserver
service mysqld status       # MySQL Datenbank
service mariadb status      # MariaDB Datenbank (falls installiert)
service postgresql status   # PostgreSQL Datenbank
service sshd status         # SSH (hast du ja schon)
 
# Auf welchen Ports wird gelauscht?
netstat -tulpn
ss -tulpn