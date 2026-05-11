import os #saame toimetada kaustas

kaust = "failide-harjutus" #anname muutuja nimega kaust

print("Failid enne ümbernimetamist:")
print("-" * 35)

failid = os.listdir(kaust)   # tagastab nimekirja kaustas olevatest failidest
for failinimi in failid:
    print(failinimi)

# 2. osa — nimeta tühikud allkriipsudeks
print("Nimetan tühikud allkriipsudeks...")
print("-" * 35)

for failinimi in os.listdir(kaust):

    if " " in failinimi:  # kontrolli, kas failinimi sisaldab tühikut

        uus_nimi = failinimi.replace(" ", "_")  # asenda kõik tühikud

        vana_tee = os.path.join(kaust, failinimi)  # täielik tee vanale failile
        uus_tee  = os.path.join(kaust, uus_nimi)   # täielik tee uuele failile

        os.rename(vana_tee, uus_tee)  # teeb ümbernimetamise

        print(f"  {failinimi}  →  {uus_nimi}")

# 3. osa — lisa eesliide failitüübi järgi
print("Lisan eesliited failitüübi järgi...")
print("-" * 35)

for failinimi in os.listdir(kaust):

    if failinimi.endswith(".jpg") and not failinimi.startswith("pilt_"):
        uus_nimi = "pilt_" + failinimi

    elif failinimi.endswith(".txt") and not failinimi.startswith("tekst_"):
        uus_nimi = "tekst_" + failinimi

    else:
        continue  # see fail ei vaja muutmist, jätame vahele

    vana_tee = os.path.join(kaust, failinimi)
    uus_tee  = os.path.join(kaust, uus_nimi)
    os.rename(vana_tee, uus_tee)
    print(f"  {failinimi}  →  {uus_nimi}")

# 4. osa — lõpptulemus
print("Failid pärast ümbernimetamist:")
print("-" * 35)
for failinimi in sorted(os.listdir(kaust)):
    print(failinimi)