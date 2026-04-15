# Vorgehensweise: CRM-Migration

**Projekt:** CRM-Migration
**Datum:** 24.03.2026  
**Version:** 1.0

## Export dateien beschaffen:
Ich habe die Analyse begonnen mit dem einloggen auf der VM.
```
Login Root
Passwort 123456
```

Ich habe mich eine weile auf der Umgebung umgeschaut und danach begonnen mit Google und KI Scripte zu finden wie ich diesen Prozess vereinfachen kann und mir die wichtigsten logs, configs und Daten die auf der VM sind mir anzuzeigen. Bevor ich begonnen habe die Scripts auszuführen habe ich micht mit diesem command per ssh eingeloggt:
```
ssh -p 2222 root@localhost -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa
```
Als ich mit ssh auf der VM eingellogt war habe ich mit der Richtigen Systemanalyse begonnen. Ich habe die Logs die ich als ergebniss bekommen habe in diesem Ordner unter logs abgelegt und die Scripts unter dem Ordner scripts.