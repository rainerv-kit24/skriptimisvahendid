# Ansible osa 2: erinevad konfiguratsioonid

**Kursus:** KIT-24
**Õpetaja:** Toivo Pärnpuu
**Eeldus:** Ansible osa 1 on tehtud (Multipassi VM-id, esimene playbook töötab)

---

## Eesmärk

Eelmises harjutuses oli kaks identset serverit. Päriselus on serverid sarnased, aga **mitte ühesugused**. Õpid, kuidas anda erinevatele serveritele erinev konfiguratsioon — ühe playbook'iga.

---

## Tulemus

- `web1` kuvab brauseris **rohelist** lehte tekstiga "Toodang"
- `web2` kuvab **kollast** lehte tekstiga "Staging"
- Mõlemad saadi **ühe** playbook'i käivitamisega

---

## Ettevalmistus

Eeldame, et `web1` ja `web2` käivad ja Ansible saab nendega ühenduda. Kui ei käi, käivita uuesti:

```bash
multipass start web1 web2
ansible veebiserverid -i inventory.ini -m ping
```

---

## 1. samm — pane serverid eri gruppidesse

Muuda `inventory.ini`. Lisame kaks uut gruppi: `toodang` ja `staging`.

```ini
[veebiserverid]
web1 ansible_host=10.93.45.21
web2 ansible_host=10.93.45.22

[toodang]
web1

[staging]
web2

[veebiserverid:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/ansible_key
ansible_python_interpreter=/usr/bin/python3
```

> Asenda IP-aadressid oma omadega.

`web1` on nüüd korraga **kahes** grupis: `veebiserverid` ja `toodang`. Sama kehtib `web2` kohta.

---

## 2. samm — anna gruppidele erinevad muutujad

Loo kaust `group_vars/` ja sinna kaks faili:

**`group_vars/toodang.yml`**:
```yaml
keskkond: Toodang
varv: "#4CAF50"   # roheline
```

**`group_vars/staging.yml`**:
```yaml
keskkond: Staging
varv: "#FFC107"   # kollane
```

See on kõik. Ansible loeb need automaatselt — sa ei pea kuhugi viidet panema.

**Mis juhtub:**
- Kui playbook käivitub `web1` peal, siis `keskkond = "Toodang"` ja `varv = "#4CAF50"`
- Kui playbook käivitub `web2` peal, siis `keskkond = "Staging"` ja `varv = "#FFC107"`

---

## 3. samm — loo template-fail

Loo kaust `templates/` ja sinna fail **`templates/index.html.j2`**:

```jinja
<!DOCTYPE html>
<html>
<head>
  <title>{{ keskkond }} - {{ inventory_hostname }}</title>
</head>
<body style="background: {{ varv }}; font-family: sans-serif; padding: 3em; text-align: center;">
  <h1>{{ keskkond }}</h1>
  <p>Server: <strong>{{ inventory_hostname }}</strong></p>
  <p>IP: {{ ansible_default_ipv4.address }}</p>
</body>
</html>
```

`{{ keskkond }}` ja `{{ varv }}` tulevad `group_vars`'ist. `{{ inventory_hostname }}` on Ansible'i sisseehitatud muutuja.

**Mille poolest erineb template `copy`-st?** `copy` kopeerib faili muutmata. `template` asendab enne `{{ }}` muutujad õigete väärtustega.

---

## 4. samm — kirjuta playbook

Loo fail **`konfiguratsioon.yml`**:

```yaml
---
- name: Seadista veebiserverid keskkonna järgi
  hosts: veebiserverid
  become: yes

  tasks:

    - name: Veendu, et nginx on paigaldatud
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: Genereeri avaleht template'ist
      template:
        src: index.html.j2
        dest: /var/www/html/index.nginx-debian.html

    - name: Veendu, et nginx töötab
      service:
        name: nginx
        state: started
```

Pane tähele: **`hosts: veebiserverid`** — sihime kõiki, mitte ainult ühte gruppi. Eristamine tuleb `group_vars`'ist.

---

## 5. samm — käivita ja vaata

```bash
ansible-playbook -i inventory.ini konfiguratsioon.yml
```

Ava brauseris:
- `http://<web1-IP>` — peaks olema **roheline** "Toodang" leht
- `http://<web2-IP>` — peaks olema **kollane** "Staging" leht

🎉 **Sama playbook, kaks eri tulemust.**

---

## Mida sa õppisid

| Mõiste | Tähendus |
|---|---|
| **Grupid inventory's** | Üks server võib olla mitmes grupis korraga |
| **`group_vars/<grupinimi>.yml`** | Selle grupi serveritele kehtivad muutujad |
| **Template (`.j2`)** | Fail, kus `{{ muutuja }}` asendatakse väärtustega |
| **`template` moodul** | Kopeerib template'i ja täidab muutujad |
| **`{{ inventory_hostname }}`** | Praeguse serveri nimi inventory'st |

**Põhitõde:** ärge kirjuta erinevatele serveritele erinevaid playbook'e. Kirjuta **üks** playbook ja anna **andmed** (muutujad) eraldi.

---

## Lisaküsimused

1. **Lisa kolmas keskkond.** Loo `web3`, pane ta gruppi `arendus`, tee `group_vars/arendus.yml` värviga `#2196F3` (sinine). Kas tuleb mõni rida `konfiguratsioon.yml`-is muuta?

2. **Üks server, eriline säte.** Kui `web1`-l peaks olema teistest erinev tervitustekst (näiteks "Peaserver"), kuhu paneksid selle muutuja? *(Vihje: `host_vars/web1.yml`)*

3. **Tingimuslik task.** Lisa playbook'i task "Ava port 80 firewall'is", mis käivitub **ainult toodangu serveritel**. Uuri märksõna `when:`.

---

## Tulemuse esitamine

Sinu kausta struktuur peaks lõpuks olema:

```
ansible-osa-2/
├── inventory.ini
├── konfiguratsioon.yml
├── group_vars/
│   ├── toodang.yml
│   └── staging.yml
└── templates/
    └── index.html.j2
```

```bash
git checkout -b harjutus-ansible-2-Eesnimi
git add tulemused/Eesnimi_P/
git commit -m "Lisa Ansible osa 2 — erinevad konfiguratsioonid — Eesnimi P"
git push -u origin harjutus-ansible-2-Eesnimi
```

Ava GitHubis **Compare & pull request** ja loo PR pealkirjaga:

```
Ansible osa 2 — Eesnimi P
```
