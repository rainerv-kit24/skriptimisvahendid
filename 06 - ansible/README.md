# Iseseisev töö: Ansible — lugemine ja reflektsioon

**Kursus:** KIT-24
**Õpetaja:** Toivo Pärnpuu
**Aeg:** 10.00–12.00 (2 akadeemilist tundi)
**Materjal:** [Getting started with Ansible](https://docs.ansible.com/projects/ansible/latest/getting_started/index.html)

---

## Eesmärk

Tutvud Ansible'i ametliku sissejuhatava materjaliga, paned kokku enda mõtted ja valmistud teise poole arutluseks. Selle harjutuse tulemus pole "õige vastus" — vaid sinu enda sõnastus. Eesmärk on, et tuleksid kell 12.00 lauda **mõtte ja küsimusega**, mitte tühja peaga.

---

## Kuidas see töötab

1. **Loed läbi** viis ametliku dokumentatsiooni alalehte (~30–40 min)
2. **Vastad küsimustele** oma sõnadega markdown-failis (~45 min)
3. **Analüüsid ühe playbook'i** ja kirjutad, mida see teeb (~20 min)
4. **Saadad oma vastused** PR-iga ja paned valmis ühe küsimuse aruteluks (~15 min)

Pole vaja kirjutada esseesid — lühikesed, ausad vastused on paremad kui pikad ja udused. Kui mingit kohta ei mõista, kirjuta seda julgelt nii — see ongi reflektsiooni mõte.

> **Pane tähele:** Vahepeal olen koosolekul ja küsimustele kohe ei vasta. Kogu küsimused Teamsi vestlusse — vastan pausidel ja kindlasti kell 12.00.

---

## A osa — lugemine ja kontrollküsimused

Loe alalehed läbi selles järjekorras. Iga alalehe kohta vasta paaride kaupa küsimustele oma sõnadega — pole vaja tsiteerida, vaid sõnastada nii, nagu ise mõistsid.

### 1. [Introduction to Ansible](https://docs.ansible.com/projects/ansible/latest/getting_started/introduction.html)

- **A1.1** Mida Ansible **automatiseerib**? Kirjuta 1–2 lauset oma sõnadega.
- **A1.2** Mis on sinu arust põhiline erinevus Ansible'i ja tavalise skripti (Bash, Python) vahel?

### 2. [Start automating with Ansible](https://docs.ansible.com/projects/ansible/latest/getting_started/get_started_ansible.html)

- **A2.1** Mis on **control node** ja mis on **managed node**? Kirjelda, kus need sinu enda arvutis võiksid olla.
- **A2.2** Milline oli esimene Ansible-käsk, mida materjalis näitati? Mida see käsk teeb?
- **A2.3** Kas Ansible nõuab sihtmasinas mingit eritarkvara installimist? Põhjenda.

### 3. [Building an inventory](https://docs.ansible.com/projects/ansible/latest/getting_started/get_started_inventory.html)

- **A3.1** Mis on **inventory**? Tee kahe lausega selgitus.
- **A3.2** Millistes formaatides võib inventory olla? Nimeta vähemalt kaks.
- **A3.3** Miks on grupid (`[veebiserverid]`, `[andmebaasid]` jne) inventory's kasulikud? Too näide olukorrast, kus see vahet teeks.

### 4. [Creating a playbook](https://docs.ansible.com/projects/ansible/latest/getting_started/get_started_playbook.html)

- **A4.1** Mis keeles (formaadis) on playbook'id kirjutatud? Mille poolest see formaat erineb Pythonist või Bashist?
- **A4.2** Mis on **task** playbook'is?
- **A4.3** Vaata näiteplaybook'i materjalis. Mida tähendab seal `hosts:`? Mida tähendab `become:`?

### 5. [Ansible concepts](https://docs.ansible.com/projects/ansible/latest/getting_started/basic_concepts.html)

See on kõige tihedam alaleht. Loe läbi, siis täida tabel **oma sõnadega** (mitte koopia dokumentatsioonist):

| Mõiste | Mida see tähendab? (1 lause) |
|---|---|
| Control node | |
| Managed node | |
| Inventory | |
| Playbook | |
| Play | |
| Task | |
| Module | |
| Handler | |
| Collection | |

- **A5.1** Mille poolest erineb **module** ja **plugin**?
- **A5.2** Mille poolest erineb **task** ja **handler**?

---

## B osa — seos sellega, mida juba tead

Sa oled juba kirjutanud Pythoni, PowerShelli ja Bashi skripte. Mõtle nüüd Ansible'i peale selle taustal.

- **B1** Sul on 30 serverit, igaühele tuleb paigaldada nginx ja luua sama konfifail. Kuidas teeksid seda **Bashi** skriptiga? Mis läheb halvasti, kui üks server vahepeal alla kukub või paigaldus jookseb pooleldi läbi?

- **B2** Kuidas Ansible sama ülesannet teisiti lahendab? Mis muutub?

- **B3** Vaata viimase nädala harjutusi (notifikatsioonimoodul, suurimad failid jne). Kas mõni sealne ülesanne sobiks Ansible'i kasutuseks paremini kui skriptiga? Põhjenda.

- **B4** Sõnasta **idempotentsus** ühes lauses oma sõnadega. *(Vihje: mõelge `apt install nginx` peale — mis juhtub teisel käivitamisel skriptiga ja mis Ansible'iga?)*

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

- **C1** Kelle peal see playbook töötab? Kust seda näed?
- **C2** Mis on `vars:` osa funktsioon? Miks ei kirjutatud `nginx` ja avalehe tekst kohe taskidesse?
- **C3** Mida teeb `{{ inventory_hostname }}`? Kui playbook käivitatakse kolme serveri peal (web1, web2, web3), kas avalehed on samad või erinevad?
- **C4** Mis vahe on **task**-il "Restart nginx" ja **handler**-il "Restart nginx"? Millal handler käivitub?
- **C5** Kui käivitad selle playbook'i kaks korda järjest, mis juhtub teisel käivitamisel? Mida väljund näitab?

---

## D osa — avatud reflektsioon

Need küsimused on subjektiivsed — õigeid vastuseid pole. Kirjuta lühike, aus vastus.

- **D1** Mis oli kõige **arusaamatum** koht materjalis? *(Kui kõik oli selge, siis tunnista seda julgelt — aga ole enda vastu aus.)*
- **D2** Mis tundus **üllatav** või huvitav?
- **D3** Kus **sinu enda igapäevatöös** (või tulevases töös IT-administraatorina) võiks Ansible kasulik olla?
- **D4** **Üks küsimus**, mille tahad arutelu ajal teistega või õpetajaga läbi rääkida. *(Pane see kindlasti — see on aluseks meie 12.00 algavale arutlusele.)*

---

## Tulemuse esitamine — Pull Request

Loo fail `tulemused/Eesnimi_P/ansible_reflektsioon.md`, kuhu vastad kõigile A–D osadele. Vasta nii, et iga vastuse ees on number (näiteks `**A1.1**` ja siis vastus).

```bash
git checkout -b harjutus-ansible-lugemine-Eesnimi
git add tulemused/Eesnimi_P/
git commit -m "Lisa Ansible lugemis- ja reflektsiooniharjutus — Eesnimi P"
git push -u origin harjutus-ansible-lugemine-Eesnimi
```

Ava GitHubis **Compare & pull request** ja loo PR pealkirjaga:

```
Ansible reflektsioon — Eesnimi P
```

PR-i kirjelduses pane kohe nähtavale **D4 küsimus**, et ma saaksin enne tundi näha, mis kõiki huvitab.

---

## Hindamine

See töö ei ole "õige/vale" küsimustega test — hinnatakse:

- **Loetavus** — kas olen aru saanud, mida sa kirjutasid?
- **Ausus** — kas tunnistad, mis jäi arusaamatuks?
- **Seosed** — kas oskad ühendada Ansible'it sellega, mida juba tead?

Kõik kolm kriteeriumi täidetud = töö on tehtud.

---

## Lisamaterjal (kui jääb aega)

Kui jõuad enne 12.00 valmis ja tahad rohkem näha:

- [YAML Syntax](https://docs.ansible.com/projects/ansible/latest/reference_appendices/YAMLSyntax.html) — tutvu YAML-i põhitõdedega
- [Ansible Galaxy](https://galaxy.ansible.com) — vaata, milliseid valmis "kollektsioone" inimesed on jaganud (otsi näiteks "nginx" või "docker")
- [Playbook Keywords](https://docs.ansible.com/projects/ansible/latest/reference_appendices/playbooks_keywords.html) — kõikide märksõnade loend, mida playbook'is kasutada saab

---

*Kohtume 12.00 Teamsis. Tule oma D4 küsimusega kohale.*