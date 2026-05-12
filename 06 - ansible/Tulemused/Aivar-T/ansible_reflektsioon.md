# Ansible lugemis- ja reflektsiooniharjutus

Autor: Aivar Tahk  
Kursus: KIT-24  
Teema: Ansible — lugemine ja reflektsioon

---

## A osa — lugemine ja kontrollküsimused

### 1. Introduction to Ansible

**A1.1 Mida Ansible automatiseerib? Kirjuta 1–2 lauset oma sõnadega.**

Ansible automatiseerib IT-süsteemide haldamisega seotud tegevusi, näiteks tarkvara paigaldamist, konfiguratsiooni muutmist, teenuste käivitamist ja süsteemide soovitud olekus hoidmist. Selle mõte on vähendada käsitsi korduvat tööd ja teha sama tegevus mitmes masinas ühtemoodi.

**A1.2 Mis on sinu arust põhiline erinevus Ansible'i ja tavalise skripti (Bash, Python) vahel?**

Tavaline skript kirjeldab enamasti sammud, mida masin peab järjest tegema. Ansible'is kirjeldatakse pigem soovitud lõpptulemus, näiteks et nginx peab olema paigaldatud ja teenus peab töötama. Kui seis on juba õige, ei pea Ansible sama asja uuesti muutma.

---

### 2. Start automating with Ansible

**A2.1 Mis on control node ja mis on managed node? Kirjelda, kus need sinu enda arvutis võiksid olla.**

Control node on masin, kus Ansible on paigaldatud ja kust käivitatakse Ansible käsud. Managed node on masin või server, mida Ansible haldab. Minu puhul võiks control node olla minu enda arvuti või WSL/Linux keskkond ning managed node võiks olla näiteks Proxmoxi LXC konteiner või mõni Linuxi server koduvõrgus.

**A2.2 Milline oli esimene Ansible-käsk, mida materjalis näitati? Mida see käsk teeb?**

Materjalis näidati esimesena käsku `pip install ansible`. See käsk paigaldab Ansible'i Pythoni paketihalduri kaudu masinasse, kust hakkan automatiseerimist käivitama.

**A2.3 Kas Ansible nõuab sihtmasinas mingit eritarkvara installimist? Põhjenda.**

Ansible ei vaja tavaliselt sihtmasinasse eraldi agenti. Põhimõte on see, et Ansible töötab control node'is ja suhtleb managed node'idega üle olemasolevate ühenduste, näiteks SSH kaudu. Seega peab sihtmasin olema ligipääsetav ja seal peab olema vajalik käivituskeskkond, aga eraldi Ansible agenti sinna tavaliselt ei paigaldata.

---

### 3. Building an inventory

**A3.1 Mis on inventory? Tee kahe lausega selgitus.**

Inventory on fail või failide kogum, kus Ansible'ile kirjeldatakse hallatavad masinad. Seal on kirjas hostid, nende aadressid ja vajadusel ka grupid või muutujad, mille järgi Ansible teab, kuhu käske käivitada.

**A3.2 Millistes formaatides võib inventory olla? Nimeta vähemalt kaks.**

Inventory võib olla näiteks INI- või YAML-formaadis. Väiksema hulga masinate puhul on INI lihtne ja loetav, aga suurema või keerulisema struktuuri puhul on YAML parem, sest seal saab hoste, gruppe ja muutujaid selgemalt kirjeldada.

**A3.3 Miks on grupid (`[veebiserverid]`, `[andmebaasid]` jne) inventory's kasulikud? Too näide olukorrast, kus see vahet teeks.**

Grupid on kasulikud, sest siis ei pea iga serverit eraldi käsitsi välja valima. Näiteks kui mul on eraldi veebiserverid ja andmebaasiserverid, saan nginx'i paigaldada ainult grupile `[veebiserverid]`, ilma et see kogemata andmebaasiserveritele läheks.

---

### 4. Creating a playbook

**A4.1 Mis keeles (formaadis) on playbook'id kirjutatud? Mille poolest see formaat erineb Pythonist või Bashist?**

Playbook'id on kirjutatud YAML-formaadis. YAML ei ole tavaline käsureaskript nagu Bash ega programmeerimiskeel nagu Python, vaid pigem kirjeldav formaat, kus pannakse kirja soovitud tegevused ja seaded loetava struktuurina.

**A4.2 Mis on task playbook'is?**

Task on playbook'is üks konkreetne tegevus, mida Ansible peab tegema. Näiteks võib task kontrollida ühendust, paigaldada paketi, kopeerida faili või käivitada teenuse.

**A4.3 Vaata näiteplaybook'i materjalis. Mida tähendab seal `hosts:`? Mida tähendab `become:`?**

`hosts:` määrab, milliste inventory's olevate masinate või gruppide peal playbook käivitatakse. `become:` tähendab, et Ansible kasutab kõrgemaid õigusi, näiteks root-õigusi, kui tegevus seda vajab.

---

### 5. Ansible concepts

| Mõiste | Mida see tähendab? |
|---|---|
| Control node | Masin, kust Ansible käske käivitatakse. Seal on Ansible paigaldatud ja sealt juhitakse teisi masinaid. |
| Managed node | Hallatav masin ehk server, konteiner, võrguseade või muu host, mida Ansible seadistab. |
| Inventory | Fail või allikas, kus on kirjas hallatavad masinad, nende aadressid, grupid ja vajadusel muutujad. |
| Playbook | YAML-formaadis automatiseerimisfail, mis kirjeldab, mida Ansible peab tegema. |
| Play | Playbook'i osa, mis seob kindla hostide grupi konkreetsete task'idega. |
| Task | Üks konkreetne tegevus play sees, näiteks paketi paigaldamine või teenuse käivitamine. |
| Module | Ansible'i kasutatav tööriist või koodiosa, mis teeb konkreetse tegevuse managed node'i peal. |
| Handler | Eriline task, mis käivitub ainult siis, kui mõni eelnev task sellest teavitab, näiteks teenuse restart pärast konfiguratsiooni muutumist. |
| Collection | Ansible'i sisu jagamise formaat, mis võib sisaldada mooduleid, rolle, pluginaid ja playbook'e. |

**A5.1 Mille poolest erineb module ja plugin?**

Module teeb managed node'i peal konkreetse töö ära, näiteks paigaldab paketi, kopeerib faili või haldab teenust. Plugin laiendab Ansible'i enda käitumist control node'i poolel, näiteks ühenduse, inventari, muutujate või väljundi töötlemisel.

**A5.2 Mille poolest erineb task ja handler?**

Task on tavaline tegevus, mida playbook käivitab oma järjekorras. Handler on eriline task, mis käivitub ainult siis, kui mõni teine task teda `notify` kaudu kutsub, näiteks pärast konfiguratsioonifaili muutmist teenuse restartimiseks.

---

## B osa — seos sellega, mida juba tead

**B1 Sul on 30 serverit, igaühele tuleb paigaldada nginx ja luua sama konfifail. Kuidas teeksid seda Bashi skriptiga? Mis läheb halvasti, kui üks server vahepeal alla kukub või paigaldus jookseb pooleldi läbi?**

Bashi skriptiga teeksin tõenäoliselt tsükli, mis käib serverite nimekirja läbi ja käivitab igas serveris SSH kaudu käsud, näiteks `apt install nginx`, konfifaili kopeerimise ja teenuse taaskäivitamise. Probleem tekib siis, kui üks server on maas või paigaldus jääb pooleli: skript võib edasi joosta, aga lõpuks on osad serverid õigesti seadistatud, osad poolikult ja osad üldse tegemata. Siis peab käsitsi kontrollima, kus viga tekkis ja mida võib uuesti käivitada.

**B2 Kuidas Ansible sama ülesannet teisiti lahendab? Mis muutub?**

Ansible puhul paneksin serverid inventory faili ja kirjeldaksin playbook'is soovitud lõpptulemuse: nginx peab olema paigaldatud, konfifail peab olema õiges kohas ja teenus peab töötama. Erinevus on selles, et Ansible annab iga hosti kohta tulemuse ja teeb muudatusi ainult seal, kus seis ei vasta soovitule. Kui mõni server on ajutiselt maas, saab hiljem playbook'i uuesti käivitada ja Ansible parandab ainult puudu oleva osa.

**B3 Vaata viimase nädala harjutusi (notifikatsioonimoodul, suurimad failid jne). Kas mõni sealne ülesanne sobiks Ansible'i kasutuseks paremini kui skriptiga? Põhjenda.**

Suurimate failide otsimise harjutus sobib pigem skriptiks, sest see on ühekordne kontroll või raport. Ansible sobiks paremini siis, kui sama kontrolli või seadistust oleks vaja teha paljudes masinates korraga, näiteks paigaldada notifikatsioonimoodul mitmesse serverisse, panna paika sama konfiguratsioon või kontrollida, et vajalikud paketid ja teenused oleksid igal pool olemas.

**B4 Sõnasta idempotentsus ühes lauses oma sõnadega.**

Idempotentsus tähendab, et sama tegevust võib mitu korda käivitada, aga kui süsteem on juba soovitud seisus, siis uut muudatust ei tehta.

---

## C osa — playbook'i selgitus

**C1 Kelle peal see playbook töötab? Kust seda näed?**

See playbook töötab inventory grupi `veebid` masinate peal. Seda näeb realt `hosts: veebid`, mis määrab, millistele hostidele see playbook rakendatakse.

**C2 Mis on `vars:` osa funktsioon? Miks ei kirjutatud `nginx` ja avalehe tekst kohe taskidesse?**

`vars:` osa all määratakse muutujad, mida saab hiljem taskides kasutada. `nginx` ja avalehe sisu ei kirjutatud otse taskidesse sellepärast, et muutujatega on playbook'i lihtsam muuta ja taaskasutada. Kui hiljem on vaja paketi nime või avalehe teksti muuta, saab seda teha ühes kohas.

**C3 Mida teeb `{{ inventory_hostname }}`? Kui playbook käivitatakse kolme serveri peal (web1, web2, web3), kas avalehed on samad või erinevad?**

`{{ inventory_hostname }}` asendatakse selle hosti nimega, mille peal Ansible parajasti task'i käivitab. Kui playbook käivitatakse serveritel `web1`, `web2` ja `web3`, siis avalehed on sisult erinevad, sest igal lehel kuvatakse vastava serveri nimi.

**C4 Mis vahe on task'il "Restart nginx" ja handler'il "Restart nginx"? Millal handler käivitub?**

Selles playbook'is ei ole tavalist task'i nimega `Restart nginx`; see on handler. Handler käivitub ainult siis, kui `copy` task teeb muudatuse ja kutsub seda `notify: Restart nginx` kaudu. Kui avalehe fail ei muutu, siis handler ei käivitu.

**C5 Kui käivitad selle playbook'i kaks korda järjest, mis juhtub teisel käivitamisel? Mida väljund näitab?**

Teisel käivitamisel ei peaks Ansible enam samu muudatusi uuesti tegema, kui nginx on juba paigaldatud, avaleht on õige sisuga ja teenus töötab. Väljundis peaks olema näha, et enamik task'e on `ok` seisus ning `changed` on väike või null. See näitab idempotentsust ehk seda, et playbook ei muuda süsteemi uuesti, kui soovitud seis on juba saavutatud.

---

## D osa — avatud reflektsioon

**D1 Mis oli kõige arusaamatum koht materjalis?**

Kõige arusaamatum koht oli alguses see, kuidas Ansible'i erinevad mõisted omavahel täpselt seostuvad: playbook, play, task, module ja handler. Eraldi võttes on need arusaadavad, aga alguses on keeruline näha kogu töövoogu tervikuna.

**D2 Mis tundus üllatav või huvitav?**

Huvitav oli see, et Ansible ei tööta ainult käsureaskripti moodi, vaid kirjeldab pigem süsteemi soovitud lõppseisu. See teeb korduva käivitamise turvalisemaks, sest sama playbook'i saab uuesti käivitada ilma, et iga kord kõike nullist üle tehtaks.

**D3 Kus sinu enda igapäevatöös või tulevases töös IT-administraatorina võiks Ansible kasulik olla?**

Ansible võiks olla kasulik Linuxi serverite ja konteinerite ühesuguseks seadistamiseks, näiteks pakettide paigaldamisel, konfiguratsioonifailide haldamisel, teenuste käivitamisel ja kontrollimisel. Minu jaoks oleks see eriti kasulik olukorras, kus sama seadistus tuleb teha mitmes serveris või LXC konteineris ja käsitsi tegemine muutuks veaohtlikuks.

**D4 Üks küsimus, mille tahad arutelu ajal teistega või õpetajaga läbi rääkida.**

Küsimus aruteluks: millal on mõistlik kasutada Ansible'it ja millal piisab tavalisest Bash-, PowerShelli- või Pythoni skriptist?