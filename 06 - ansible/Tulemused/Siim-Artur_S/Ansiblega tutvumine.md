### Ansiblega tutvumine 
### 1. [Introduction to Ansible](https://docs.ansible.com/projects/ansible/latest/getting_started/introduction.html)

- **A1.1 Mida Ansible automatiseerib? Kirjuta 1–2 lauset oma sõnadega.**
---    
    Ansiblega saab teoreetiliselt automatiseerida ükskõik mis ülesannet. Võimalus lihtsustada ülesandeid töövoolus, manageerida ja uuendada süsteeme. 
---
- **A1.2 Mis on sinu arust põhiline erinevus Ansible'i ja tavalise skripti (Bash, Python) vahel?**
---
    Kasutab lihtsasti loetavat keelt, alguses ehk harjumatu kuid dokumentatsiooni läbilugedes tundub arusaadav ja loogiline.
---

### 2. [Start automating with Ansible](https://docs.ansible.com/projects/ansible/latest/getting_started/get_started_ansible.html)

- **A2.1 Mis on control node ja mis on managed node? Kirjelda, kus need sinu enda arvutis võiksid olla.**
---
    Control node on süsteem, millele Ansible on installitud.
    Managed node on host või remote system, mida ansiblega saab kontrollida.
    Ansible installimiseks oleks vaja kasutada kas WSL või mõnda muud virtuaal UNIX baasi, kuhu on python installitud.
---
- **A2.2 Milline oli esimene Ansible-käsk, mida materjalis näitati? Mida see käsk teeb?**
---
    Esimene ansible käsk, mida kasutati oli
        ansible-inventory -i inventory.ini --list
    See command kinnitab loodud hostide nimistu.
---
- **A2.3 Kas Ansible nõuab sihtmasinas mingit eritarkvara installimist? Põhjenda.**
---
    Ansible ei nõua sihtmasinates mingit eritarkvara, vaja on vaid sihtmasina IP'd ja enda public SSH võtit sihtmasinas. 
---

### 3. [Building an inventory](https://docs.ansible.com/projects/ansible/latest/getting_started/get_started_inventory.html)

- **A3.1 Mis on inventory? Tee kahe lausega selgitus.**
---
    Inventory on sihtmasinate kogumik, mida on võimalik kategoriseerida erinevatel viisidel. 
---
- **A3.2 Millistes formaatides võib inventory olla? Nimeta vähemalt kaks.**
---
    Inventory luuakse kas .ini või .YAML failina, mis on lihtsasti loetav.
---
- **A3.3 Miks on grupid (`[veebiserverid]`, `[andmebaasid]` jne) inventory's kasulikud? Too näide olukorrast, kus see vahet teeks.**
---
    See aitab luua struktuuri ja manageerida kindlaid gruppe. 
---

### 4. [Creating a playbook](https://docs.ansible.com/projects/ansible/latest/getting_started/get_started_playbook.html)

- **A4.1 Mis keeles (formaadis) on playbook'id kirjutatud? Mille poolest see formaat erineb Pythonist või Bashist?**
---
    Playbook on YAML formaadis. Teksti loetakse ülevalt alla ja selles järjekorras sooritatakse ka ülesanded.
---
- **A4.2 Mis on task playbook'is?**
---
    Task on pöördumine mingile kindlale moodulile, mis defineerib ülesande mida Ansible peab tegema.
---
- **A4.3 Vaata näiteplaybook'i materjalis. Mida tähendab seal `hosts:`? Mida tähendab `become:`?**
---
    Hosts - määrab ära mis masinate grupis antud käske jooksutatakse.
    Become - saab jooksutada käsku teise kasutajana.
---

### 5. [Ansible concepts](https://docs.ansible.com/projects/ansible/latest/getting_started/basic_concepts.html)

**See on kõige tihedam alaleht. Loe läbi, siis täida tabel **oma sõnadega** (mitte koopia dokumentatsioonist):**

| Mõiste | Mida see tähendab? (1 lause) |
|---|---|
| Control node | Control node on süsteem, millele Ansible on installitud. |
| Managed node | Managed node on host või remote system, mida ansiblega saab kontrollida. |
| Inventory | Inventory on sihtmasinate kogumik |
| Playbook | Playde kogumik, loetakse ülevalt alla |
| Play | Ülesannete kogumik, mis suunatakse manageeritud sihtmasinatele |
| Task | Viide kindlale moodulile, mida ansible teostab |
| Module | Koodi jupp, mida ansible jooksutab sihtmasinatel |
| Handler | Käsk, mida jooksutatakse vaid juhul kui teine käsk sellele pöördub |
| Collection | Distributsiooni formaat, sisaldab playbooke, rolle, mooduleid ja pluginaid |

- **A5.1** Mille poolest erineb **module** ja **plugin**?
---
    Module on plugini osa, mis automatiseerib sihtmasinatel tööülesanded. Neid jooksutatakse väljaspool control node.
    Plugin on koodi jupp, mis laiendab Ansible funktsionaalsust. Neid on võimalik ka juurde kirjutada.
---
- ****A5.2** Mille poolest erineb **task** ja **handler**?**
---
    Task - individuaalne ülesanne mida teostatakse playbooki alusel.
    handler - ülesanne mida teostatakse vaid juhul, kui task selle poole pöördub, üldiselt playbooki lõpus näiteks teenuse restartimine.
---

## B osa — seos sellega, mida juba tead

Sa oled juba kirjutanud Pythoni, PowerShelli ja Bashi skripte. Mõtle nüüd Ansible'i peale selle taustal.

- **B1** Sul on 30 serverit, igaühele tuleb paigaldada nginx ja luua sama konfifail. Kuidas teeksid seda **Bashi** skriptiga? Mis läheb halvasti, kui üks server vahepeal alla kukub või paigaldus jookseb pooleldi läbi?
---
    Bashi kasutamisel võib jääda server osaliselt seadistamata, kui üks server vahepeal alla kukub.
---
- **B2** Kuidas Ansible sama ülesannet teisiti lahendab? Mis muutub?
---
    Kui server peaks maha kukkuma või paigaldus vigaseks muutuma parandab Ansible need vead järgmisel runil. 
    Server märgitakse unreachableks ja minnakse järgmise masina peale.
    Lõpp tulemusena kuvatakse masinate seisund.
---
- **B3** Vaata viimase nädala harjutusi (notifikatsioonimoodul, suurimad failid jne). Kas mõni sealne ülesanne sobiks Ansible'i kasutuseks paremini kui skriptiga? Põhjenda.
---
    
---
- **B4** Sõnasta **idempotentsus** ühes lauses oma sõnadega. *(Vihje: mõelge `apt install nginx` peale — mis juhtub teisel käivitamisel skriptiga ja mis Ansible'iga?)*
---
    Idempotentsus - lõpptulemus on alati sama, ei oma tähtsust mitu korda asja jooksutada.
---

## C osa — loe ja seleta seda playbook'i

Vaata järgnevat playbook'i. **See ei ole sinu kirjutada** — sinu töö on **selgitada igat osa** lihtsate sõnadega, nagu seletaksid kolleegile, kes Ansible'it ei tunne.

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

Vasta:

- **C1 Kelle peal see playbook töötab? Kust seda näed?**
---
    Playbook pöördub "veebid" poole, see on nähtav hosts:.
---
- **C2** Mis on `vars:` osa funktsioon? Miks ei kirjutatud `nginx` ja avalehe tekst kohe taskidesse?
---
    Vars plokis defineeritakse muutujad.
---
- **C3** Mida teeb `{{ inventory_hostname }}`? Kui playbook käivitatakse kolme serveri peal (web1, web2, web3), kas avalehed on samad või erinevad?
---
    Avalehed on erinevad, tuuakse lisaks hosti nimi.
---
- **C4** Mis vahe on **task**-il "Restart nginx" ja **handler**-il "Restart nginx"? Millal handler käivitub?
---
    Handler jooksutatakse alles siis, kui ülejäänud playbookist on teostatud.
---
- **C5** Kui käivitad selle playbook'i kaks korda järjest, mis juhtub teisel käivitamisel? Mida väljund näitab?
---
    Ansible peaks kontrollima lihtsalt üle kas vajalikud asjad on olemas. Kui algses runis kõik paigaldati ilusti siis faile üle ei kirjutata - idempotentsuse mõte.
---

## D osa — avatud reflektsioon

Need küsimused on subjektiivsed — õigeid vastuseid pole. Kirjuta lühike, aus vastus.

- **D1** Mis oli kõige **arusaamatum** koht materjalis? *(Kui kõik oli selge, siis tunnista seda julgelt — aga ole enda vastu aus.)*
---
    Kuna materjali oli palju sai õnneks siin ülesandes vajalikele küsimustele vastused kõik Ansible lehelt. Küll kiire googeldusega, et täpne vastus leida, sest branche on ansiblel endal meeletult palju ja seal otsimine võttis tükkaega.
---
- **D2** Mis tundus **üllatav** või huvitav?
---
    Pigem huvitav tundus ansible võimekus, pani mõtlema kuidas ja kas saaks tööelus rakendada.
---
- **D3** Kus **sinu enda igapäevatöös** (või tulevases töös IT-administraatorina) võiks Ansible kasulik olla?
---
    Seadmete deploymentis, alg seadistus.
---
- **D4** **Üks küsimus**, mille tahad arutelu ajal teistega või õpetajaga läbi rääkida. *(Pane see kindlasti — see on aluseks meie 12.00 algavale arutlusele.)*
---
    Kas saaks kasutada justkui nagu on ABM/MDM aga kõikide masinate jaoks. 
---