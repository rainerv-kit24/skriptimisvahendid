**ISESEISEV TÖÖ**
**Autor: Lauri Hallimäe**
**Kursus: KIT-24**
# Logianalüüsi skript (Python) (Ülesanne A)
**Failid: analyysi_logi.py, naidis_ps-alerts.log, analyys_paevad.csv, README.md**

## Kirjeldus
Skript loeb logifaili ja koostab kokkuvõtte:
- teadete koguarv
- õnnestunud ja ebaõnnestunud teated
- raskusastmete jaotus (Info, Warning, Critical)
- top allikad (hostid)
- kriitiliste teadete trend päevade lõikes

Lisaks salvestatakse tulemused CSV faili.

---

## ##Disainiotsused

### Andmestruktuurid
Kasutasin collections.Counter, et lugeda kokku staatused, raskusastmed ja hostid
Kasutasin defaultdict, et hoida päevapõhist statistikat ilma käsitsi kontrollideta
### Kuupäevade käsitlemine
Kuupäevad parsitakse datetime objektideks, mitte stringideks
See võimaldab korrektset sorteerimist ja ajavahemike arvutamist
### Vigade käsitlemine
Kui logifailis on vigane rida, skript ei katkesta tööd
Vigane rida logitakse konsooli ja jäetakse vahele
See on oluline päris logide töötlemisel, kus andmed ei pruugi alati olla puhtad
### ASCII-graafik
Kriitiliste teadete kuvamiseks kasutan lihtsat ASCII graafikut (█)
Iga märk tähistab ühte teadet
Kui teadet pole, kuvatakse "-"
See annab kiire visuaalse ülevaate trendist ilma graafikute teegita
### CSV-formaat
CSV sisaldab päevapõhist kokkuvõtet:
Päev
OK / FAIL
Info / Warning / Critical
Valisin lihtsa struktuuri, et faili saaks avada Excelis ja kasutada edasiseks analüüsiks
### Failitöötlus
Kasutan pathlib.Path, et kood oleks platvormist sõltumatu
Faili nimi saab anda käsurea argumendina (argparse)
### Tühja logi käsitlemine
Kui logifail on tühi või puudub, skript ei jookse kokku
Kuvatakse informatiivne teade

### Kasutus / Vaikimisi logifail:
Skripti saab käivitada käsurealt, andes ette logifaili nime. Vaikimisi kasutatakse faili naidis_ps-alerts.log

```bash
python analyysi_logi.py
#Käivitab analüüsi vaikimisi logifailiga.

python analyysi_logi.py naidis_ps-alerts.log
#Kasutab etteantud logifaili.

python analyysi_logi.py naidis_ps-alerts.log --csv tulemus.csv
#Salvestab tulemuse määratud CSV faili.

# ------------------------------------------------

# Serverite saadavuse monitor (PowerShell) (Ülesanne B)
**Failid: kontrolli-hostid.ps1, hostid.csv, saadavus_2026-05-05.csn, README.md**

## Kirjeldus

# Skript loeb CSV failist hostide nimekirja ja kontrollib nende saadavust.
# Kui port on määratud, tehakse TCP kontroll (Test-NetConnection), vastasel juhul ping (Test-Connection).

# Tulemused kuvatakse konsoolis ja salvestatakse CSV faili.

##Disainiotsused

### Kui port on olemas → kasutatakse TCP kontrolli (Test-NetConnection)
### Kui port puudub → kasutatakse pingi (Test-Connection)
### Vigane või kättesaamatu host ei katkesta skripti tööd
### Tulemused salvestatakse kuupäevaga CSV faili (saadavus_YYYY-MM-DD.csv)
### Konsoolis kuvatakse lihtne ja loetav tabel koos staatuse ja viivitusega

## Kasutus

```powershell
.\kontrolli-hostid.ps1
# Skripti saab käivitada PowerShellis. Vaikimisi kasutatakse faili hostid.csv.

.\kontrolli-hostid.ps1  
# Käivitab kontrolli vaikimisi sisendfailiga.

.\kontrolli-hostid.ps1 -InputFile muu_fail.csv  
# Kasutab etteantud CSV faili.

# Tulemused kuvatakse konsoolis ja salvestatakse CSV faili.

# ------------------------------------------------

# Kaustade puhastus skript (Bash) (Ülesanne C)
**Failid: puhasta.sh, test-andmed.sh, README.md**

## Kirjeldus

Skript leiab vanad failid, arhiveerib need ja kustutab originaalid.

## Kasutus

1. Kõigepealt kopeeri "puhastus.sh" ja "test-andmed.sh" failid oma seadmesse. (loo kaust näiteks "/c/tmp/test-puhastus") 

2. Järgmisena lood test andmed Git bashis

### Testandmete loomine, test puhastus ja kustutamine

```bash
./test-andmed.sh 
# Skripti saab käivitada Git bashis.

./puhasta.sh --dry-run /c/tmp/test-puhastus 7
# Teeb test puhastus(ei kustuta)

./puhasta.sh /c/tmp/test-puhastus 7
# Kustutab failid mis on vanemad kui 7 päeva!!!