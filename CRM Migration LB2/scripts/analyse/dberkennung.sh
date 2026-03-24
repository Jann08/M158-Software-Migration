# Lauernede MySQL/MariaDB Prozesse?
ps aux | grep -E "mysql|mariadb"
 
# Wenn MySQL läuft: Wo sind die Konfigurationsdateien?
mysql --help | grep "Default options" -A 1
 
# MySQL-Version und Datenbanken anzeigen (nur wenn MySQL läuft und du Zugang hast)
mysql -u root -p -e "SHOW DATABASES;"   # Du wirst nach dem Passwort gefragt
mysql -u root -p -e "SHOW VARIABLES LIKE 'version';"
 
# Falls PostgreSQL:
ps aux | grep postgres
sudo -u postgres psql -c "\l"   # Alle Datenbanken anzeigen