**A osa — lugemine ja kontrollküsimused**

--1. Introduction to Ansible--

    A1.1 Mida Ansible automatiseerib? Kirjuta 1–2 lauset oma sõnadega.

See automatiseerib serverite manageerimist ehk mitme serveri haldamiselt ei pea igat serverit haldama manuaalselt vaid ansamblet kasutades saab seda teha ühe ühest kohast. Taskide hulka kuulub näiteks tarkvarauuendused ja confid.

    A1.2 Mis on sinu arust põhiline erinevus Ansible'i ja tavalise skripti (Bash, Python) vahel?

Tavalise bashiga sa manuaalselt kirjeldad igat sammu mis vaja teha. Ansamblet kasutades kirjeldad lõpptulemuse mis peaks olema saavutatud.

--2. Start automating with Ansible--

    A2.1 Mis on control node ja mis on managed node? Kirjelda, kus need sinu enda arvutis võiksid olla.

	Control node on masin millega sa teed kontrolli taske ning managed node on manageeritav masin. Control nodeks võib olla sinu masin nind manageeritavaks masin localhost või VM. 

    A2.2 Milline oli esimene Ansible-käsk, mida materjalis näitati? Mida see käsk teeb?

	Esimene cmd oli "pip install ansible". See laeb alla vajalikud packagid

    A2.3 Kas Ansible nõuab sihtmasinas mingit eritarkvara installimist? Põhjenda.

	Ei nõua kuna Ansible on agentless. Ta kasutab pythonit mis on suhteliselt standartne ning sshd teise masinaga ühendamiseks. 

--3. Building an inventory--

    A3.1 Mis on inventory? Tee kahe lausega selgitus.

	Inventory on ini file kus on ära kirjeldatud kõik masinad mida Ansible haldab. Inventory failis on ära kirjeldatud ainult hosti IP aadress. 

    A3.2 Millistes formaatides võib inventory olla? Nimeta vähemalt kaks.

	Inventory võib olla ini või yaml formaadis.

    A3.3 Miks on grupid ([veebiserverid], [andmebaasid] jne) inventory's kasulikud? Too näide olukorrast, kus see vahet teeks.

	Võib olla kasulik et endal oleks parem ülevaade manageeritud masinatest. Näiteks olukorras kus sul on palju masinaid ning sa tahad kontrollida kas hallatav server on ikka listis olemas. Sellisel juhul tuleks eraldada [serverid] [masinad] vms.

4. Creating a playbook

    A4.1 Mis keeles (formaadis) on playbook'id kirjutatud? Mille poolest see formaat erineb Pythonist või Bashist?

	Playbookid on yaml formaadis. See formaat on deklaratiivne ehk ta pole programmeerimiskeel nagu python või bash vaid see on inimese jaoks arusaadavam keel mis haldab python või bash tegevusi. 

    A4.2 Mis on task playbook'is?

	Task on üks tegevus mis on kirjeldatud playbookis. Taskid asuvad play listis. Playbook koosneb erinevatest playdes.

    A4.3 Vaata näiteplaybook'i materjalis. Mida tähendab seal hosts:? Mida tähendab become:?
	
	Hosts on need masinad mis said kirjeldatud inventory all. Become: ?

--5. Ansible concepts--

See on kõige tihedam alaleht. Loe läbi, siis täida tabel oma sõnadega (mitte koopia dokumentatsioonist):
Mõiste 	Mida see tähendab? (1 lause)

Control node 	See on masin mille peal kasutatakse kõiki haldavaid commande
Managed node 	See on masin mida mõjutatakse control node pealt
Inventory 	See on nimekiri kõikidest masinatest mida mõjutatakse
Playbook 	See on fail mis kirjeldab ära milliseid mõjutusi tehakse
Play 		See on Playbookis olev alapeatükk kus on ära kirjeldatud millised taskid mõjutusteks tehakse
Task 		See on kindel tegevus mis on vaja teha suurema plaani täitmiseks
Module 		See on kood mida kasutatakse taskide tegemiseks juhul kui see on vajalik
Handler 	See on Task mis läheb täitmisele juhul kui eelnev Task on seda nõudnud teatud põhjusetel
Collection 	Põhimõtteliselt programm, ehk failide kogum mis teeb midagi milleks ta on juba kokku pandud.

    A5.1 Mille poolest erineb module ja plugin?

	Module on juba kaasa antud Ansible installides, plugin on lisa kood mis annab erinevaid võimalusi haldamiseks juurde.

    A5.2 Mille poolest erineb task ja handler?
	
	Handler on Task mis ei alusta tööd iseseisvalt vaid mis nõuab eelneva taski sisendit et ta tööle hakkaks.

B osa — seos sellega, mida juba tead

Sa oled juba kirjutanud Pythoni, PowerShelli ja Bashi skripte. Mõtle nüüd Ansible'i peale selle taustal.

    B1 Sul on 30 serverit, igaühele tuleb paigaldada nginx ja luua sama konfifail. Kuidas teeksid seda Bashi skriptiga? Mis läheb halvasti, kui üks server vahepeal alla kukub või paigaldus jookseb pooleldi läbi?

	Kui üks server maha kukub, siis ma peaksin hakkama manuaalselt selle serveri confimist  otsast peale et kõik saaks õigesti tehtud. 

    B2 Kuidas Ansible sama ülesannet teisiti lahendab? Mis muutub?
	
	Ansible abiga mul on kõik serverid inventorys ning playbooki kasutades veendub Ansible ise, et kõik taskid saaksid tehtud. Serveri maha kukkudes ei mõjuta see taskide teostamist selles suhtes et kogu inventory haldamine käib control nodes ning saaksin control nodes kohe teate et mahakukkunud serveris läks midagi valesti.

    B3 Vaata viimase nädala harjutusi (notifikatsioonimoodul, suurimad failid jne). Kas mõni sealne ülesanne sobiks Ansible'i kasutuseks paremini kui skriptiga? Põhjenda.

	Võibolla oleks mitme failiga harjutuste puhul ülesande täitmine lihtsam kui kõik info on ühes playbookis olemas.

    B4 Sõnasta idempotentsus ühes lauses oma sõnadega. (Vihje: mõelge apt install nginx peale — mis juhtub teisel käivitamisel skriptiga ja mis Ansible'iga?)

	Skripti ülesanne oleks teha mingisugune liigutus läbi olenemata olemasolevast seisust. Selles kontekstis idempotentust tähendab et Ansible ei hakka nginx uuesti installima kui see on juba olemas vaid ta lähtub püstitatud ülesandest "nginx on installitud". 

--C osa — loe ja seleta seda playbook'i--

Vaata järgnevat playbook'i. See ei ole sinu kirjutada — sinu töö on selgitada igat osa lihtsate sõnadega, nagu seletaksid kolleegile, kes Ansible'it ei tunne.

---
- name: Seadista veebiserverid
  hosts: veebid
  become: yes

  vars:
    nginx_pakk: nginx
    avaleht_sisu: "Tere, mina olen {{ inventory_hostname }}"

  tasks:

    - name: Paigalda nginx
      apt:
        name: "{{ nginx_pakk }}"
        state: present
        update_cache: yes

    - name: Loo avaleht
      copy:
        content: "{{ avaleht_sisu }}"
        dest: /var/www/html/index.html
      notify: Restart nginx

    - name: Veendu, et nginx töötab
      service:
        name: nginx
        state: started
        enabled: yes

  handlers:

    - name: Restart nginx
      service:
        name: nginx
        state: restarted

Vasta:

    C1 Kelle peal see playbook töötab? Kust seda näed?

	Control modulit ei näe aga hostid on "veebid" mis on täpsemalt kirjeldatud inventorys.

    C2 Mis on vars: osa funktsioon? Miks ei kirjutatud nginx ja avalehe tekst kohe taskidesse?

	Nii on lihtsam kasutada playbooki ka teiste tööde jaoks ehk saab ära muuta paki. Samuti on lihtsam ära muuta avalehe sisu. 

    C3 Mida teeb {{ inventory_hostname }}? Kui playbook käivitatakse kolme serveri peal (web1, web2, web3), kas avalehed on samad või erinevad?

	Sisu peaks olema sama kui inventory hostname on nende webide kategooria nimi ehk hosts = veebid. Sellisel juhul peaks olema Tere, mina olen veebid?


    C4 Mis vahe on task-il "Restart nginx" ja handler-il "Restart nginx"? Millal handler käivitub?

	Handler käivitub alles peale seda kui avaleht on loodud. Selle taski edukalt läbimisel on alles mõtet restartida enginx. Lisaks playbooki uuesti jooksutamisel pole mõtet nginx restartida kui kõik on nii nagu peab ehk seda taski ei runnita. 

    C5 Kui käivitad selle playbook'i kaks korda järjest, mis juhtub teisel käivitamisel? Mida väljund näitab?

	Väljund näitab et enginx on olemas, avaleht on olemas ning nginx töötab. Uuesti avalehte looma ei hakata ning nginx ei restardita. 

D osa — avatud reflektsioon

Need küsimused on subjektiivsed — õigeid vastuseid pole. Kirjuta lühike, aus vastus.

    D1 Mis oli kõige arusaamatum koht materjalis? (Kui kõik oli selge, siis tunnista seda julgelt — aga ole enda vastu aus.)

	Läbitöötatud osas ei olnud otseselt midagi arusaamatut. Hetkel veel pole kogu playbooki ülesehitus nii selge. 

    D2 Mis tundus üllatav või huvitav?

	Üllatas et ülesehitus on nii kergesti arusaadav inimese jaoks. Samuti imestas kui lihtsaks see muudab mitme serveri haldamise. Lisaks oleks seda kasutada ka mitmes koolitöös. 

    D3 Kus sinu enda igapäevatöös (või tulevases töös IT-administraatorina) võiks Ansible kasulik olla?

	See võib olla väga kasulik tööriist kui sul on rohkem kui 1 server mida pead haldama.

    D4 Üks küsimus, mille tahad arutelu ajal teistega või õpetajaga läbi rääkida. (Pane see kindlasti — see on aluseks meie 12.00 algavale arutlusele.)

	Küsimus selle kohta kas C osa ülesandest sai õigesti vastatud, kui ei siis mis on õige