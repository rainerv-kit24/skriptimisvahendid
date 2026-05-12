# =====================================================
#  IT-seadmete inventuuri analüüs
#  Kursus: KIT-24  |  Õpetaja: Toivo Pärnpuu
#  Autor:  Mark L.
# =====================================================
#
#  Skript loeb sisse seadmed.csv, leiab probleemsed seadmed
#  (vana uuendus, vähe kettaruumi, aegunud garantii),
#  arvutab statistika osakondade kaupa ja kirjutab tulemused
#  faili probleemseadmed.csv.

import csv
from datetime import date


# ------------------------------------------------------
# 1. osa — loe CSV fail sisse
# ------------------------------------------------------
seadmed = []  # tühi nimekiri, kuhu salvestame kõik read

with open("seadmed.csv", newline="", encoding="utf-8") as f:
    lugeja = csv.DictReader(f)          # iga rida loetakse sõnastikuna
    for rida in lugeja:
        seadmed.append(rida)

print(f"Kokku seadmeid andmebaasis: {len(seadmed)}")
print()

# Vaata, milline näeb välja üks rida
print("Näidis — esimene seade:")
print("-" * 40)
for väli, väärtus in seadmed[0].items():
    print(f"  {väli}: {väärtus}")


# ------------------------------------------------------
# 2. osa — filtreerimine: leia probleemid
# ------------------------------------------------------
tana = date.today()

vanad_uuendused  = []   # mida pole üle aasta uuendatud
vähe_ruumi       = []   # vaba kettaruum alla 10 %
aegunud_garantii = []   # garantii on lõppenud

for seade in seadmed:
    # --- viimane uuendus ---
    uuendus = date.fromisoformat(seade["viimane_uuendus"])
    paevi_tagasi = (tana - uuendus).days
    if paevi_tagasi > 365:
        vanad_uuendused.append((seade["nimi"], paevi_tagasi))

    # --- kettaruum ---
    kokku = int(seade["kettaruum_gb"])
    vaba  = int(seade["kettaruum_vaba_gb"])
    protsent = vaba / kokku * 100
    if protsent < 10:
        vähe_ruumi.append((seade["nimi"], round(protsent, 1)))

    # --- garantii ---
    garantii = date.fromisoformat(seade["garantii_lõpp"])
    if garantii < tana:
        aegunud_garantii.append((seade["nimi"], seade["garantii_lõpp"]))


print("\nSeadmed, mida pole üle aasta uuendatud:")
for nimi, paevi in vanad_uuendused:
    print(f"  {nimi} — {paevi} päeva tagasi")

print("\nSeadmed, kus vaba kettaruum alla 10%:")
for nimi, protsent in vähe_ruumi:
    print(f"  {nimi} — {protsent}% vaba")

print("\nSeadmed, mille garantii on lõppenud:")
for nimi, kuupäev in aegunud_garantii:
    print(f"  {nimi} — lõppes {kuupäev}")


# ------------------------------------------------------
# 3. osa — arvutused osakondade kaupa
# ------------------------------------------------------
osakonnad = {}   # osakonna nimi -> seadmete arv
for seade in seadmed:
    osakond = seade["osakond"]
    if osakond not in osakonnad:
        osakonnad[osakond] = 0
    osakonnad[osakond] += 1

print("\nSeadmete arv osakondade kaupa:")
for osakond, arv in sorted(osakonnad.items()):
    print(f"  {osakond}: {arv} seadet")

# Keskmine vaba kettaruum
vaba_ruumid = [int(s["kettaruum_vaba_gb"]) for s in seadmed]
keskmine_vaba = sum(vaba_ruumid) / len(vaba_ruumid)
print(f"\nKeskmine vaba kettaruum: {round(keskmine_vaba, 1)} GB")


# ------------------------------------------------------
# 4. osa — kirjuta aruanne uude CSV-faili
# ------------------------------------------------------
with open("probleemseadmed.csv", "w", newline="", encoding="utf-8") as f:
    väljad = ["nimi", "probleem", "detail"]
    kirjutaja = csv.DictWriter(f, fieldnames=väljad)
    kirjutaja.writeheader()

    for nimi, paevi in vanad_uuendused:
        kirjutaja.writerow({
            "nimi": nimi,
            "probleem": "vana uuendus",
            "detail": f"{paevi} päeva tagasi"
        })

    for nimi, protsent in vähe_ruumi:
        kirjutaja.writerow({
            "nimi": nimi,
            "probleem": "vähe kettaruumi",
            "detail": f"{protsent}% vaba"
        })

    for nimi, kuupäev in aegunud_garantii:
        kirjutaja.writerow({
            "nimi": nimi,
            "probleem": "garantii lõppenud",
            "detail": kuupäev
        })

print("\nAruanne salvestatud faili: probleemseadmed.csv")
