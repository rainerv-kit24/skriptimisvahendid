#!/usr/bin/env python3

#ps-alerts logi analüsaator
#Formaat: AJATEMPEL\t[STAATUS]\tSEVERITY\tALLIKAS\tSÕNUM[\tVIGA]
#Kasutus: python analyys.py [logifail] [--csv väljund.csv]


import argparse
import csv
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path


LOG_AJAVORMING = "%Y-%m-%d %H:%M:%S"


def parse_args():
    p = argparse.ArgumentParser(description="Analüüsib ps-alerts logifaili")
    p.add_argument("logifail", nargs="?", default="ps-alerts.log",
                   help="Logifail (vaikimisi: ps-alerts.log)")
    p.add_argument("--csv", default="analyys_paevad.csv",
                   dest="csv_väljund",
                   help="CSV väljundfail (vaikimisi: analyys_paevad.csv)")
    return p.parse_args()


def loe_logi(tee: Path):
 
#    Loeb logifaili ja tagastab (kirjed, vigased_read) tuple.

    kirjed = []
    vigased = []

    read = tee.read_text(encoding="utf-8", errors="replace").splitlines()

    if not any(r.strip() for r in read):
        return kirjed, vigased  # tühi fail

    for nr, rida in enumerate(read, start=1):
        rida = rida.strip()
        if not rida:
            continue

        osad = rida.split("\t")

        # Minimaalselt 5 välja: AJATEMPEL, STAATUS, SEVERITY, ALLIKAS, SÕNUM
        if len(osad) < 5:
            vigased.append((nr, rida, f"Liiga vähe välju — oodatakse 5+, saadi {len(osad)}"))
            continue

        # Ajatempel
        try:
            aeg = datetime.strptime(osad[0].strip(), LOG_AJAVORMING)
        except ValueError as e:
            vigased.append((nr, rida, f"Kuupäeva viga: {e}"))
            continue

        # Staatus — eemaldame nurksulud ümbert, nt "[OK]" -> "OK"
        staatus = osad[1].strip().strip("[]")

        kirjed.append({
            "aeg":      aeg,
            "kuupäev":  aeg.date(),
            "staatus":  staatus,
            "severity": osad[2].strip().upper(),
            "allikas":  osad[3].strip(),
            "sõnum":    osad[4].strip(),
            "viga":     osad[5].strip() if len(osad) >= 6 else "",
        })

    return kirjed, vigased


def analüüsi(kirjed: list) -> dict:
  #Grupeerib kirjed päevade ja severity kaupa, kogub allikad.
    paevad: dict = defaultdict(lambda: defaultdict(int))
    allikad: dict = defaultdict(int)
    õnnestus = 0
    ebaõnnestus = 0

    for k in kirjed:
        paevad[k["kuupäev"]][k["severity"]] += 1
        paevad[k["kuupäev"]]["KOKKU"] += 1
        allikad[k["allikas"]] += 1
        if k["staatus"].upper() in ("OK", "OK"):
            õnnestus += 1
        else:
            ebaõnnestus += 1

    return {
        "paevad":      paevad,
        "allikad":     allikad,
        "õnnestus":    õnnestus,
        "ebaõnnestus": ebaõnnestus,
    }


def prindi_kokkuvõte(andmed: dict, vigased: list, kirjed: list):
    paevad     = andmed["paevad"]
    allikad    = andmed["allikad"]
    õnnestus   = andmed["õnnestus"]
    ebaõnnestus = andmed["ebaõnnestus"]
    kokku      = õnnestus + ebaõnnestus

    if not paevad:
        print("Logifailis pole ühtegi kehtivat kirjet.")
        return

    sorditud_paevad = sorted(paevad)
    algus  = sorditud_paevad[0]
    lõpp   = sorditud_paevad[-1]
    päevi  = (lõpp - algus).days + 1

    # Periood ja üldstatistika
    print(f"\nPeriood:      {algus} kuni {lõpp} ({päevi} päeva)")
    print(f"Teadeid kokku: {kokku}")
    print(f"  ├─ õnnestus:    {õnnestus}")
    print(f"  └─ ebaõnnestus: {ebaõnnestus}")

    # Raskusaste
    info     = sum(paevad[p].get("INFO",     0) for p in paevad)
    warning  = sum(paevad[p].get("WARNING",  0) for p in paevad)
    critical = sum(paevad[p].get("CRITICAL", 0) for p in paevad)
    print("Raskusaste:")
    print(f"  Info:     {info}")
    print(f"  Warning:  {warning}")
    print(f"  Critical: {critical}")

    # Top allikad
    top = sorted(allikad.items(), key=lambda x: x[1], reverse=True)[:5]
    print("Top allikad:")
    for i, (allikas, arv) in enumerate(top, 1):
        teade = "teadet" if arv != 1 else "teade"
        print(f"  {i}. {allikas:<12} — {arv} {teade}")

    # Critical päeva lõikes (histogramm)
    print("Critical teated päeva lõikes:")
    max_critical = max((paevad[p].get("CRITICAL", 0) for p in sorditud_paevad), default=1)
    max_blokid   = 10  # max tulba laius

    from datetime import date, timedelta
    kõik_päevad = [algus + timedelta(days=i) for i in range(päevi)]

    for päev in kõik_päevad:
        arv    = paevad[päev].get("CRITICAL", 0) if päev in paevad else 0
        blokid = round((arv / max_critical) * max_blokid) if max_critical > 0 and arv > 0 else 0
        riba   = "█" * blokid if blokid > 0 else "-"
        print(f"  {päev}: {riba} ({arv})")

    # Vigased read
    if vigased:
        print(f"\n Vigaseid ridu: {len(vigased)}")
        for nr, rida, põhjus in vigased[:5]:
            print(f"   Rida {nr}: {põhjus}")
            print(f"     → {rida[:80]}")
        if len(vigased) > 5:
            print(f"   ... ja veel {len(vigased) - 5} viga.")
    print()


def salvesta_csv(paevad: dict, väljund: Path):
    severity_veerud = ["INFO", "WARNING", "CRITICAL", "KOKKU"]
    with väljund.open("w", newline="", encoding="utf-8") as f:
        kirjutaja = csv.DictWriter(f, fieldnames=["kuupäev"] + severity_veerud)
        kirjutaja.writeheader()
        for päev in sorted(paevad):
            t = paevad[päev]
            kirjutaja.writerow({
                "kuupäev": päev,
                **{sev: t.get(sev, 0) for sev in severity_veerud},
            })
    print(f"CSV salvestatud: {väljund}")


def main():
    args = parse_args()
    logi_tee = Path(args.logifail)

    if not logi_tee.exists():
        print(f"Viga: logifaili '{logi_tee}' ei leitud.", file=sys.stderr)
        sys.exit(1)

    kirjed, vigased = loe_logi(logi_tee)

    if not kirjed and not vigased:
        print(f"Logifail '{logi_tee}' on tühi — midagi analüüsida pole.")
        sys.exit(0)

    andmed = analüüsi(kirjed)
    prindi_kokkuvõte(andmed, vigased, kirjed)
    salvesta_csv(andmed["paevad"], Path(args.csv_väljund))


if __name__ == "__main__":
    main()
