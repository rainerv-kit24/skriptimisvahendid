ANSIBLE

1. Introduction to Ansible
A1.1 Mida Ansible automatiseerib? 
Ansible automatiseerib praktiliselt iga ülesande kasutades lihtsaid inimloetavaid scripte mida kutsutakse playbookideks. Ansiblega saab teha samu toiminguid mitmes masinas korraga. 

A1.2 Mis on sinu arust põhiline erinevus Ansible'i ja tavalise skripti (Bash, Python) vahel?
Ansible on spetsiaalselt loodud mitme masina haldamiseks.

2. Start automating with Ansible 
A2.1 Mis on control node ja mis on managed node? 
Control node on ansible aju, ehk siis süsteem kuhu ansible on installitud. Managed node on põhimõtteliselt server, virtuaalne masin või pilv mida ansible haldab. Minu arvutis võiks control node olla minu PC ja managed node näiteks Virtualboxi masin.

A2.2 Milline oli esimene Ansible-käsk, mida materjalis näitati? 
Esimene käsk oli "pip install ansible" mis paigaldab tarkvara.

A2.3 Kas Ansible nõuab sihtmasinas mingit eritarkvara installimist? Põhjenda.
Ansible ei nõua mingit eritarkvara. Piisab kui on SSH ligipääs, sest ansible töötab üle SSH.

3. Building an inventory
A3.1 Mis on inventory? Tee kahe lausega selgitus.
Inventory on masinate nimekiri, mida ansible haldab. Seal määratakse nende aadressid ja grupid.

A3.2 Millistes formaatides võib inventory olla? Nimeta vähemalt kaks.
*INI format
*YAML formaat

A3.3 Miks on grupid ([veebiserverid], [andmebaasid] jne) inventory's kasulikud? Too näide olukorrast, kus see vahet teeks.
Grupid aitavad jagada serverid rollide järgi (nt veebiserverid, andmebaasid). See omakorda annab võimaluse teha nii, et uuendus läheks ainult veebiserverile, mitte andmebaasile.

4. Creating a playbook
A4.1 Mis keeles (formaadis) on playbook'id kirjutatud? Mille poolest see formaat erineb Pythonist või Bashist?
Playbookid on kirjutatud YAML keeles. See erineb pythonist või bashist ülesehituse poolelt ja pigem kirjeldab soovitud tulemust

A4.2 Mis on task playbook'is?
Task on üks konkreetne tegevus playbook’is, näiteks paketi installimine või faili kopeerimine.

A4.3 Vaata näiteplaybook'i materjalis. Mida tähendab seal hosts:? Mida tähendab become:?
*hosts: määrab, millistele masinatele see playbook kehtib
*become: tähendab, et käsku tehakse kõrgemate õigustega (nt root kasutajana)

5. Ansible concepts
Mõiste	Mida see tähendab? (1 lause)
Control node - Arvuti, kust Ansible käske käivitatakse ja teisi masinaid juhitakse.
Managed node - Masin (server või arvuti), mille peal Ansible tegevusi teeb.
Inventory - Nimekiri kõikidest masinatest ja gruppidest, mida Ansible haldab.
Playbook - YAML-fail, mis kirjeldab samm-sammult, mida masinatega teha.
Play - Üks osa playbook’ist, mis määrab tegevused kindla masinagrupi jaoks.
Task - Üks konkreetne tegevus play sees, näiteks paketi installimine.
Module - Valmis funktsioon, mida task kasutab mingi töö tegemiseks.
Handler - Task, mis käivitub ainult siis, kui midagi on muutunud (nt teenuse restart).
Collection - Kogumik moodulitest, pluginatest ja muudest Ansible komponentidest.

A5.1 Mille poolest erineb module ja plugin?
Module teeb konkreetse töö sihtmasinas nt installib paketi. Plugin aga kuidas ühendus luuakse või andmeid töödeldakse.
A5.2 Mille poolest erineb task ja handler?
Task käivitatakse alati playbooki käigus, handler ainult siis kui mõni task tegi muudatuse.

B osa — seos sellega, mida juba tead
B1
Bashiga kirjutaksin skripti, mis SSH kaudu läheks igasse serverisse, installib nginxi ja kopeerib konfifaili. Kui server alla kukub või paigaldus pooleldi läbi kukub siis või skript pooleli jääda või osa samme jääb tegemata. Server võib jääda poolikusse olekusse ja skript ei pruugi aru saada, mida juba tehti.

B2
Ansible teeb seda mitmes serveris korraga sealhulgas haldab ühendusi, kontrollib uuenduste seisu, jätkab pooleli jäänud või ebaõnnestunuid uuendusi.

B3
Väga hästi võiks sobida näiteks teavituste mooduli harjutus kui seda peaks tegema mitmes masinas, sest siis saaks ühe käsuga kõik serverid läbi käia.

B4
Idempotentsus tähendab seda, et sama käsku võib mitu korda käivitada ja tulemus jääb ikka samaks, ilma et midagi katki läheks või dubleeruks.

C osa — loe ja seleta seda playbook'i
C1 
Playbook töötab "veebid" kuuluvatel serveritel.(Seda näeb realt hosts: veebid)

C2
vars: osa hoiab muutujaid, mida saab hiljem kasutada.
nginx'i ja avalehe teksti ei kirjutatud kohe taskidesse, et koodi oleks lihtsam muuta ja uuesti kasutada.

C3
{{ inventory_hostname }}tähendab konkreetse serveri nime.
Kui on web1, web2, web3, siis iga serveri avaleht on erinev, sest sinna pannakse selle serveri nimi.

C4
Task “Restart nginx” annab lihtsalt märku.
Handler “Restart nginx” teeb tegelikult restardi ja käivitub ainult siis, kui fail muutus.

C5
Teisel käivitamisel ei tehta enam muudatusi, sest kõik on juba paigas.
Väljund näitab enamasti “ok”, mitte “changed”.

D osa — avatud reflektsioon
D1
Materjalis oli minu jaoks kõige arusaamatum A osa kuna vastused pole otsest välja toodud ja tekst inglise keeles(Nõuab süvenemist).

D2
Minu jaoks tuli Ansible puhul üllatuseks, et ta kontrollib ise kas midagi on juba tehtud või pooleli ja vajadusel jätkab ise.

D3
Ansible oleks kasulik serverite seadistamisel ja haldamisel, näiteks tarkvara paigaldamisel, uuenduste tegemisel. See säästaks IT-spetsi aega ja vähendaks käsitsi tehtavaid vigu.

D4
Kuidas saaks hallata keerulisemaid olukordi? näiteks kui serveritel peab olema erinev konfiguratsioon?