#!/usr/bin/env python3

"""
Analüüsib ps-alerts.log logifaili ja teeb kokkuvõtte.

Väljund:
 - konsooli kokkuvõte
 - CSV fail päevade lõikes
"""

import argparse
import csv
from pathlib import Path
from datetime import datetime
from collections import Counter, defaultdict


def parse_rida(rida: str) -> dict | None:
    """Parsib ühe logirea sinu PowerShell logiformaadist."""

    rida = rida.strip()

    if not rida:
        return None

    # proovime ISO timestampi
    try:
        ajatempel = rida[:19]
        aeg = datetime.strptime(ajatempel, "%Y-%m-%d %H:%M:%S")
        ylejaanud = rida[20:]
    except ValueError:

        # fallback USA formaat
        try:
            ajatempel = rida[:19]
            aeg = datetime.strptime(ajatempel, "%m/%d/%Y %H:%M:%S")
            ylejaanud = rida[20:]
        except ValueError:
            return None

    # jagame ülejäänud osa
    osad = ylejaanud.split(" - ")

    if len(osad) < 2:
        return None

    staatus = osad[0].strip()

    # kui severity puudub (vana formaat)
    if len(osad) == 1:
        severity = "Info"
        allikas = "Unknown"
        sonum = osad[0]
        viga = None

    else:
        severity = osad[1]

        if len(osad) >= 3:
            sonum = osad[2]
        else:
            sonum = ""

        if len(osad) >= 4:
            allikas = osad[3]
        else:
            allikas = "Unknown"

        if len(osad) >= 5:
            viga = osad[4]
        else:
            viga = None

    return {
        "aeg": aeg,
        "staatus": staatus.strip("[]"),
        "severity": severity,
        "allikas": allikas,
        "sõnum": sonum,
        "viga": viga,
    }


def loe_logi(tee: Path) -> list[dict]:
    """Loeb logifaili ja tagastab parsed read."""
    if not tee.exists():
        raise FileNotFoundError(f"Logifail puudub: {tee}")

    vigased = 0
    teated = []

    for rida in tee.read_text(encoding="utf-8").splitlines():
        if not rida.strip():
            continue

        parsed = parse_rida(rida)

        if parsed:
            teated.append(parsed)
        else:
            vigased += 1

    if vigased:
        print(f"Hoiatus: {vigased} rida ei suutnud parsida")

    return teated


def analuusi(teated: list[dict]) -> dict:
    """Analüüsib parsed logiteated."""

    if not teated:
        return {
            "esimene": None,
            "viimane": None,
            "kokku": 0,
            "paevad": {},
            "allikad": Counter(),
            "severity": Counter(),
            "ebaõnnestumisi": 0,
        }

    paevad = defaultdict(lambda: Counter())

    for t in teated:
        paev = t["aeg"].date()

        paevad[paev]["_kokku"] += 1
        paevad[paev][t["severity"]] += 1

        if t["staatus"] == "FAIL":
            paevad[paev]["_fail"] += 1

    return {
        "esimene": min(t["aeg"] for t in teated).date(),
        "viimane": max(t["aeg"] for t in teated).date(),
        "kokku": len(teated),
        "paevad": dict(paevad),
        "allikad": Counter(t["allikas"] for t in teated),
        "severity": Counter(t["severity"] for t in teated),
        "ebaõnnestumisi": sum(1 for t in teated if t["staatus"] == "FAIL"),
    }


def ascii_riba(arv: int) -> str:
    """Tagastab ASCII ribagraafiku."""
    return "██" * arv if arv else "-"


def prindi_kokkuvote(tulemus: dict):
    """Prindib analüüsi kokkuvõtte konsooli."""

    if tulemus["kokku"] == 0:
        print("Logifail on tühi.")
        return

    paevade_arv = (tulemus["viimane"] - tulemus["esimene"]).days + 1

    print(f"Periood:      {tulemus['esimene']} kuni {tulemus['viimane']} ({paevade_arv} päeva)")
    print(f"Teateid kokku: {tulemus['kokku']}")
    print(f"  ├─ õnnestus:  {tulemus['kokku'] - tulemus['ebaõnnestumisi']}")
    print(f"  └─ ebaõnnestus: {tulemus['ebaõnnestumisi']}")

    print("\nRaskusaste:")

    for tase in ["Info", "Warning", "Critical"]:
        print(f"  {tase}: {tulemus['severity'].get(tase, 0)}")

    print("\nTop allikad:")

    for i, (allikas, arv) in enumerate(tulemus["allikad"].most_common(3), 1):
        print(f"  {i}. {allikas} — {arv} teadet")

    print("\nCritical teated päeva lõikes:")

    for paev in sorted(tulemus["paevad"]):
        arv = tulemus["paevad"][paev].get("Critical", 0)
        print(f"  {paev}: {ascii_riba(arv)} ({arv})")


def salvesta_csv(tulemus: dict, tee: Path):
    """Salvestab päevade analüüsi CSV faili."""

    with open(tee, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)

        writer.writerow([
            "Päev",
            "Teateid kokku",
            "Info",
            "Warning",
            "Critical",
            "Ebaõnnestunud"
        ])

        for paev in sorted(tulemus["paevad"]):
            p = tulemus["paevad"][paev]

            writer.writerow([
                paev,
                p.get("_kokku", 0),
                p.get("Info", 0),
                p.get("Warning", 0),
                p.get("Critical", 0),
                p.get("_fail", 0),
            ])


def main():

    parser = argparse.ArgumentParser(description="Analüüsi teavituste logifaili")

    parser.add_argument(
        "logi",
        nargs="?",
        default="ps-alerts.log",
        help="Logifail (vaikimisi ps-alerts.log)"
    )

    parser.add_argument(
        "--väljund",
        default="analyys_paevad.csv",
        help="CSV väljundfail"
    )

    args = parser.parse_args()

    teated = loe_logi(Path(args.logi))

    tulemus = analuusi(teated)

    prindi_kokkuvote(tulemus)

    salvesta_csv(tulemus, Path(args.väljund))

    print(f"\nCSV salvestatud: {args.väljund}")


if __name__ == "__main__":
    main()