### A - osa ###

1. Introduction to Ansible
A1.1 Mida Ansible automatiseerib? Kirjuta 1–2 lauset oma sõnadega.
V: Automatiseerib serverite haldamist.
A1.2 Mis on sinu arust põhiline erinevus Ansible'i ja tavalise skripti (Bash, Python) vahel?
V: Tavalised skriptid kirjutavad alati olemas oleva üle isegi siis kui se juba olemas, ansible kontrollib ja kui vaja muuta siis muudab.

2. Start automating with Ansible
A2.1 Mis on control node ja mis on managed node? Kirjelda, kus need sinu enda arvutis võiksid olla.
V: Control node on kus töötab Ansible ja Managed node on mida soovitakse hallata.
A2.2 Milline oli esimene Ansible-käsk, mida materjalis näitati? Mida see käsk teeb?
V: pip install ansible - installib ansible
A2.3 Kas Ansible nõuab sihtmasinas mingit eritarkvara installimist? Põhjenda.
V: Ei vaja,kuna ühendus tehakse üle SSH.

3. Building an inventory
A3.1 Mis on inventory? Tee kahe lausega selgitus.
V: Nimekiri masinatest mida soovid hallata. Selle kaudu on võimalik määrata gruppid kuhu üks või teine masin kuulub. 
A3.2 Millistes formaatides võib inventory olla? Nimeta vähemalt kaks.
V: .ini või .ymal
A3.3 Miks on grupid ([veebiserverid], [andmebaasid] jne) inventory's kasulikud? Too näide olukorrast, kus see vahet teeks.
V: Kui hakata veebiservereid ülesse ehitama siis nad vajavad APACHE samas, aga andmebaaside serverid seda ei vaja. 

4. Creating a playbook
A4.1 Mis keeles (formaadis) on playbook'id kirjutatud? Mille poolest see formaat erineb Pythonist või Bashist?
V: ymal keeles. Mille poolest erineb ....?
A4.2 Mis on task playbook'is?
V: Tegevuste nimekiri ülal alla et saavutada lõpptulemus. 
A4.3 Vaata näiteplaybook'i materjalis. Mida tähendab seal hosts:? Mida tähendab become:?
V: Hosts võib tähendada ühte masinat või grupp masinaid.

5. Ansible concepts
See on kõige tihedam alaleht. Loe läbi, siis täida tabel oma sõnadega (mitte koopia dokumentatsioonist):
V: 
Control node - masin kust saadetakse käske
Managed Nodes - masinad mida hallatakse
Inventory - nimekiri masinatest mida soovid hallata
Playbook - käskude nimekiri mida vaja vastavlt järjestusele teha
Play - osa playbookist mis määrab masiante grupi
Task - ülesanne, kus saad määrata kindlat tegevuse masinale
Module -  moodul mis on juba olemas aga tahad et see sinu masinasse installitakse
Handler - käivitatakse see kui midagi muutub
Collection - kõikide ülal nimetatud tegevuste kogum
A5.1 Mille poolest erineb module ja plugin?
V: Modul oleks kui rakendus aga plugin on staatus mis peab olema siis hiljem sihtmasians.
A5.2 Mille poolest erineb task ja handler?
V: Task kindel tegevus alati, samas handler on siis kui midagi on muutunud siis tee seda

### B - osa ###

# B1 #
V: Kui üks server kukub poole pealt ära siis sellest mul info puudub ja peaksin hakkama ise tuvastama
# B2 #
V: Ansible kontrollib kus midagi on tehtud ja kui on kuskil midagi puudu proovib uuesti. Lõpptulemus kuvatakse mis tehtud mis mitte.
# B3 # 
V: Kui on mitu masinat siis hea kasutada Ansible, samas kui üks siis saab ka skriptiga hakkama
# B4 #
V: Skripitis installitakse see alati uuesti samas Ansible kontrollib ka see on juba olemas ja teeb seda vajadusel

### C - osa ###

# C1 #
V: Töötab serverite peal mis asuvad gruppis "veebid". Näed seda inventory alt gruppi "veebid".
# C2 #
V: vars on koht kus saab määrata muutujat ei pea kirjutama igas lõigus pikal lahti teksti mida soovitakse kuvada vaid määrata sellele muutuja.
# C3 #
V: Erinevad: "Tere, mina olen web1", "Tere, mina olen web2", "Tere, mina olen web3"
# C4 #
V: Taski puhul tehaks igakord restart, samas handleri puhul tehaks ainult siis kui ülal pool tegevustes on muudatusi eelnevas konfiguratsioonis.
# C5 #
V: Kontrollib ja peaks näita et kõik on insatlitud ja korras.

### D - osa ###

# D1 #
V: Segaseks võivad jääd kuidas üht võiteist mõistet kasutada (Task, Play, Handler, Collection)
# D2 #
V: Päris palju saaks tööd lihtsamaks teha
# D3 #
V: Kindlasti on
# D4 #
V: Hetkel ei ole küsimus











