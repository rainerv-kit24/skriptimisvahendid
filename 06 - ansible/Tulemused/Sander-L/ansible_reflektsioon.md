## A osa — lugemine ja kontrollküsimused

## 1.Introduction to Ansible
__A1.1 Mida Ansible automatiseerib?__

Ansiblega saab automatiseerida kõike ja saab jooksutada igal pool

__A1.2 Mis on sinu arust põhiline erinevus Ansible'i ja tavalise skripti (Bash, Python) vahel?__

Ansible kirjeldab milline peab olema lõpptulemus, tavaline skript kirjeldab samm-sammult mida teha.
Kui apache on juba paigaldatud, siis ansible seda uuesti ei tee

## 2.Start automating with Ansible

__A2.1 Mis on control node ja mis on managed node? Kirjelda, kus need sinu enda arvutis võiksid olla.__

Masin, millelt jookseb käsurea tööriist (ansible-playbook,ansible,ansible-vault), on control node. "Juhtimiskeskus".\
managed node on seade, millel tahetakse mõnd skripti jooksutada. Sihtmasin.

__A2.2 Milline oli esimene Ansible-käsk, mida materjalis näitati? Mida see käsk teeb?__

Esmalt on vaja ansible arvutisse installida ```pip install ansible``` ja siis on vaja luua projekti kaust ```mkdir ansible_quickstart && cd ansible_quickstart```\
Esimene Ansible-käsk, mida näidatakse on ```ansible-inventory -i inventory.ini --list``` see käsk kinnitab ära inventory, et kõik sihtmasinad vastavad.

__A2.3 Kas Ansible nõuab sihtmasinas mingit eritarkvara installimist? Põhjenda.__

Ansible ei ole vaja sihtmasinas eraldi installida.\
 Ansible kasutab SSH protokolli masinasse jõudmiseks.



## 3. Building an inventory
__3.1 Mis on inventory? Tee kahe lausega selgitus.__

Inventory on fail, kus on kirjas kõikide sihtmasinate andmed (IP-d,hostinimed).\
Sellega saab ka masinad gruppidesse panna, et erinevate masinate grupid saaksid erinevad konfiguratsioonid.

__A3.2 Millistes formaatides võib inventory olla? Nimeta vähemalt kaks.__

Inventory fail võib olla nii INI formaadis kui ka YAML formaadis.

__A3.3 Miks on grupid ([veebiserverid], [andmebaasid] jne) inventory's kasulikud? Too näide olukorrast, kus see vahet teeks.__

Grupid võimaldavad rakendada erinevat konfiguratsiooni erinevatele masinate kogumitele, mis on inventory failis kirjeldatud.\
Näiteks kui ära defineerida veebiserverid ja andmebaasid, siis veebiserveritele tuleb peale panna apache2 või nginx, aga andmebaasidele seda vaja pole.\
Vastupidiselt andmebaasidele oleks vaja peale panna mysql või postgresql, aga veebiserveritel seda vaja pole.

## 4. Creating a playbook
__A4.1 Mis keeles (formaadis) on playbook'id kirjutatud? Mille poolest see formaat erineb Pythonist või Bashist?__

Playbook-id on kirjutatud YAML formaadis. Python ja Bash täidavad käske järjest, see mis on ette antud tehakse ka ära. Ansible YAML on rohkem kirjeldab "Peaks olema apache2 paigaldatud"

__A4.2 Mis on task playbook'is?__

Task on üks konkreetne samm, mida Ansible peab ära tegema. "Veendu, et postgresql on installitud viimane versioon" 

__A4.3 Vaata näiteplaybook'i materjalis. Mida tähendab seal hosts:? Mida tähendab become:?__

hosts: määrab millistel masinatel või gruppidel playbook käivitatakse.\
become: määrab kas käsk jooksutatakse administraatorina või tavakasutajana.

## 5. Ansible concepts

| Mõiste | Mida see tähendab? (1 lause) |
|--------|------------------------------|
| Control node | Masin, mis kontrollib Ansible |
| Managed node | Sihtmasin, kus jooksutatakse playbook |
| Inventory | Fail, kus määratakse ära sihtmasinate parameetrid |
| Playbook | Fail, kus määratakse ära automatiseerimise tööd |
| Play | Playbooki osa, mis seob grupi konkreetse taskiga |
| Task | Playbooki üks konkreetne ülesanne |
| Module | Ansible funktsioon, mis teeb konkreetse töö (apt, copy) |
| Handler | Spetsiaalne task, näiteks taaskäivitamiseks |
| Collection | Sisaldab playbooke, mooduleid ja muid komponente ühes kogumis |

__A5.1 Mille poolest erineb module ja plugin?__

Moodul tegutseb sihtmasinal, teeb konkreetset tööd(paigaldab,kopeerib).\
Plugin aitab Ansiblel endal töötada, laiendab võimekust.

__A5.2 Mille poolest erineb task ja handler?__

Task teeb kõik tööd ülevalt alla järjest ära.\
Handlerit peab eraldi kutsuma notify abiga ja tavaliselt kutsutakse kui on vaja süsteemile restarti.


## B osa — seos sellega, mida juba tead

__B1 Sul on 30 serverit, igaühele tuleb paigaldada nginx ja luua sama konfifail. Kuidas teeksid seda Bashi skriptiga? Mis läheb halvasti, kui üks server vahepeal alla kukub või paigaldus jookseb pooleldi läbi?__

Bashi skriptiga tuleks ssh-ga arvutitesse sisse minna ja käivitada "apt install nginx" käsk ja konfifail kopeerida. Kui üks server kukub maha, siis jääb selles serveris installimine poolikuks ja skript võtaks ette uue serveri. Hiljem tuleks käsitsi installimine lõpuni teha või jooksutada skript uuesti. Otseselt Bashi skriptiga ei näe ka, kus jäi pooleli või mis serverist mindi üle.

__B2 Kuidas Ansible sama ülesannet teisiti lahendab? Mis muutub?__

Ansible kontrollib ise kas Nginx on juba paigaldatud. Kui Bash skriptiga paigaldatakse Nginx igal juhul uuesti, isegi kui see juba on paigaldatud, siis Ansible ei tee midagi kui Nginx on juba olemas.\
Ansible suudab ka paralleelselt mitme serveriga korraga tööd teha.

__B3 Vaata viimase nädala harjutusi (notifikatsioonimoodul, suurimad failid jne). Kas mõni sealne ülesanne sobiks Ansible'i kasutuseks paremini kui skriptiga? Põhjenda.__

Kui oleks vaja korraga 30 serverit monitoorida, siis selle paigaldamine Ansiblega oleks sobiv. Teiste ülesannetega, nagu andmeanalüüs ja süsteemi kohta info kogumisega saab python paremini hakkama, on paindlikum.

__B4 Sõnasta idempotentsus ühes lauses oma sõnadega. (Vihje: mõelge apt install nginx peale — mis juhtub teisel käivitamisel skriptiga ja mis Ansible'iga?)__

Idempotentsus tähendab, et korduvad käivitused ei muuda süsteemi/lõppolekut.
Sama käsku saab mitu korda käivitada ja tulemus on alati sama.

## C osa — loe ja seleta seda playbook'i

__C1 Kelle peal see playbook töötab? Kust seda näed?__

See playbook töötab "veebid" grupi masinatel.\
Seda näeb ära teiselt realt hosts:

__C2 Mis on vars: osa funktsioon? Miks ei kirjutatud nginx ja avalehe tekst kohe taskidesse?__

```vars:``` on keskne seadistuste koht playbooki alguses, kust on lihtne muuta ja mis teeb playbooki paindlikuks ja korduvkasutatavaks. Ilma selleta oleks playbook jäik ja raske hooldada.\
Kui ```vars:``` ei ole defineeritud, siis võib juhtuda, et ühte muutujat on vaja muuta kolmest või enamast kohast.

__C3 Mida teeb {{ inventory_hostname }}? Kui playbook käivitatakse kolme serveri peal (web1, web2, web3), kas avalehed on samad või erinevad?__

{{ inventory_hostname }} sisaldab masina nime inventory failist, mis on igal serveril erinev. Kui käivitatakse web1, web2 või web3 serveril, siis kõigi avalehed on erinevad.

__C4 Mis vahe on task-il "Restart nginx" ja handler-il "Restart nginx"? Millal handler käivitub?__

Task käivitub iga kord kui on defineeritud playbookis, aga handler käivitub ainult siis kui teda eraldi ```notify:``` abil kutsutakse ja mingi muudatus on toimunud.

__C5 Kui käivitad selle playbook'i kaks korda järjest, mis juhtub teisel käivitamisel? Mida väljund näitab?__

Teisel käivitamisel playbook kontrollib, et kõik on juba õigesti seadistatud. Ei muuda midagi, handler ei käivitu.\
Kõik taskid täidetakse, aga kõik näitavad ```ok``` mitte ```changed```.

## D osa — avatud reflektsioon

__D1 Mis oli kõige arusaamatum koht materjalis? (Kui kõik oli selge, siis tunnista seda julgelt — aga ole enda vastu aus.)__

Handleri loogikast oli kõige raskem aru saada, aga C osa sai see palju selgemaks, just see ```changed``` osa logides.

__D2 Mis tundus üllatav või huvitav?__

Idempotentsuse aspekt oli üllatav ja huvitav, polnud varem sellest kuulnud.\
Teine aspekt, mis oli huvitav - Ansible ei tööta nagu teised skriptid, vaid töötab lõppseisu kirjeldavana.

__D3 Kus sinu enda igapäevatöös (või tulevases töös IT-administraatorina) võiks Ansible kasulik olla?__

Uute serverite mass paigaldamine ja konfigureerimine. Samamoodi ka olemasolevate serverite taastamine, juhul kui peaks katki minema.

__D4 Üks küsimus, mille tahad arutelu ajal teistega või õpetajaga läbi rääkida. (Pane see kindlasti — see on aluseks meie 12.00 algavale arutlusele.)__

Kuidas ära tunda millal kasutada Ansible ja milla võiks piisav olla lihtne Bash/Python skript.