**A1.1** 
Ansible automatiseerib ja lihtsustab tööprotsesse: süsteemiseadete haldust, tarkvara paigaldust ja uuendamist. 

**A1.2**
 Tavalise skripti puhul tuleb kirjutada täpsed käsud, mida on tarvis teha. Ansible puhul tuleb anda kirjeldus soovitud tulemusest/seisundist. Keerulise koodi asemel on pigem tegu juhendite andmisega.

**A2.1**
 Control node - arvuti, kus Ansible jookseb ja millest juhitakse teisi seadmeid. Nt. Powershelli terminalis avatud WSL + Ubuntu + Ansible.<br> Managed node - arvutid/serverid, mida Ansible kaudu hallatakse. Nt. enda Windows arvuti või loodud virtuaalmasin.

**A2.2**
pip install ansible <br>
Paigaldab Ansible.

**A2.3** 
Ansible ei nõua sihtmasinas eritarkvara installimist. Ansible kasutab ühenduseks SSH protokolli ja olemasolevaid süsteemi vahendeid (Linux'i keskkond, Python).

**A3.1**
 Inventory on nimekiri seadmetest, mida Ansible haldab. Seal on kirjas nt. IP-aadressid ja seaded.

**A3.2** 
Inventory võib olla nt. INI või YAML formaadis.

**A3.3**
 Grupid võimaldavad hallata mitut sarnase rolliga seadet (nt.serverit) korraga. <br>
Näiteks saab veebiserverite grupile paigaldada veebiserver tarkvara (nt.Nginx) ja andmebaaside grupile andmebaasi tarkvara, mis teeb haldamise lihtsamaks. Ilma gruppideta tuleks igat serverit eraldi käsitleda.

**A4.1**
 Playbook'id on kirjutatud YAML formaadis. <br>
YAML ei ole programmeerimiskeel vaid andmete kirjeldamise formaat - soovitud seisundit kirjeldatakse lihtsasti loetaval kujul. <br>
Pythonis ja Bashis seevastu kirjutatakse täpsed käsud ja loogika, kuidas tulemus saavutada.

**A4.2** 
Task on üks konkreetne tegevus, mida Ansible täidab määratud seadmetel.

**A4.3**
hosts: - määrab, millistele inventory's olevatele seadmetele playbook'i tegevused rakendatakse. <br>
become: - konkreetses näiteplaybook'is see küll puudub, kuid seda kasutatakse, kui on vaja kõrgendatud (admin-) õigusi.

| Mõiste        | Mida see tähendab? (1 lause) |
|--------------|------------------------------|
| Control node | Seade, millele on Ansible paigaldatud ja millelt hallatakse teisi masinaid                               |
| Managed node | Seade (sihtmasin), mida Ansible abil hallatakse                               |
| Inventory    | Nimekiri hallatavatest seadmetest, nende seadetest ja gruppidesse kuulumisest                             |
| Playbook     | Kirjeldus, milliseid tegevusi Ansible teeb ja millistele seadmetele need rakendatakse                             |
| Play         | Playbook'i osa, mis määrab millistele seadmetele teatud tegevused rakendatakse                             |
| Task         | Üks konkreetne tegevus määratud seadmes või grupis                             |
| Module       | Kood, mida rakendatakse hallatavale sihtmasinale tegevuse sooritamiseks                             |
| Handler      | Tegevuse eriliik, mis rakendub kui eelnev tegevus annab selleks märku ja olek muutus "changed".                              |
| Collection   | Ansible pakett, mis sisaldab komponente: playbook'id, rollid, moodulid ja pluginad.                               |

**A5.1**
Module teostab konkreetse tegevuse hallatavas masinas.<br>
Plugin toetab Ansible tööd control nodes, nt. ühenduste või andmete töötlemise kaudu.

**A5.2** 
Task on tavaline tegevus, mis täidetakse alati playbook'i käivitamisel. <br>
Handler on eriliiki tegevus, mis käivitakse ainult siis, kui mõni task teeb muudatuse ja kutsub selle välja.

**B1**
Bashi skriptiga tuleks kirjutada käsud, mis käivituvad igas serveris eraldi, näiteks SSH kaudu. Probleem on selles, et kui mõni server ei vasta või paigaldus katkeb, võib osa servereid jääda seadistamata või poolikusse seisundisse ning seda tuleb käsitsi kontrollida ja parandada.

**B2**
Ansible puhul pannakse serverid gruppi ja kirjeldatakse, milline peab olema lõpptulemus. Ansible teeb sama tegevuse kõikides serverites ning näitab, kus õnnestus ja kus tekkis viga. See teeb töö lihtsamaks ja vähendab vigade tekkimise võimalust.

**B3**
Mõned harjutused sobiksid Ansible'i kasutuseks paremini kui tavalise skriptiga, eriti need, kus sama tegevust tuleks teha mitmes arvutis või serveris.

Näiteks "Serverite saadavuse monitor" sobiks osaliselt Ansible'iga, sest Ansible suudab inventory põhjal kontrollida mitut hosti korraga ja näidata, millised masinad on kättesaadavad. Samuti sobiks "ID-tarkvara versiooni automaatne kontroll", kui seda oleks vaja teha paljudes tööjaamades, sest Ansible abil saaks sama kontrolli rakendada korraga mitmele seadmele.

PowerShelli teavituste moodul REST API kaudu võiks sobida hästi Ansible jaoks, sest töötaks mitmes serveris, teavitusloogika on ühene kõikjal.

Ka "Süsteemi inventuur" võiks sobida Ansible'iga, kui eesmärk on koguda infot paljudest masinatest. Ansible oskab koguda süsteemi fakte, näiteks operatsioonisüsteemi, mälu, protsessori ja võrguseadmete kohta.

Kaustade puhastus Bashiga võiks teatud olukorras Ansible'iga sobida, kui sama puhastust tuleb teha mitmes serveris.

Samas CSV analüüs, logianalüüs ja suurimate failide leidmine sobivad pigem Pythoni või PowerShelli skriptideks, sest need on rohkem andmetöötluse ülesanded. 

**B4**
Idempotentsus tähendab, et süsteem jääb samaks ja muudatusi ei tehta, kui sama tegevust käivitatakse korduvalt.<br>
apt install nginx võib uuendada ja muuta süsteemi, installida lisapakette.<br>
Ansible kontrollib, kas nginx on olemas - kui soovitud seisund on saavutatud, siis ei tee midagi.

**C1**
Playbook töötab seadmete grupi "veebid" peal. Seda on näha realt "hosts: veebid"

**C2**
vars: osa funktsioon defineerib muutujad (variables), mida kasutatakse playbook'i taskides.<br>
nginx_pakk: nginx - määratakse paigaldatav pakett;<br>
avaleht_sisu: - määrab veebilehe sisu.<br>
Neid ei kirjutatud otse taskidesse, et koodi oleks lihtsam hallata ja muuta - kui väärtus on muutujas, saab seda muuta ühes kohas ilma, et peaks kõiki taske eraldi muutma.

**C3**
inventory_hostname kuvab veebilehel seadmete nimekirjas (inventory) määratud seadme nime. Kui playbook käivitatakse kolme serveri peal (web1, web2, web3), siis avalehed erinevad seadme nime poolest:<br>
"Tere, mina olen web1"<br>
"Tere, mina olen web2"<br>
"Tere, mina olen web3"

**C4**
Task "Restart nginx" - on tavaline tegevus, mis käivitatakse alati. <br>
Handler "Restart nginx" - on eriline tegevus, mis käivitatakse ainult siis, kui eelnev task teeb muudatuse ja handler välja kutsutakse.<br>
Antud näites käivitub handler siis, kui avalehe loomise task muudab faili sisu (notify: Restart nginx).

**C5**
Teisel käivitamisel ei tehta muudatusi, kuna süsteem on juba soovitud seisundis. Ansible väljund näitab, et kõik task'id on olekus "ok" ja midagi ei muudetud, ning handler ei käivitu.

**D1**
Kõige arusaamatumaks jäi, kuidas Ansible kaudu sihtmasinaid hallatakse ja mida täpselt peab nendesse paigaldama. Tõenäoliselt aitaks sellest paremini aru saada praktiline harjutamine, näiteks inventory loomine, gruppide ja muutujate määramine ning lihtsa playbook'i koostamine.

Keeruline oli ka otsustada, milliste seni tehtud skriptiülesannete puhul oleks Ansible kasutamine mõistlikum. Selle analüüsimisel kasutasin abivahendina AI-d, et paremini mõista erinevate tööriistade rolli.

**D2**
Üllatav ja huvitav oli see, et Ansible playbook'id on pealtnäha lihtsamini mõistetavad kui programmeerimiskeeltes kirjutatud skriptid. 

**D3**
Ansible võiks olla kasulik olukordades, kus sama seadistust tuleb rakendada mitmes serveris või tööjaamas korraga. Näiteks tarkvara paigaldamine, konfiguratsioonifailide haldamine ja teenuste käivitamine mitmes masinas.

Samuti oleks Ansible kasulik süsteemide ühtse seisundi tagamisel, et kõik serverid oleksid samade seadistustega. See vähendab käsitsi tehtavat tööd ja vigade tekkimise võimalust.

**D4**
Võiks arutada, milliste seni tehtud skriptimise harjutuste puhul oleks mõistlik kasutada Ansible't ning millistel juhtudel jääksid sobivamaks tavalised skriptid. See aitaks paremini mõista, kus jookseb piir automatiseerimise ja andmetöötluse vahel.