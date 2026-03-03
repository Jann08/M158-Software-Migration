
# Übung Pfade

## Lokal

**Gegebene Verzeichnisstruktur:**

C:\Daten\Bilder <br>
C:\Daten\CSS<br>
C:\Daten\index.html<br>
C:\Daten\Bilder\Blume.jpg<br>
C:\Daten\Bilder\test.html<br>
C:\Daten\CSS\main.css


| Frage | Antwort |
|-------|---------|
| Absoluter Pfad von `main.css` | `C:\Daten\CSS\main.css` |
| Relativer Pfad von `index.html` zu `Blume.jpg` | `Bilder/Blume.jpg` |
| Absoluter Pfad von `main.css` zu `Blume.jpg` | `C:\Daten\Bilder\Blume.jpg` |
| Relativer Pfad von `main.css` zu `Blume.jpg` | `../Bilder/Blume.jpg` |
| Relativer Pfad von `test.html` zu `Blume.jpg` | `Blume.jpg` |

---

## Im Netz

**Gegeben:**
- Domain: `ihreadresse.ch`
- Lokaler Root-Pfad: `/srv/var/www/htdocs`
- Document Root: `/htdocs`
- Dateien:
  - `wp-content/uploads/2022/5/Dokument.pdf`
  - `wp-content/plugins/neon/files/download.php`

| Frage | Antwort |
|-------|---------|
| Lokaler Pfad zu `Dokument.pdf` | `/srv/var/www/htdocs/wp-content/uploads/2022/5/Dokument.pdf` |
| Absoluter Pfad zu `Dokument.pdf` | `/wp-content/uploads/2022/5/Dokument.pdf` |
| Lokaler Pfad zu `download.php` | `/srv/var/www/htdocs/wp-content/plugins/neon/files/download.php` |
| Absoluter Pfad zu `download.php` | `/wp-content/plugins/neon/files/download.php` |
| URL von `Dokument.pdf` | `https://ihreadresse.ch/wp-content/uploads/2022/5/Dokument.pdf` |
| URL von `download.php` | `https://ihreadresse.ch/wp-content/plugins/neon/files/download.php` |
| Relativer Pfad von `download.php` zu `Dokument.pdf` | `../../../uploads/2022/5/Dokument.pdf` |