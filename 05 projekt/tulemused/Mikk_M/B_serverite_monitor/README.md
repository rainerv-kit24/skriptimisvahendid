# Serverite saadavuse monitor (kontrolli-hostid.ps1)

## Eesmärk

Skript kontrollib mitme hosti saadavust ning loob:
- konsooli kokkuvõtte (OK / FAIL + latency)
- CSV faili ajatempli põhjal
- võrgu kontrolli nii ICMP kui TCP kaudu

---

## Käivitamine

```powershell
.\kontrolli-hostid.ps1