# Ansible — lugemine ja reflektsioon

**Nimi:** Rainer V

---

## A osa — lugemine ja kontrollküsimused

### 1. Introduction to Ansible

**A1.1** Mida Ansible automatiseerib?

> Ansible võimaldab automatiseerida laias laastus kõiksuguste seadmete konfiguratsioonide keskset haldust, millele saab SSH-ga ligi.

**A1.2** Mis on sinu arust põhiline erinevus Ansible'i ja tavalise skripti (Bash, Python) vahel?

> Ansible on deklaratiivne - kirjeldad soovitud lõppseisu (nt "nginx peab olema paigaldatud"), mitte samm-sammult käske. Skript on imperatiivne ja jooksutab käsud alati uuesti, olenemata sellest, mis seisus masin juba on.

### 2. Start automating with Ansible

**A2.1** Mis on control node ja mis on managed node? Kirjelda, kus need sinu enda arvutis võiksid olla.

> Control node on see, mille peal jookseb Ansible, managed node on masin, mida Ansible haldab. Enda arvutis võiks olla control node näiteks minu arvuti ja managed node VM.

**A2.2** Milline oli esimene Ansible-käsk, mida materjalis näitati? Mida see käsk teeb?

> `ansible all -m ping -i inventory.ini` - pingib kõiki masinaid, mis on inventorys.

**A2.3** Kas Ansible nõuab sihtmasinas mingit eritarkvara installimist? Põhjenda.

> Ei nõua, sest Ansible kasutab masinale ligisaamiseks SSH ühendust.

### 3. Building an inventory

**A3.1** Mis on inventory? Tee kahe lausega selgitus.

> Inventory on konfiguratsioonifail, kuhu paned kirja kõik masinad, mida soovid hallata. Konfiguratsiooni fail võib olla INI või YAML fail ning saad seal masinaid näiteks kategoriseerida, lisada neile vaikeväärtusi ja muud sellist.

**A3.2** Millistes formaatides võib inventory olla? Nimeta vähemalt kaks.

>  INI ja YAML.

**A3.3** Miks on grupid (`[veebiserverid]`, `[andmebaasid]` jne) inventory's kasulikud? Too näide olukorrast, kus see vahet teeks.

> Sedasi saab eristada, mis masinatega on tegu. Olukord, kus see vahe oleks oluline, on näiteks veebiserveri konfiguratsiooni muutmine - andmebaasiserveris pole veebiserverit, mida hallata.

### 4. Creating a playbook

**A4.1** Mis keeles (formaadis) on playbook'id kirjutatud? Mille poolest see formaat erineb Pythonist või Bashist?

> Playbookid kirjutatakse YAMLis. Python ja Bash on programmeerimiskeeled, kus kirjutad samm-sammult loogikat. YAML on andmete kirjeldamise formaat, kus pole koodi, vaid struktuur, mis ütleb Ansible'ile mida teha, mitte kuidas.

**A4.2** Mis on task playbook'is?

> Üks konkreetne toiming playbookis - näiteks paketi paigaldamine, faili kopeerimine või teenuse käivitamine. Iga task kutsub välja ühe mooduli kindlate parameetritega.

**A4.3** Vaata näiteplaybook'i materjalis. Mida tähendab seal `hosts:`? Mida tähendab `become:`?

> `hosts:` määrab ära, mis masinate peal playbook jookseb. `become:` määrab ära, kas playbook peab jooksma root kasutajana.

### 5. Ansible concepts

| Mõiste | Mida see tähendab? (1 lause) |
|---|---|
| Control node | Masin, mille peal jookseb Ansible ning mis haldab teisi masinaid. |
| Managed node | Masin, mida Ansible haldab. |
| Inventory | Fail, kus on kirjas masinad, mida Ansible haldab. |
| Playbook | YAML-fail, mis sisaldab ühte või mitut play'd ja kirjeldab, mida managed node'idel teha. |
| Play | Playbooki osa, mis seob hostide grupi konkreetsete taskidega. |
| Task | Üks konkreetne toiming, mis kutsub välja mooduli kindlate parameetritega. |
| Module | Valmis koodiüksus, mis teeb ühe kindla toimingu (nt `apt`, `copy`, `service`). |
| Handler | Task, mis käivitub ainult siis, kui mõni teine task seda `notify` kaudu teavitab. |
| Collection | Pakett, mis koondab mooduleid, pluginaid, rolle ja playbooke üheks jagatavaks tervikuks. |

**A5.1** Mille poolest erineb module ja plugin?

> Module jookseb managed node'il ja teeb seal konkreetse toimingu (nt paigaldab paketi). Plugin jookseb control node'il ja laiendab Ansible'i enda tööd (nt ühenduse loomine, väljundi kuvamine, muutujate lugemine).

**A5.2** Mille poolest erineb task ja handler?

> Task jookseb playbookis alati järjekorras. Handler on samuti task, aga käivitub ainult siis, kui mõni teine task seda `notify` kaudu teavitab ja alles kõigi taskide lõpus.

---

## B osa — seos sellega, mida juba tead

**B1** Sul on 30 serverit, igaühele tuleb paigaldada nginx ja luua sama konfifail. Kuidas teeksid seda Bashi skriptiga? Mis läheb halvasti, kui üks server vahepeal alla kukub või paigaldus jookseb pooleldi läbi?

> Bashi puhul kirjutaksin for-tsükli, mis SSH-ga ühendub igasse serverisse, jooksutab `apt install nginx` ja kopeerib konfifaili üle (nt `scp`-ga). Kui üks server alla kukub või ühendus katkeb, siis skript kas jätab selle vahele või jookseb üldse kokku ja sul pole aimugi, milline server jäi poolikuks. Uuesti käivitamisel jooksutab skript kõik käsud uuesti ka nendel serveritel, kus kõik juba korras oli.

**B2** Kuidas Ansible sama ülesannet teisiti lahendab? Mis muutub?

> Ansible'iga kirjutad ühe playbooki, kus ütled "nginx peab olema paigaldatud ja see konfifail peab olemas olema". Ansible ühendub kõigi 30 serveriga paralleelselt, mahaläinud serverid jäetakse vahele ja raporteeritakse eraldi. Uuel käivitamisel kontrollib Ansible iga taski juures, kas soovitud seisund juba kehtib - kui jah, siis ei tee midagi üle.

**B3** Vaata viimase nädala harjutusi (notifikatsioonimoodul, suurimad failid jne). Kas mõni sealne ülesanne sobiks Ansible'i kasutuseks paremini kui skriptiga? Põhjenda.

> Serverite saadavuse monitor (ülesanne B) ja süsteemi inventuur (ülesanne D) sobiks Ansible'iga paremini. Mõlema puhul on vaja sama asja teha paljudel masinatel korraga — Ansible saab inventory põhjal kõik hostid läbi käia ilma, et peaksid ise SSH-ühendusi ja tsükleid haldama. Skriptiga pead ise paralleelsuse ja veahalduse ehitama, Ansible teeb seda automaatselt.

**B4** Sõnasta idempotentsus ühes lauses oma sõnadega.

> Kui midagi peab tegema, aga see on varem juba nõuetele vastavalt tehtud, siis uuesti seda ei tehta.

---

## C osa — loe ja seleta seda playbook'i

```yaml
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
```

**C1** Kelle peal see playbook töötab? Kust seda näed?

> Playbook töötab veebiserverite peal, näen seda `hosts:` põhjal.

**C2** Mis on `vars:` osa funktsioon? Miks ei kirjutatud `nginx` ja avalehe tekst kohe taskidesse?

> See võimaldab mitu korda kasutatavaid väärtusi hallata ühes kohas. Selle playbooki puhul isegi oleks võinud panna need kohe taskidesse, aga hea tava on teha asju tulevikukindlalt juhuks, kui tekib vajadus samasid väärtusi mitmes kohas kasutada. Sellisel juhul on tulevikus millegi muutmine lihtne ühe asja ühes kohas muutmine.

**C3** Mida teeb `{{ inventory_hostname }}`? Kui playbook käivitatakse kolme serveri peal (web1, web2, web3), kas avalehed on samad või erinevad?

> `{{ inventory_hostname }}` võtab managed node'i hostname'i. Kui playbook käivitada kolme serveri peal, siis on avalehed erinevad, sest igaühel on oma hostname.

**C4** Mis vahe on task-il "Restart nginx" ja handler-il "Restart nginx"? Millal handler käivitub?

> Task käivitub playbooki käimise käigus alati, handler ainult siis, kui mingi task selle käima tõmbab `notify:` kasutades.

**C5** Kui käivitad selle playbook'i kaks korda järjest, mis juhtub teisel käivitamisel? Mida väljund näitab?

> Väljund näitab, et kõik on "OK", mitte ühtegi "Changed" tegevust, sest nginx on juba installitud ja konf fail on masinate peal identne.

---

## D osa — avatud reflektsioon

**D1** Mis oli kõige arusaamatum koht materjalis?

> Ausaltöeldes minu jaoks ei olnud midagi arusaamatut, sest olen Ansiblega tublisti kokku puutunud tööl.

**D2** Mis tundus üllatav või huvitav?

> Täna ei olnud midagi üllatavat, aga kui ise Ansible avastasin enda jaoks, siis see tundus nagu maailmapäästja, sest tööl on vaja keskselt hallata ca 200 serverit.

**D3** Kus sinu enda igapäevatöös (või tulevases töös IT-administraatorina) võiks Ansible kasulik olla?

> Suure hulga masinate keskselt haldamine kiirelt ja lihtsalt.

**D4** Üks küsimus, mille tahad arutelu ajal teistega või õpetajaga läbi rääkida.

> Jinja!
