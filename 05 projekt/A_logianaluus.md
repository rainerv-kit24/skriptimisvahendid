# Ülesanne A — Logianalüüsi skript

**Kursus:** KIT-24
**Keel:** Python
**Moodul:** `csv`, `collections`, `datetime`, `argparse` (kõik Pythoniga kaasa)
**Raskusaste:** ★★☆ (keskmine) · **Aeg:** ~1 tund

---

## Eesmärk

Eelmises harjutuses ehitatud teavituste moodul kirjutab iga saatmise kohta rea logifaili:

```
2026-04-15 14:22:01 [OK]	Info	DESKTOP-42	Teenus käivitus
2026-04-15 14:22:05 [OK]	Warning	DESKTOP-42	Ketas 85% täis
2026-04-16 09:01:33 [FAIL]	Critical	DC01	Teenus maas	Unable to connect
...
```

Nüüd selle logi peal ehitad analüüsi­skripti. See on päris IT-admin töö: vaadata, mis toimus nädala jooksul, **kust** teated tulid, **kui tihti** kriitilisi juhtumeid oli.

---

## Näidissisend

Loo endale test-logifail. Näidis (kopeeri oma kausta `ps-alerts.log`):

```
2026-04-14 08:00:00	[OK]	Info	DESKTOP-42	Skript käivitus
2026-04-14 14:22:05	[OK]	Warning	DESKTOP-42	Ketas 85% täis
2026-04-14 23:15:22	[OK]	Critical	DC01	Teenus kinni jooksnud
2026-04-15 02:33:11	[FAIL]	Critical	DC01	Teenus endiselt maas	Timeout
2026-04-15 08:01:30	[OK]	Info	DESKTOP-42	Skript käivitus
2026-04-15 14:55:02	[OK]	Warning	LAPTOP-07	Aku 15%
2026-04-16 08:00:45	[OK]	Info	DESKTOP-42	Skript käivitus
2026-04-16 09:15:10	[OK]	Warning	DC01	Ketas täitub kiiresti
2026-04-16 15:30:00	[OK]	Critical	DC01	Ketas täis!
2026-04-17 08:02:11	[OK]	Info	DESKTOP-42	Skript käivitus
```

Kui sul on oma päris logifail `ps-alerts.log` olemas (eelmise harjutuse moodulilt), kasuta hoopis seda.

---

## Tulemus

Skript `analyysi_logi.py` annab kahte laadi väljundit:

**1. Konsooli — kokkuvõte:**

```
Periood:      2026-04-14 kuni 2026-04-17 (4 päeva)
Teadeid kokku: 10
  ├─ õnnestus:  9
  └─ ebaõnnestus: 1

Raskusaste:
  Info:     3
  Warning:  4
  Critical: 3

Top allikad:
  1. DESKTOP-42 — 4 teadet
  2. DC01       — 4 teadet
  3. LAPTOP-07  — 1 teade

Critical teated päeva lõikes:
  2026-04-14: ██ (1)
  2026-04-15: ██ (1)
  2026-04-16: ██ (1)
  2026-04-17: - (0)
```

**2. CSV-i — detailsemalt:**

Fail `analyys_paevad.csv`:

```
Päev,Teateid kokku,Info,Warning,Critical,Ebaõnnestunud
2026-04-14,3,1,1,1,0
2026-04-15,3,1,1,1,1
2026-04-16,3,1,1,1,0
2026-04-17,1,1,0,0,0
```

---

## Nõuded

- Sisendi logi­fail antakse käsurea argumendina (vaikimisi `ps-alerts.log`)
- Kokkuvõte prinditakse konsooli
- CSV salvestatakse — vaikimisi `analyys_paevad.csv`, ümber­seadistatav argumendiga
- Ajakonnad parsitakse kuupäevadeks (`datetime`) — mitte stringideks
- Kui logifailis on vigaseid ridu, skript **ei jookse kokku** — logib need ja jätkab
- Skript töötab ka tühja logifailiga (annab mõistliku teate)

---

## Hea tava — checklist

- [ ] **`argparse`** — mitte `sys.argv[1]`
- [ ] **`pathlib.Path`** — mitte string­ide liitmine
- [ ] **`collections.Counter`** või `defaultdict` — mitte käsitsi sõnastike ehitamine
- [ ] **`datetime`-tüüp** — kuupäevad on *kuupäevad*, mitte stringid
- [ ] **Vead ei katkesta** — rikutud rida logitakse ja jätkatakse
- [ ] **Funktsioonid jagatud** — lugemine / analüüs / väljundi vormindamine on eraldi
- [ ] **Kommentaarid / docstring'id** — iga funktsiooni kohal on selgelt, mida see teeb
- [ ] **Tühja juhtum** — kui logi on tühi, skript ei jookse kokku

---

## Samm-sammult

Vihjed on `<details>` taga — ava alles kui jääd kinni. Dokumentatsiooni lugemine on osa tööst.

---

### Samm 1 — parsi üks logi­rida

Logi formaat on tabulaatoriga eraldatud:

```
AJATEMPEL\t[STAATUS]\tSEVERITY\tALLIKAS\tSÕNUM[\tVIGA]
```

Kirjuta funktsioon `parse_rida(tekst) -> dict | None`, mis võtab stringi ja tagastab sõnastiku (või `None`, kui rida on vigane).

<details>
<summary>Vihje</summary>

```python
from datetime import datetime

def parse_rida(rida: str) -> dict | None:
    """Parsib ühe logirea sõnastikuks. Vigase rea puhul tagastab None."""
    osad = rida.strip().split("\t")

    if len(osad) < 5:
        return None  # liiga vähe välju

    ajatempel, staatus, severity, allikas, sõnum, *veateade = osad

    try:
        aeg = datetime.strptime(ajatempel, "%Y-%m-%d %H:%M:%S")
    except ValueError:
        return None  # halb kuupäevaformaat

    return {
        "aeg":      aeg,
        "staatus":  staatus.strip("[]"),
        "severity": severity,
        "allikas":  allikas,
        "sõnum":    sõnum,
        "viga":     veateade[0] if veateade else None,
    }
```

`*veateade` on Pythoni "kogu ülejäänud" süntaks — kui veateade puudub, on see tühi list.

</details>

---

### Samm 2 — loe kogu fail ja jäta vigased read välja

**Mida vajad:** `Path.read_text()` või tsükkel, `list comprehension` või `filter`.

<details>
<summary>Vihje</summary>

```python
def loe_logi(tee: Path) -> list[dict]:
    if not tee.exists():
        raise FileNotFoundError(f"Logifail puudub: {tee}")

    vigased = 0
    teated = []

    for rida in tee.read_text(encoding="utf-8").splitlines():
        if not rida.strip():
            continue  # tühi rida
        parsed = parse_rida(rida)
        if parsed:
            teated.append(parsed)
        else:
            vigased += 1

    if vigased:
        print(f"Hoiatus: {vigased} rida ei suutnud parsida")

    return teated
```

Miks `read_text().splitlines()`, mitte `for rida in open(...)`? Väiksemate logifailide puhul lihtsam, ei pea `with`-plokki haldama. Suurte failide puhul (üle 100 MB) kasutaks streamimist.

</details>

---

### Samm 3 — liigita teated päevade ja kategooriate järgi

**Mida vajad:** `collections.Counter` või `defaultdict`.

<details>
<summary>Vihje</summary>

```python
from collections import Counter, defaultdict

def analuusi(teated: list[dict]) -> dict:
    if not teated:
        return {"periood": None, "kokku": 0, "paevad": {}}

    paevad = defaultdict(lambda: Counter())

    for t in teated:
        paev = t["aeg"].date()
        paevad[paev][t["severity"]] += 1
        paevad[paev]["_kokku"] += 1
        if t["staatus"] == "FAIL":
            paevad[paev]["_fail"] += 1

    return {
        "esimene": min(t["aeg"] for t in teated).date(),
        "viimane": max(t["aeg"] for t in teated).date(),
        "kokku":   len(teated),
        "paevad":  dict(paevad),
        "allikad": Counter(t["allikas"] for t in teated),
        "severity": Counter(t["severity"] for t in teated),
        "ebaõnnestumisi": sum(1 for t in teated if t["staatus"] == "FAIL"),
    }
```

`defaultdict(lambda: Counter())` tähendab: kui küsid võtit, mida pole, saad automaatselt uue `Counter()`-i. Hoiab koodi lühikesena.

</details>

---

### Samm 4 — prindi konsooli kokkuvõte

Näpista näidis­väljundi formaati pealtpoolt. ASCII-graafik (`██`) critical-teadete kohta on vabas vormis — piisab, kui näitad visuaalselt, kellel kõige rohkem on.

<details>
<summary>Vihje — ASCII-graafik</summary>

```python
def ascii_riba(arv: int, max_arv: int, laius: int = 20) -> str:
    if max_arv == 0:
        return ""
    pikkus = int(round(arv / max_arv * laius))
    return "█" * pikkus + (f" ({arv})" if arv else " -")
```

Või lihtsamalt — iga kriitilise teate kohta üks `██`:

```python
riba = "██" * arv if arv else "-"
```

Kumba eelistad? Teine on lihtsam, esimene skaleerub paremini suurte numbrite korral.

</details>

---

### Samm 5 — salvesta CSV

**Mida vajad:** `csv.DictWriter`, `newline=""`, `encoding="utf-8"`.

<details>
<summary>Vihje</summary>

```python
import csv

def salvesta_csv(tulemus: dict, tee: Path) -> None:
    with open(tee, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["Päev", "Teateid kokku", "Info", "Warning", "Critical", "Ebaõnnestunud"])

        for paev in sorted(tulemus["paevad"]):
            p = tulemus["paevad"][paev]
            w.writerow([
                paev,
                p.get("_kokku", 0),
                p.get("Info", 0),
                p.get("Warning", 0),
                p.get("Critical", 0),
                p.get("_fail", 0),
            ])
```

`sorted(tulemus["paevad"])` sorteerib kuupäevi loomulikult, sest nad on `date`-objektid (mitte stringid — **sama komistus­kivi kui versiooni­võrdluses!**).

</details>

---

### Samm 6 — pane kokku `argparse`-iga

<details>
<summary>Vihje — skripti karkass</summary>

```python
import argparse
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(description="Analüüsi teavituste logifaili")
    parser.add_argument("logi", nargs="?", default="ps-alerts.log",
                        help="Logifail (vaikimisi ps-alerts.log)")
    parser.add_argument("--väljund", default="analyys_paevad.csv",
                        help="CSV-väljundfail")
    args = parser.parse_args()

    teated = loe_logi(Path(args.logi))
    tulemus = analuusi(teated)
    prindi_kokkuvote(tulemus)
    salvesta_csv(tulemus, Path(args.väljund))
    print(f"\nCSV salvestatud: {args.väljund}")

if __name__ == "__main__":
    main()
```

`if __name__ == "__main__":` on Pythonis oluline muster — selle koodi ainult käivitatakse, kui skripti käivitatakse otse, mitte kui keegi impordib selle oma koodis. Tähelepanu­väärne hea tava.

</details>

---

## Mida sa õppisid

| Mõiste | Tähendus |
|---|---|
| `datetime.strptime()` | Stringist `datetime`-objekt |
| `collections.Counter` | Elementide lugemine / grupeerimine |
| `collections.defaultdict` | Sõnastik vaikeväärtustega |
| `list comprehension` + `if` | Filtreerimine ja teisendus ühes |
| `Path.read_text()` | Kogu faili lugemine tekstina |
| `csv.DictWriter` / `csv.writer` | CSV kirjutamine õigete tsitaatidega |
| `*rest` unpacking | "Kogu ülejäänud" stringi lahti­võtmisel |
| `if __name__ == "__main__"` | Impordi-ohutu skripti käivitus |

---

## Lisaküsimused (valikuline)

1. **Filter ajavahemikuna.** Lisa argumendid `--alates` ja `--kuni` (kuupäevad). Kasulik suurte logide puhul.
2. **HTML-raport.** Sama tulemus, aga HTML-faili (koos CSS-iga). Saab brauseris avada.
3. **Anomaaliate tuvastus.** Kui ühel päeval on teadeid rohkem kui 3× keskmisest, tähista see. Uuri `statistics.mean()` ja `statistics.stdev()`.
4. **Loe mitu logifaili korraga.** `nargs="+"` argpars'is. Kasulik, kui logid rotaatoriga (ps-alerts.log, ps-alerts.log.1 jne).

---

## Esitamine

Fail `analyysi_logi.py` oma kausta. Kohustuslik ka `README.md`, mis kirjutab käivitamise ja valitud disaini­otsused (nt ASCII-graafiku stiil, CSV-formaat).

```
tulemused/Eesnimi_P/
├── analyysi_logi.py
├── näidis_ps-alerts.log        <- test-sisend
├── analyys_paevad.csv          <- näidisväljund
└── README.md
```
