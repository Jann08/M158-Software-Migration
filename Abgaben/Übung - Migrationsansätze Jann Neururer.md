# Übung - Migrationsansätze

**Name:** Jann Neururer  
**Datum:** 03.03.2026 
**Kurs:** M158  

---

## 1. Ausgangslage

- **Quelle:** Einzelner ESXi Host (ESXI-07, 10.80.10.5) im Labor.
- **Ziel:** ESXi Cluster CL-01 (Nodes: 10.80.12.1/2/4) in der E4-Zone.
- **Workload:** 2 CAD-VMs, aktuell ohne Hochverfügbarkeit.

**Ziel der Migration:**  
Überführung der beiden CAD-VMs in die hochverfügbare Cluster-Umgebung.

---

## 2. Migrationsansatz

**Gewählter Ansatz:** Lift-and-Shift (Rehosting)

### Begründung:

- **Technische Kompatibilität:** VMware zu VMware – keine Plattformwechsel.
- **Minimales Risiko:** Keine Änderungen an OS oder Applikationen (CAD-Software).
- **Effizienz:** Schnellste Methode mit überschaubarem Aufwand.

**Verworfen:**
- **Big Bang:** zu riskant.
- **Refactor/Rebuild:** unverhältnismässiger Aufwand.

---

## 3. Migrationsplan

### Detaillierte Schritte

#### Phase 1: Vorbereitung & Analyse

1. **Inventur:** Ressourcen der 2 CAD-VMs erfassen (CPU, RAM, Disk, Netzwerk).
2. **Kapazitätscheck:** Prüfen, ob Cluster CL-01 genügend freie Ressourcen hat.
3. **Netzwerk klären:** IP-Konzept (neue IPs oder Layer-2-Strecke)? Mit Netzzuständigkeit abstimmen.
4. **Tool-Auswahl:** Migration via VMware vMotion oder simpler Export/Import.
5. **Backup:** Vollständiges Backup der VMs erstellen (Murphy Rules).

#### Phase 2: Migration

6. **Kommunikation:** Wartungsfenster an CAD-Benutzer kommunizieren (z.B. Fr. ab 18:00).
7. **Snapshot-Check:** Alte Snapshots konsolidieren.
8. **Konnektivitätstest:** Quell-Host (10.80.10.5) zu Ziel-Cluster (10.80.12.0/24) testen.
9. **Transfer:** VMs migrieren (vMotion oder Export/Import).
10. **Netzwerk-Anbindung:** VMs in korrekte Portgruppen/VLANs einhängen.

#### Phase 3: Test & Abschluss

11. **Grundfunktion testen:** Einschalten, Ping, RDP/SSH prüfen.
12. **Anwendungstest:** CAD-Benutzer testen die Software (Freigabe erteilen).
13. **Abschluss:** Dokumentation aktualisieren, alte VMs auf ESXI-07 deaktivieren.
14. **Aufräumen:** Alten Host ESXI-07 ggf. freigeben oder stilllegen.

---

## 4. Fazit

Die Migration erfolgt mittels **Lift-and-Shift**. Dies gewährleistet eine schnelle, risikoarme Überführung der CAD-VMs in den Cluster. Der 14-Schritte-Plan stellt einen strukturierten Ablauf mit minimalen Ausfallzeiten sicher.