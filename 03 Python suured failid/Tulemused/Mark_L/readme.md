# Suured failid harjutus — Mark L.

**Kursus:** KIT-24
**Õpetaja:** Toivo Pärnpuu
**Moodul:** pathlib, csv, argparse, datetime

## Mida see kaust sisaldab

| Fail | Kirjeldus |
|---|---|
| `suurimad_failid.py` | Skript, mis leiab 10 kõige suuremat faili. |
| `suurimad_failid.csv` | Skripti väljund — top 10 koos teega, suuruse ja muutmise kuupäevaga. |
| `readme.md` | See fail. |

## Kuidas käivitada

```bash
cd "03 Python suured failid\Tulemused\Mark_L"

# Vaikimisi: otsi kasutaja kodukaustast, AppData välja jäetud
python suurimad_failid.py

# Otsi konkreetsest kaustast
python suurimad_failid.py C:\Users\Mark\Downloads

# Kaasa ka AppData (mis vaikimisi välja jääb)
python suurimad_failid.py --lisa-appdata
```

CSV salvestatakse alati skripti kõrvale (`suurimad_failid.csv`), olenemata sellest, kust skript käivitati.

## Mida skript teeb (samm-sammult)

1. **Loeb käsurea argumendid** — `argparse` abil. Vaikimisi otsingukoht on `Path.home()`, vabatahtlik lipp `--lisa-appdata` lülitab AppData filtri välja.
2. **Otsib rekursiivselt** kõik failid `rglob("*")`-iga, jättes vahele:
   - kaustad (`is_file()` kontroll),
   - failid millele puudub ligipääs (`PermissionError` / `OSError`),
   - kõik mis asub `AppData` kaustas (`"AppData" in fail.parts`).
3. **Sorteerib** suuruse järgi kahanevalt: `sorted(..., key=lambda f: f.stat().st_size, reverse=True)`.
4. **Võtab esimesed 10** lõikamisega `[:10]`.
5. **Vormindab suuruse** loetavasse ühikusse (GB / MB / KB) abifunktsiooniga `vorminda_suurus()`.
6. **Lisab muutmise kuupäeva** `datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d")` abil.
7. **Kirjutab CSV** `csv.DictWriter`-iga, veerud: `Tee, Nimi, Suurus, Muudetud`.

## Lahendatud lisaülesanded

| Lisaülesanne | Kus koodis |
|---|---|
| AppData välistamine | funktsioon `on_appdatas(fail)` — kontrollib `fail.parts` sisu |
| Muudetud kuupäev | `stat.st_mtime` → `datetime.fromtimestamp(...).strftime("%Y-%m-%d")` |
| Argparse otsingukoht | funktsioon `loe_argumendid()` — positsiooniline arg `kaust` ja lipp `--lisa-appdata` |

## Õpitud Pythoni vahendid

| Vahend | Kasutus |
|---|---|
| `Path.home()` | kasutaja kodukaust |
| `Path.rglob("*")` | rekursiivne faililoend |
| `fail.is_file()` | kontroll, kas tegu on failiga |
| `fail.stat().st_size` | faili suurus baitides |
| `fail.stat().st_mtime` | viimase muutmise aeg (Unix timestamp) |
| `fail.parts` | tee tükkideks (kaustanimede tuple) |
| `sorted(..., key=lambda, reverse=True)` | sorteerimine kohandatud võtme järgi |
| `[:10]` | võta esimesed 10 elementi |
| `Path.mkdir(parents=True, exist_ok=True)` | loo kaust |
| `Path(__file__).parent` | skripti enda asukoha kaust |
| `argparse.ArgumentParser` | käsurea argumentide lugemine |
| `try/except PermissionError, OSError` | vigade graatsiline käsitlemine |
