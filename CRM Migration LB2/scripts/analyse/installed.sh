# Alle installierten Pakete auflisten
rpm -qa | sort
 
# Nach bestimmten Paketen suchen (z.B. Datenbanken, Webserver)
rpm -qa | grep -E "mysql|mariadb|postgresql|httpd|nginx|php|tomcat"
 
# Yum-Repositories, die konfiguriert sind
yum repolist