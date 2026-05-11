# CSV harjutus — Mark L.

**Kursus:** KIT-24
**Õpetaja:** Toivo Pärnpuu
**Moodul:** csv, datetime

## Mida see kaust sisaldab

| Fail | Kirjeldus |
|---|---|
| `seadmete_analyys.py` | Põhiharjutus — loeb `seadmed.csv`, leiab probleemsed seadmed (vana uuendus, vähe ruumi, aegunud garantii), arvutab statistika osakondade kaupa ja kirjutab `probleemseadmed.csv`. |
| `seadmed_filter.py` | Lisaülesanded — Windows 10 filter, vähe ruumi sorteerimine kasvavalt, garantii lõppemine järgmise 6 kuu jooksul. |
| `seadmed.csv` | Lähteandmed — 15 seadme inventuur. |
| `probleemseadmed.csv` | Aruande fail, mille genereerib `seadmete_analyys.py` käivitamine. |
| `readme.md` | See fail. |

## Kuidas käivitada

Kaust sisaldab juba `seadmed.csv` faili, nii et skriptid töötavad otse:

```bash
# käivita põhiskript — see loob/uuendab probleemseadmed.csv
python seadmete_analyys.py

# käivita lisaülesannete skript
python seadmed_filter.py
```

## Mida skriptid teevad

### seadmete_analyys.py

1. Loeb `seadmed.csv` `csv.DictReader`-iga (iga rida sõnastikuna).
2. Filtreerib kolm probleemkategooriat:
   - **vana uuendus** — `viimane_uuendus` üle 365 päeva tagasi
   - **vähe kettaruumi** — vaba ruum alla 10 % kogumahust
   - **aegunud garantii** — `garantii_lõpp` enne tänast
3. Loendab seadmed osakondade kaupa ja arvutab keskmise vaba kettaruumi.
4. Kirjutab kõik leiud `probleemseadmed.csv`-sse veergudega `nimi, probleem, detail`.

### seadmed_filter.py

1. **Windows 10 filter** — kuvab seadmed, mille `os == "Windows 10"` (need vajavad uuendamist Windows 11-le).
2. **Vähe ruumi sorteerimine** — sama tingimus kui põhiskriptis, aga tulemus sorteeritud `key=lambda x: x[1]` järgi protsendi alusel kasvavalt (kõige hullem ette).
3. **Garantii 6 kuud** — loendab seadmed, mille garantii lõpeb vahemikus `[täna, täna + 183 päeva]`.

## Õpitud Pythoni vahendid

| Vahend | Kasutus |
|---|---|
| `csv.DictReader` / `csv.DictWriter` | CSV ridade lugemine/kirjutamine sõnastikena |
| `date.fromisoformat()` | teksti `"2024-11-03"` teisendamine kuupäevaks |
| `(d1 - d2).days` | päevade vahe kahe kuupäeva vahel |
| `timedelta(days=183)` | tulevikukuupäeva arvutamine |
| List comprehension | `[s for s in seadmed if ...]` |
| `sorted(..., key=lambda x: x[1])` | sorteerimine kohandatud võtme järgi |
