
### A osa - Introduction to Ansible

**A1.1** Ansible automatiseerib IT-ülesandeid mitme masina peal korraga: tarkvara paigaldust, konfiguratsiooni seadistamist, rakenduste väljarullimist ja keerukamaid mitmesammulisi protsesse (orkestratsioon).

**A1.2** Tavaline skript (Bash, Python) on "tee see, siis tee see". Iga kord, kui sa skripti käivitad, käivad samad käsud läbi, ükskõik kas süsteem on juba õiges seisus või mitte. Ansiblega ütled "selles masinas peab nginx olemas olema", ja Ansible vaatab ise, kas see juba on (siis ei tee midagi) või tuleb installida. Lisaks töötab Ansible mitme masina peal paralleelselt ühe käsuga, samas kui Bash-skripti peaks SSH-iga eraldi igale masinale viskama.

### 2. Start automating with Ansible

**A2.1** **Control node** on masin, kus Ansible ise installitud on ja kust sa käske annad — minu puhul oleks see WSL Ubuntu mu sülearvutis (või eraldi Linuxi VM). **Managed node** on iga sihtmasin, mida ma haldan — võiks olla mu VirtualBoxis jooksvad Debian ja Ubuntu VM-id, aga päris elus serverid pilves.

**A2.2** Esimene näide on tavaliselt `ansible all -m ping` — see käsk võtab kõik inventory's olevad hostid (`all`), kasutab `ping` moodulit (`-m ping`) ja kontrollib, kas Ansible saab nendega SSH kaudu ühenduse. See pole tavaline ICMP ping vaid Ansible enda test, mis kontrollib SSH+Pythoni saadavust.

**A2.3** Ei nõua, vähemalt mitte Ansible-spetsiifilist tarkvara. Sihtmasinas peab olema **SSH server** (tavaline asi Linuxis nagunii) ja **Python**. Ansible kasutab seda, sest saadab SSH kaudu Pythoni mooduli sihtmasinasse, käivitab selle, võtab tulemuse ja koristab enda järelt. See on Ansible'i suur müügiargument: pole vaja igale serverile mingit "agent"-tarkvara installida nagu Puppeti või Chef-i puhul.

### 3. Building an inventory

**A3.1** Inventory on **nimekiri masinatest, mida Ansible haldab**. See on kas üks fail (vaikimisi `/etc/ansible/hosts`) või kataloog mitme failiga, ning seal on kirjas hostide aadressid (IP või domeen) ja nende grupeering.

**A3.2** Vähemalt **INI-formaat** (lihtsam, oldschool) ja **YAML-formaat** (uuem, struktureeritum). Ansible toetab ka dünaamilisi inventory'sid, mis on Pythoni skriptid, mis genereerivad nimekirja jooksvalt (näiteks AWS API-st).

**A3.3** Grupid lasevad sul kogu sama tüüpi masinatele korraga reegleid rakendada. Näide: kui sul on `[veebiserverid]` grupp 12 masinaga ja `[andmebaasid]` grupp 4 masinaga, saad öelda playbook'is `hosts: veebiserverid` ja nginx läheb ainult veebiserveritesse, mitte andmebaasimasinatesse. Ilma gruppideta peaksid iga masina nime kirja panema või tegema kõike kõigis, mis kaotab Ansible kasutuse põhimõtte.

### 4. Creating a playbook

**A4.1** Playbook'id on **YAML**-formaadis. YAML kasutab **taanet** struktuuri näitamiseks (nagu Python), aga see pole programmeerimiskeel, sest see on **andmete kirjeldamise keel**. Sa ei kirjuta tsükleid ega if-lauseid Pythonist tuttaval moel; sa kirjeldad andmestruktuuri (loendid, sõnastikud) ja Ansible interpreteerib seda. Seega võrreldes Pythoni või Bashiga on YAML palju "passiivsem" — see kirjeldab seisundit, mitte tegevust.

**A4.2** **Task** on üks samm playbook'is — üks toiming, mida Ansible peab tegema. Iga task kasutab ühte **moodulit** (näiteks `apt`, `copy`, `service`) ja annab sellele parameetrid. Näiteks "paigalda nginx" on üks task, "loo konfifail" on teine task.

**A4.3** `hosts:` ütleb, **millise grupi (või masina) peal** see play käib — ehk inventory'ist tuuakse vastavad masinad ja taskid jooksevad nende peal. `become:` tähendab, et task'e käivitatakse **kõrgendatud õigustega** (nagu Linuxis sudo, Windowsis runas). Tavakasutaja ei saa `apt install`-i teha, seega `become: yes` ütleb Ansible'ile "kasuta sudo'd".

### 5. Ansible concepts



Control node - Masin, kuhu Ansible on installitud ja kust sa käske annad.

Managed node - Sihtmasin, mida Ansible SSH/Pythoni kaudu seadistab.

Inventory - Nimekiri haldavatest masinatest (sageli grupeeritud).

Playbook - YAML-fail, mis kirjeldab, mis tuleb teha ja kus.

Play - Üks "tükk" playbook'is — määratud grupile (hosts) suunatud tasks'ide hulk. 

Task - Üks samm play's — kutsub välja ühe mooduli (nt apt install nginx). 

Module - Konkreetne tööriist, mida task kasutab (apt, copy, service, file...). 

Handler - Eriline task, mis käivitub ainult siis, kui mõni teine task talle "notify" saadab (nt nginx restart). 

Collection - Pakett, mis sisaldab mooduleid, role'isid, plugin'eid jms — jagatav ja versioneeritud üksus.

**A5.1** **Module** käivitub sihtmasinas ja teeb seal mingi konkreetse asja (paigalda pakk, kopeeri fail). **Plugin** käivitub control node'is ja **muudab Ansible'i enda käitumist** — näiteks connection plugin (kuidas SSH-ga ühendutakse), callback plugin (kuidas väljund kuvatakse), lookup plugin (kust vars-id kätte saadakse). Lihtne mõttemudel: moodul = mida tehakse sihtmasinas, plugin = kuidas Ansible ise toimib.

**A5.2** **Task** käivitub alati, kui play sealt mööda läheb — iga kord kui playbook'i jooksutad. **Handler** käivitub ainult siis, kui mõni task on talle `notify:`-ga märku andnud, **et midagi muutus**. Lisaks käivituvad handlerid kõik **play lõpus** ühe korraga (mitte kohe pärast notify'd) ja iga handler ainult ühe korra, isegi kui mitu task'i talle notify saatis. See on optimeering: nt nginx tuleb taaskäivitada üks kord pärast 5 konfiguratsioonimuudatust, mitte 5 korda.

---

## B osa 

**B1** Bashiga teeksin midagi sellist: silmus üle hostinimede, igaühele `ssh user@host "apt install -y nginx && cat > /etc/nginx/conf.d/site.conf <<EOF ... EOF"`. Probleemid:

- Kui üks server kukub keset paigaldust, ei tea ma kindlat seisu — kas pakk paigaldati pooleldi, kas konf jõudis kohale?
- Skript jätkab teiste hostidega ega ütle automaatselt, et "host nr 7 ebaõnnestus".
- Kui üks server oli jubaolemas seadistatud, siis `apt install` jookseb ikka uuesti läbi (raisatud aeg).
- Paralleelsus tuleb käsitsi `&` ja `wait`-iga teha — on lihtne valesti teha.


**B2** Ansible muudab seda nii:

- **Üks playbook** kirjeldab soovitud seisu, mitte sammude jada.
- **Paralleelsus on sisseehitatud** (vaikimisi 5 hosti korraga, saab muuta).
- **Idempotentsus** tuleb tasuta — moodulid kontrollivad ise, kas midagi on vaja teha.
- Iga hosti tulemus on **eraldi raporteeritud** (changed, ok, failed). Kui üks ebaõnnestub, jätkab Ansible teistega ja näitab raportis selgelt, mis valesti läks.
- Saab käivitada **uuesti** ja Ansible parandab ainult selle, mis rikki läks.

**B3** Tagasi vaatesse oma viimaste harjutuste peale:

- **Notifikatsioonimoodul** — kui see oleks vaja paigaldada paljudele Windowsi serveritele, oleks Ansible (`win_*` moodulitega) parem kui käsitsi RDP-ga sisselogimine. Üks playbook → 30 serverit valmis.
- **Suurimad failid** — see on **ühekordne uurimisskript**, mille kasutaja jookseb ühes masinas ja vaatab tulemust. Ansible on siia liiga "overengineered". AGA kui ma tahaksin teha "kontrolli iganädalaselt 50 serveri kettaruumi ja saada raport e-mailile", siis Ansible (koos cron'iga või Ansible Tower'iga) sobiks väga hästi.
- **CSV harjutus / inventory analüüs** — sama lugu, see on andmete teisendus. Pole põhjust Ansible'iga lähedale tulla.

Mõttereegel: Ansible on hea, kui sa **muudad seisundit mitmes masinas korraga**. Kui sa lihtsalt **arvutad midagi välja** ühes masinas, on Python/PS lihtsam ja sobivam.

**B4** Idempotentsus = ükskõik mitu korda sa sama operatsiooni käivitad, lõpptulemus on alati sama. Esimene `apt install nginx` paigaldab; teine `apt install nginx` ütleb "already installed" ja midagi ei muutu. Bashi skript võib olla idempotent, kui sa selle nii kirjutad, aga Ansible'i moodulid on **vaikimisi** idempotentsed — sa ei pea selle pärast vaeva nägema.

---

## C osa — playbook'i analüüs

**C1** See playbook töötab grupi `veebid` peal — näha rida `hosts: veebid`. See grupp peab inventory's olema defineeritud (näiteks INI-formaadis `[veebid]` ja all hostide loend). Iga `veebid` grupi liige saab kõik allolevad taskid läbi.

**C2** `vars:` plokk defineerib **muutujad**, mida saab playbook'is hiljem `{{ ... }}` Jinja2 süntaksiga kasutada. Põhjus, miks neid eraldi hoida:

- **Loetavus** — task ise jääb lühemaks ja näeb, mida see teeb, mitte millised konkreetsed väärtused.
- **Hooldus** — kui homme tuleb nginx asendada Apache'iga, muudad ühte rida vars'is, mitte mitut taski.
- **Korduvkasutatavus** — sama playbook töötab erinevate seadetega, andes vars'e käsureal või eraldi failis.

**C3** `{{ inventory_hostname }}` on **sisseehitatud muutuja** — Ansible asendab selle iga hosti puhul **selle hosti nimega inventory's**. Kui playbook käivitub `web1`, `web2`, `web3` peal, on:

- web1-l index.html sisuga: `Tere, mina olen web1`
- web2-l: `Tere, mina olen web2`
- web3-l: `Tere, mina olen web3`

Avalehed on **erinevad**, kuigi kood on üks.

**C4** Task **"Veendu, et nginx töötab"** ja handler **"Restart nginx"** on mõlemad tasks, kuid:

- Tavaline task (`tasks:` blokis) käivitub iga kord, kui play sealt mööda läheb.
- Handler (`handlers:` blokis) käivitub **ainult siis**, kui mõni task on talle `notify: Restart nginx` saatnud, ja **ainult kui see task tegelikult midagi muutis** (`changed`).
- Handlerid käivituvad **play lõpus**, mitte kohe.

Konkreetses näites: kui task "Loo avaleht" muudab `index.html` faili (esimesel käivitamisel või kui sisu muutus), siis ta notify-b handlerit. Play lõpus käivitub "Restart nginx" ja nginx loeb uue konfi sisse. Kui avaleht polnud vaja muuta, siis nginxi ka ei taaskäivitata — pole vaja ju.

**C5** Teisel käivitamisel:

- **"Paigalda nginx"** — apt vaatab, et nginx on olemas → `ok` (mitte `changed`).
- **"Loo avaleht"** — copy võrdleb sisu, see on sama → `ok`.
- **"Veendu, et nginx töötab"** — service check, juba töötab → `ok`.
- **Handler ei käivitu**, sest ükski task ei notify-nud.

Väljundis näeksin midagi sellist:

```
PLAY RECAP **********************
web1 : ok=3  changed=0  unreachable=0  failed=0
web2 : ok=3  changed=0  unreachable=0  failed=0
web3 : ok=3  changed=0  unreachable=0  failed=0
```

`changed=0` näitab, et midagi reaalset ei juhtunud — see ongi idempotentsus. Käivitada võib turvaliselt nii mitu korda kui tahes.

---

## D osa — avatud reflektsioon

**D1** Kõige arusaamatumaks jäid **collection**'id ja **role**'id — eriti suhe nende vahel. Aru sain et collection on suurem pakett ja võib sisaldada role'isid, aga ei tea, pole kunagi role'i ise kirjutanud, nii et ei saa tunnetuslikult aru, millal mida kasutada. Plaanin pärast tundi vaadata mõnda konkreetset näidet Ansible Galaxy'st (nt `geerlingguy.nginx`).

Teine asi, mis veel peas selgeks ei läinud: **Jinja2 templating** sügavam kasutus. Lihtsa `{{ var }}` mõte sain kätte, aga kui dokumentatsioonis hakati näitama tsükleid `{% for %}` ja filtreid `{{ var | upper }}`, siis läks asi täitsa segaseks.

**D2** Üllatav oli, et Ansible **ei vaja sihtmasinatesse mingit agenti** — kogu maagia toimub SSH ja Pythoni peal. Olin alati arvanud, et selliste tööriistade kasutamiseks tuleb kõikjale midagi paigaldada (nagu antiviirus või monitooring). Aga Ansible saadab moodulid vajadusel ise kohale, käivitab ja koristab. Väga mugav ning tähendab ka seda, et serverisse saab Ansible'iga "tulla ja minna" ilma jälge jätmata.

Teine põnev avastus: **handler'ite hilinenud käivitumine** play lõpus. Esimese hooga tundus see veidrana — miks mitte kohe? Aga kui hakkasin mõtlema "5 konfimuudatust × restart = 5 restart'i vs 1 restart lõpus", sain aru, et see on tegelikult väga mõistlik.

**D3** Tulevasel IT-administraatori tööl näen kasutust:

- **Klassiruumi arvutite seadistus** — koolides tüüpiliselt 20-30 sama konfiga arvutit. Ansible'iga saaks ühe playbook'iga uue tarkvara peale rullida, kasutajakontosid hallata, printeri seadeid muuta jne.
- **Mitme veebiserveri haldus** — kui peaks kunagi pidama firmasiseseid veebiteenuseid (intranet, GitLab, Jenkins), siis Ansible hoiaks need ühes rütmis.
- **Disaster recovery** — kui server kraashib, saab Ansible'iga uue masina **algusest peale samasse seisu** taastada, ilma käsitsi sammude meenutamiseta. Kogu konfiguratsioon on koodis ja git'is.

**D4** **Aruteluküsimus:** Kus on praktikas Ansible'i piir — millal hakkab Ansible-playbook'ide haldamine ise rohkem aega võtma kui see, mille jaoks Ansible ehitati? Mis hetkest on Ansible dependancy? 50 masinat, 100 masinat, 1000 masinat?

**Lisa** 

Väga huvitav vaatamine oli NetworkChuck youtube kanalil. Jah tema materjalid on peamiselt 5 aastat vanad aga sellegi poolest on see väga hästi ja lihtsalt lahti selgitatud. 

- https://www.youtube.com/watch?v=5hycyr-8EKs&t=62s
- https://www.youtube.com/watch?v=OWKPxAgh9DU

