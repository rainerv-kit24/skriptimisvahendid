from pathlib import Path
import csv
from datetime import datetime
import argparse

# Võimaldab kasutajal anda otsingukausta käsurealt (argparse)
parser = argparse.ArgumentParser(description="Leia suurimad failid kaustas")
parser.add_argument("kaust", nargs="?", help="Kaust, kust otsida (vaikimisi kodukaust)")
args = parser.parse_args()

if args.kaust:
    kodu = Path(args.kaust)
else:
    kodu = Path.home()

def vorminda_suurus(baidid):
    if baidid >= 1_073_741_824:          # 1 GB = 1024³ baiti
        return f"{baidid / 1_073_741_824:.1f} GB"
    elif baidid >= 1_048_576:            # 1 MB = 1024² baiti
        return f"{baidid / 1_048_576:.1f} MB"
    else:                                # KB
        return f"{baidid / 1024:.1f} KB"


failid = []

for fail in kodu.rglob("*"):
    try:
        if "AppData" in fail.parts:
            continue  # jäta AppData kaust vahele

        if fail.is_file():
            suurus = fail.stat().st_size
            failid.append((fail, suurus))
    except (PermissionError, FileNotFoundError):
        continue

failid_sorditud = sorted(
    failid,
    key=lambda x: x[1],                  # sorteeri faili suuruse järgi
    reverse=True                         # suurimast väikseimani
)[:10]                                   # võta 10 esimest

tulemus = []

valjund = Path("suurimad_failid.csv")

for fail, suurus in failid_sorditud:

    # faili viimase muutmise aeg
    muudetud = fail.stat().st_mtime
    muudetud_str = datetime.fromtimestamp(muudetud).strftime("%Y-%m-%d %H:%M")

    # Kui failinimes on @, siis peidame e-maili (nt Outlook .pst fail)
    # et vältida isikliku info sattumist CSV faili
    if "@" in fail.name:
        nimi_csv = "peidetud_email_fail" + fail.suffix
    else:
        nimi_csv = fail.name

    # Asendame ka tee sees failinime, et e-mail ei paistaks seal
    tee_csv = str(fail).replace(fail.name, nimi_csv)

    tulemus.append({
        "Tee": tee_csv,
        "Nimi": nimi_csv,
        "Suurus": vorminda_suurus(suurus),
        "Muudetud": muudetud_str
    })

with open(valjund, "w", newline="", encoding="utf-8") as f:
    kirjutaja = csv.DictWriter(f, fieldnames=["Tee", "Nimi", "Suurus", "Muudetud"])
    kirjutaja.writeheader()
    kirjutaja.writerows(tulemus)

print(f"Salvestatud: {valjund}")
