# Ülesanne D — Süsteemi inventuur

**Kursus:** KIT-24
**Keel:** Python
**Moodul:** `platform`, `psutil`, `socket`, `json`, `argparse`
**Raskusaste:** ★★☆ (keskmine) · **Aeg:** ~1–1.5 tundi

---

## Eesmärk

Kirjuta ristplatformne skript, mis kogub arvuti kohta teavet (operatsioonisüsteem, CPU, RAM, ketas, võrk) ja salvestab struktureeritud JSON-i. See on tüüpiline stsenaarium suurettevõttes — IT-osakond jooksutab seda kümnete arvutite peal ja saab ülevaate kogu pargi seisust.

---

## Tulemus

Skripti käivitus:

```bash
python inventuur.py
```

Konsoolis:

```
=== Süsteemi inventuur ===
Host:        desktop-toivo
Kasutaja:    toivo
OS:          Windows 11 (10.0.22631)
Python:      3.12.1

CPU:         Intel Core i7-1165G7 @ 2.80GHz
Südamikke:   4 (8 loogilist)
RAM:         16.0 GB (kasutuses 61%)

Kettad:
  C:\   Total: 476.9 GB  Free: 182.3 GB  (38% vaba)
  D:\   Total: 931.5 GB  Free: 812.1 GB  (87% vaba)

Võrgukaardid:
  Wi-Fi             192.168.1.47
  Ethernet          (ühendamata)

Salvestatud: inventuur_desktop-toivo_2026-04-21.json
```

JSON fail on detailsem — sisaldab kõik väljad ülevaatlikult:

```json
{
  "ajamäär": "2026-04-21T10:15:02Z",
  "host": "desktop-toivo",
  "kasutaja": "toivo",
  "os": {
    "süsteem": "Windows",
    "versioon": "10.0.22631",
    "release": "11",
    "arhitektuur": "64bit"
  },
  "python": "3.12.1",
  "cpu": {
    "mudel": "Intel(R) Core(TM) i7-1165G7 @ 2.80GHz",
    "südamikud_füüsilised": 4,
    "südamikud_loogilised": 8,
    "kasutus_protsent": 23.5
  },
  "mälu": {
    "kokku_gb": 16.0,
    "kasutuses_gb": 9.8,
    "vaba_gb": 6.2,
    "kasutus_protsent": 61.0
  },
  "kettad": [ ... ],
  "võrk": [ ... ]
}
```

---

## Nõuded

- Skript töötab **Windowsis, macOS-is ja Linuxis**
- JSON sisaldab kõik nõutud väljad (vaata tulemust üleval)
- Konsoolile prinditakse loetav kokkuvõte
- Väljundifaili nimi on automaatne: `inventuur_<hostname>_<kuupäev>.json`
- Argument `--väljund <fail>` võimaldab valida teistsuguse nime
- Argument `--stdout` prindib JSON-i konsooli (kasulik torustikus: `python inventuur.py --stdout | jq ...`)
- Võrgukaardid, mida pole ühendatud, on märgitud (mitte jäetud välja)

---

## Ettevalmistus

`psutil` pole Pythoniga kaasa, tuleb paigaldada:

```bash
pip install psutil
```

Kontrolli, kas paigaldus õnnestus:

```bash
python -c "import psutil; print(psutil.__version__)"
```

---

## Hea tava — checklist

- [ ] **Ristplatformsus** — skript testitud vähemalt kahel OS-il (või dokumenteeritud piirangud)
- [ ] **`argparse`** käsurea argumentide jaoks
- [ ] **Funktsioonid jagatud valdkondade järgi** — `kogu_cpu()`, `kogu_mälu()`, `kogu_kettad()` jne
- [ ] **`type hints`** funktsioonide parameetritel ja tagastustes
- [ ] **Docstring'id** — iga funktsiooni kohal
- [ ] **`try/except`** platvormi­spetsiifiliste kohtade ümber
- [ ] **JSON süvitusega** — `indent=2`, UTF-8
- [ ] **Ei krahši, kui psutil info puudub** — näita "teadmata"

---

## Samm-sammult

---

### Samm 1 — OS ja hosti info

**Mida vajad:** `platform` moodul, `socket.gethostname()`, `getpass.getuser()`.

<details>
<summary>Vihje</summary>

```python
import platform
import socket
import getpass
import sys

def kogu_os() -> dict:
    """Tagastab OS ja platvormi info."""
    return {
        "süsteem":      platform.system(),          # 'Windows', 'Linux', 'Darwin'
        "versioon":     platform.version(),
        "release":      platform.release(),
        "arhitektuur":  platform.architecture()[0], # '64bit'
        "masina_tüüp":  platform.machine(),         # 'AMD64', 'x86_64'
    }

def kogu_host() -> dict:
    return {
        "host":     socket.gethostname(),
        "kasutaja": getpass.getuser(),
        "python":   platform.python_version(),
    }
```

**Miks `Darwin`, mitte `macOS`?** Ajaloolised põhjused — macOS-i sisemine nimi on "Darwin" (aluseks BSD variant). Kui tahad kasutajale "macOS" näidata, tee see map ise:

```python
OS_NIMED = {"Darwin": "macOS", "Linux": "Linux", "Windows": "Windows"}
```

</details>

---

### Samm 2 — CPU info

<details>
<summary>Vihje</summary>

```python
import psutil

def kogu_cpu() -> dict:
    mudel = platform.processor()
    # Linuxis on platform.processor() sageli tühi — proovi lugeda /proc/cpuinfo
    if not mudel and platform.system() == "Linux":
        try:
            with open("/proc/cpuinfo") as f:
                for rida in f:
                    if rida.startswith("model name"):
                        mudel = rida.split(":", 1)[1].strip()
                        break
        except Exception:
            mudel = "Teadmata"

    return {
        "mudel":                 mudel or "Teadmata",
        "südamikud_füüsilised":  psutil.cpu_count(logical=False),
        "südamikud_loogilised":  psutil.cpu_count(logical=True),
        "kasutus_protsent":      psutil.cpu_percent(interval=1),
    }
```

`psutil.cpu_percent(interval=1)` blokeerib 1 sekundi, et saada õiget keskmist. Ilma interval'ita tagastab 0.0 esimesel kutsel.

</details>

---

### Samm 3 — mälu info

<details>
<summary>Vihje</summary>

```python
def kogu_mälu() -> dict:
    m = psutil.virtual_memory()

    return {
        "kokku_gb":        round(m.total / (1024**3), 2),
        "kasutuses_gb":    round(m.used / (1024**3), 2),
        "vaba_gb":         round(m.available / (1024**3), 2),
        "kasutus_protsent": m.percent,
    }
```

`1024**3` = 1 GB baitides. `round(..., 2)` — kaks kümnendkohta.

**Miks `m.available`, mitte `m.free`?** `free` on "vaba ja kasutamata", `available` on "kui palju saaks uus programm tegelikult kasutada" (võtab arvesse ka cache'i, mida saaks vabastada). Päris maailmas `available` on õige arv.

</details>

---

### Samm 4 — kettad

<details>
<summary>Vihje</summary>

```python
def kogu_kettad() -> list[dict]:
    kettad = []
    for osa in psutil.disk_partitions(all=False):
        try:
            kasutus = psutil.disk_usage(osa.mountpoint)
        except (PermissionError, OSError):
            continue  # mõnda ketast ei pruugi saada lugeda

        kettad.append({
            "haakepunkt":       osa.mountpoint,
            "seade":            osa.device,
            "failisüsteem":     osa.fstype,
            "kokku_gb":         round(kasutus.total / (1024**3), 2),
            "vaba_gb":          round(kasutus.free / (1024**3), 2),
            "kasutatud_gb":     round(kasutus.used / (1024**3), 2),
            "kasutus_protsent": kasutus.percent,
        })
    return kettad
```

`all=False` — jätab välja virtuaalsed failisüsteemid (Linuxis `/proc`, `/sys` jne). `True` oleks liiga palju müra.

</details>

---

### Samm 5 — võrgukaardid

<details>
<summary>Vihje</summary>

```python
def kogu_võrk() -> list[dict]:
    kaardid = []
    aadressid = psutil.net_if_addrs()
    olek      = psutil.net_if_stats()

    for nimi, adrlist in aadressid.items():
        ipv4 = next(
            (a.address for a in adrlist if a.family == socket.AF_INET and not a.address.startswith("127.")),
            None
        )
        on_üleval = olek[nimi].isup if nimi in olek else False

        kaardid.append({
            "nimi":      nimi,
            "ipv4":      ipv4,
            "ühendatud": on_üleval,
        })
    return kaardid
```

`next((expr for x in ... if cond), None)` on muster "leia esimene sobiv või tagasta `None`". Lühem kui `for + break`.

**Miks filtreerida `127.`?** Loopback on igal masinal, ei ole infomatsiooni. Sa võid seda dokumenteerida ja jätta alles — disaini­otsus.

</details>

---

### Samm 6 — pane kõik kokku

<details>
<summary>Vihje — peafunktsioon</summary>

```python
import json
import argparse
from datetime import datetime, timezone
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(description="Süsteemi inventuur")
    parser.add_argument("--väljund", help="JSON-fail (vaikimisi automaatselt)")
    parser.add_argument("--stdout", action="store_true",
                        help="Prindi JSON konsooli, ära salvesta faili")
    args = parser.parse_args()

    inventuur = {
        "ajamäär":  datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        **kogu_host(),
        "os":       kogu_os(),
        "cpu":      kogu_cpu(),
        "mälu":     kogu_mälu(),
        "kettad":   kogu_kettad(),
        "võrk":     kogu_võrk(),
    }

    if args.stdout:
        print(json.dumps(inventuur, indent=2, ensure_ascii=False))
        return

    # kokkuvõte konsoolile
    prindi_kokkuvote(inventuur)

    # salvesta JSON
    if args.väljund:
        fail = Path(args.väljund)
    else:
        kp = datetime.now().strftime("%Y-%m-%d")
        fail = Path(f"inventuur_{inventuur['host']}_{kp}.json")

    fail.write_text(json.dumps(inventuur, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"\nSalvestatud: {fail}")

if __name__ == "__main__":
    main()
```

`**kogu_host()` — sõnastiku "lahti­pakkimine" teise sõnastiku sisse. Nii saab `host`, `kasutaja`, `python` kõik samasse tasemesse.

</details>

---

## Mida sa õppisid

| Käsk / muster | Tähendus |
|---|---|
| `platform.system()` | 'Windows', 'Linux', 'Darwin' |
| `psutil.cpu_count(logical=False)` | Füüsilised südamikud |
| `psutil.virtual_memory()` | Mälu info |
| `psutil.disk_partitions()` | Kettad / haakepunktid |
| `psutil.net_if_addrs()` | Võrgukaartide IP-d |
| `datetime.now(timezone.utc)` | UTC-ajamäär (oluline logide puhul) |
| `json.dumps(..., ensure_ascii=False)` | JSON Unicode-ga (täpitähed) |
| `**sõnastik` | Lahti­pakkimise operaator |
| `next((x for x in ... if ...), None)` | "Leia esimene või vaikimisi" |

---

## Lisaküsimused (valikuline)

1. **Paigaldatud tarkvara Windowsis.** Kuidas lugeda registrist (nagu tegime ID-tarkvara harjutuses)? Lisa JSON-i väli "paigaldatud_tarkvara".
2. **Avatud pordid.** `psutil.net_connections()` tagastab praegu avatud võrguühendused. Lisa JSON-i "kuulavad_pordid" — ainult `status == 'LISTEN'`.
3. **Ajalugu.** Kui sama skript jookseb iga päev, saad ajaloo. Tee teine skript (`vordle_inventuurid.py`), mis võtab kaks JSON-i ja näitab muudatusi (nt "C: ketas vabanes 15 GB", "RAM kasvas 16→32 GB").
4. **HTML-raport.** Sama andmed, aga ilus HTML-fail. Kui tahad kiireimat rada — `json2html` pakett.

---

## Esitamine

```
tulemused/Eesnimi_P/
├── inventuur.py
├── inventuur_<hostname>_<kp>.json   <- näidisväljund
├── requirements.txt                  <- psutil==X.Y.Z
└── README.md
```

`README.md`-s dokumenteeri:

- Millisel OS-il testisid (Windows / macOS / Linux)?
- Millised väljad õnnestusid kõigil platvormidel?
- Millised kohad olid platvormi­spetsiifilised ja kuidas said üle?
