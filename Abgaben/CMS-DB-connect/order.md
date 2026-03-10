Erklärung der 9 Schritte (ohne DNS)
-----------------------------------

**User → Webserver**Der User gibt [**https://supercms.ch**](https://supercms.ch) im Browser ein. Der Browser sendet eine **HTTPS-Request (HTTP GET)** an den Webserver.

**Webserver → CMS-Dateien**Der Webserver (z. B. Apache/Nginx) prüft das Webroot/var/www/html/super-cms und sucht die angeforderte **PHP-Datei** (z. B. index.php).

**CMS-Datei → Webserver / PHP Interpreter**Die PHP-Datei wird durch den **PHP-Interpreter** ausgeführt. Dabei wird z. B. database.php oder mysqli-db-connect.php eingebunden.

**Webserver/PHP → DB-Server**Die PHP-Applikation baut über **MySQL/MariaDB (Port 3306)** eine Verbindung zum **DB-Server (192.168.22.10)** auf.

**DB-Server → Webserver/PHP**Der Datenbankserver verarbeitet die **SQL-Query** und sendet die **Ergebnisse (z. B. Artikel, Benutzer, Inhalte)** zurück.

**PHP → weitere CMS-Dateien**Das CMS lädt zusätzliche **Templates, Funktionen oder Module** aus dem Verzeichnis /var/www/html/super-cms.

**PHP verarbeitet Inhalte**Die Daten aus der **Datenbank** werden mit **HTML-Templates** kombiniert und zu einer fertigen **HTML-Seite** generiert.

**Webserver → User**Der Webserver sendet die fertige **HTML-Response über HTTPS** zurück an den Browser des Users.

**Browser → Webserver (weitere Requests)**Der Browser fordert zusätzlich **CSS, JavaScript, Bilder oder weitere Seiten** vom Webserver an.