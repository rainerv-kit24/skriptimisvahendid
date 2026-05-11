# =====================================================
#  IT-seadmete täiendav analüüs (lisaülesanded)
#  Kursus: KIT-24  |  Õpetaja: Toivo Pärnpuu
#  Autor:  Mark L.
# =====================================================
#
#  Lisaülesanded põhiharjutusele:
#   1) Filter: ainult Windows 10 seadmed (vajavad uuendust Win11-le)
#   2) Sorteerimine: vähe kettaruumi seadmed protsendi järgi kasvavalt
#   3) Loendus: mitu seadet, mille garantii lõpeb järgmise 6 kuu jooksul

import csv
from datetime import date, timedelta


# ------------------------------------------------------
# Loe seadmed sisse
# ------------------------------------------------------
seadmed = []
with open("seadmed.csv", newline="", encoding="utf-8") as f:
    for rida in csv.DictReader(f):
        seadmed.append(rida)


# ------------------------------------------------------
# 1) Filter — ainult Windows 10 seadmed
# ------------------------------------------------------
print("=" * 50)
print("Windows 10 seadmed (vajavad uuendust Windows 11-le)")
print("=" * 50)

windows10 = [s for s in seadmed if s["os"].strip() == "Windows 10"]

if windows10:
    for s in windows10:
        print(f"  {s['seadme_id']:8s}  {s['nimi']:20s}  osakond: {s['osakond']}")
    print(f"\n  Kokku: {len(windows10)} seadet")
else:
    print("  Windows 10 seadmeid ei leitud — tubli!")


# ------------------------------------------------------
# 2) Sorteerimine — vähe kettaruumi seadmed kasvavalt
# ------------------------------------------------------
print("\n" + "=" * 50)
print("Vähe kettaruumi (alla 10%) — sorteeritud kasvavalt")
print("=" * 50)

vähe_ruumi = []
for s in seadmed:
    kokku = int(s["kettaruum_gb"])
    vaba  = int(s["kettaruum_vaba_gb"])
    protsent = vaba / kokku * 100
    if protsent < 10:
        vähe_ruumi.append((s["nimi"], round(protsent, 1), vaba, kokku))

# sorteeri protsendi (indeks 1) järgi kasvavalt
vähe_ruumi_sorteeritud = sorted(vähe_ruumi, key=lambda x: x[1])

if vähe_ruumi_sorteeritud:
    for nimi, protsent, vaba, kokku in vähe_ruumi_sorteeritud:
        print(f"  {nimi:20s}  {protsent:5.1f}%   ({vaba}/{kokku} GB)")
else:
    print("  Kõigil seadmetel piisavalt ruumi.")


# ------------------------------------------------------
# 3) Garantii lõppemine järgmise 6 kuu jooksul
# ------------------------------------------------------
print("\n" + "=" * 50)
print("Garantii lõpeb järgmise 6 kuu jooksul")
print("=" * 50)

tana       = date.today()
kuus_kuud  = tana + timedelta(days=183)   # ligikaudu 6 kuud (183 päeva)

peagi_aegumas = []
for s in seadmed:
    garantii = date.fromisoformat(s["garantii_lõpp"])
    # vahemikus täna ... +6 kuud (kaasa arvatud)
    if tana <= garantii <= kuus_kuud:
        paevi_jaanud = (garantii - tana).days
        peagi_aegumas.append((s["nimi"], s["garantii_lõpp"], paevi_jaanud))

# sorteeri kõige kiiremini lõppev ette
peagi_aegumas.sort(key=lambda x: x[2])

if peagi_aegumas:
    for nimi, lopp, paevi in peagi_aegumas:
        print(f"  {nimi:20s}  lõpeb {lopp}  ({paevi} päeva pärast)")
    print(f"\n  Kokku: {len(peagi_aegumas)} seadet")
else:
    print("  Ühelgi seadmel ei aegu garantii järgmise 6 kuu jooksul.")
