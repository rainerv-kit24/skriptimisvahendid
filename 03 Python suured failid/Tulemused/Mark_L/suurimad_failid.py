# =====================================================
#  10 kõige suuremat faili kasutaja kodukaustas
#  Kursus: KIT-24  |  Õpetaja: Toivo Pärnpuu
#  Autor:  Mark L.
# =====================================================
#
#  Skript otsib rekursiivselt kasutaja kodukaustast (või
#  käsureal antud kaustast) 10 kõige suuremat faili ja
#  salvestab tulemuse faili suurimad_failid.csv.
#
#  Lisaülesanded:
#   - argparse: otsingukoht käsurea argumendina
#   - AppData kausta välistamine
#   - lisaveerg "Muudetud" (faili viimase muutmise kuupäev)

import argparse
import csv
from datetime import datetime
from pathlib import Path


# ------------------------------------------------------
# Abifunktsioon — teisenda baidid loetavasse ühikusse
# ------------------------------------------------------
def vorminda_suurus(baidid):
    """Tagasta nt '2.3 GB', '847.2 MB' või '12.0 KB'."""
    if baidid >= 1_073_741_824:        # 1 GB = 1024^3
        return f"{baidid / 1_073_741_824:.1f} GB"
    elif baidid >= 1_048_576:          # 1 MB = 1024^2
        return f"{baidid / 1_048_576:.1f} MB"
    else:
        return f"{baidid / 1024:.1f} KB"


# ------------------------------------------------------
# Lisaülesanne: AppData välistamine
# ------------------------------------------------------
def on_appdatas(fail):
    """True kui fail asub AppData kaustas (Windowsi rakenduste vahemälu)."""
    return "AppData" in fail.parts


# ------------------------------------------------------
# Lisaülesanne: käsurea argumendid
# ------------------------------------------------------
def loe_argumendid():
    parser = argparse.ArgumentParser(
        description="Leiab antud kaustas 10 kõige suuremat faili."
    )
    parser.add_argument(
        "kaust",
        nargs="?",                     # argument on vabatahtlik
        default=str(Path.home()),
        help="Otsingukoht (vaikimisi kasutaja kodukaust)"
    )
    parser.add_argument(
        "--lisa-appdata",
        action="store_true",
        help="Kaasa ka AppData kaust (vaikimisi välja jäetud)"
    )
    return parser.parse_args()


# ------------------------------------------------------
# Põhiprogramm
# ------------------------------------------------------
def main():
    args = loe_argumendid()
    otsingukoht = Path(args.kaust)

    if not otsingukoht.exists():
        print(f"Viga: kausta '{otsingukoht}' ei eksisteeri.")
        return

    print(f"Otsin faile kaustast: {otsingukoht}")
    if not args.lisa_appdata:
        print("(AppData kaust on välja jäetud — kasuta --lisa-appdata, et lisada)")
    print()

    # 1. Leia kõik failid rekursiivselt
    failid = []
    for fail in otsingukoht.rglob("*"):
        try:
            if not fail.is_file():
                continue
            if not args.lisa_appdata and on_appdatas(fail):
                continue
            failid.append(fail)
        except (PermissionError, OSError):
            # Vahele jätta failid, millele puudub ligipääs
            continue

    print(f"Leitud faile kokku: {len(failid)}")

    # 2. Sorteeri suuruse järgi ja võta 10 esimest
    failid_sorditud = sorted(
        failid,
        key=lambda f: f.stat().st_size,
        reverse=True
    )[:10]

    # 3. Ehita tulemus
    tulemus = []
    for fail in failid_sorditud:
        andmed = fail.stat()
        muudetud = datetime.fromtimestamp(andmed.st_mtime).strftime("%Y-%m-%d")
        tulemus.append({
            "Tee":      str(fail),
            "Nimi":     fail.name,
            "Suurus":   vorminda_suurus(andmed.st_size),
            "Muudetud": muudetud,
        })

    # 4. Kuva ekraanile
    print("\n10 suurimat faili:")
    print("-" * 70)
    for i, rida in enumerate(tulemus, 1):
        print(f"  {i:2d}. {rida['Suurus']:>10s}  {rida['Muudetud']}  {rida['Nimi']}")

    # 5. Salvesta CSV-faili (skripti kõrvale)
    väljund = Path(__file__).parent / "suurimad_failid.csv"
    väljund.parent.mkdir(parents=True, exist_ok=True)

    with open(väljund, "w", newline="", encoding="utf-8") as f:
        kirjutaja = csv.DictWriter(
            f, fieldnames=["Tee", "Nimi", "Suurus", "Muudetud"]
        )
        kirjutaja.writeheader()
        kirjutaja.writerows(tulemus)

    print(f"\nSalvestatud: {väljund}")


if __name__ == "__main__":
    main()
