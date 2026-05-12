# Ansible reflektsioon
## Juri Pavlov KIT-24

### A osa

**A1.1**
Ansible automatiseerib serverite haldamist ja seadistamist. Näiteks tarkvara paigaldamist, konfiguratsiooni muutmist ja teenuste käivitamist.

**A1.2**
Peamine erinevus on see, et Ansible kirjeldab soovitud tulemust, mitte samme. Skript (Bash/Python) täidab käske järjest, aga Ansible kontrollib, kas asi on juba tehtud, ja ei tee midagi üleliigset.

**A2.1**
Control node on arvuti, kust Ansible käske käivitatakse. 
Managed node on server, mida hallatakse. Minu arvutis võib control node olla minu PC ja managed node näiteks virtuaalmasinad.

**A2.2**
Esimesed käsud olid 
``pip install ansible``
``ansible-inventory -i inventory.ini --list; ``
``ansible myhosts -m ping -i inventory.ini. ``

See kontrollib, kas Ansible saab ühenduse serveritega.

**A2.3**
Ei nõua eraldi tarkvara installimist sihtmasinas. Piisab SSH-st ja Pythonist, mis on juba enamikus Linuxites olemas.

**A3.1**
Inventory on fail, kus on kirjas kõik serverid, mida Ansible haldab. Seal saab määrata ka gruppe.

**A3.2**
Inventory võib olla näiteks INI-formaadis või YAML-formaadis.

**A3.3**
Grupid aitavad hallata servereid. Näiteks saab paigaldada nginx ainult [veebiserverid] grupile, mitte andmebaasidele.

**A4.1**
Playbook’id on kirjutatud YAML-formaadis. See erineb Pythonist või Bashist, sest see on lihtsam lugeda.

**A4.2**
Task on konkreetne tegevus, näiteks paketi paigaldamine või faili kopeerimine.

**A4.3**
hosts näitab, millistel serveritel playbook töötab. become tähendab, et käsud käivitatakse root õigustes.

**Table**
| Mõiste        | Mida see tähendab? |
|--------------|--------------------|
|Control node | on masin, kust Ansible töötab.|
|Managed node | on masin, mida hallatakse.|
|Inventory | on serverite nimikiri sihtmasinatest.|
|Playbook | on YAML fail automatiseerimiseks.|
|Play | on üks osa playbook’is, mis rakendub hostidele.|
|Tast |on konkreetne tegevus.|
|Module |on valmistatud funktsioon.|
|Handler |on tast, mis käivitub ainult vajadusel.|
|Collection |on moodulite ja pluginate kogum.|

**A5.1**
Module teeb konkreetse töö (nt installib paketi), plugin lisab Ansible’ile lisafunktsionaalsust.

**A5.2**
Task käivitub alati, handler ainult siis, kui midagi muutus.

---

### B osa

**B1**
Bash skriptiga kirjutan skripti, mis ühendub igasse serverisse ja paigaldab nginx’i. Probleem on see, et kui üks server kukub maha, siis skript võib katkeda või jääda poolikuks.

**B2**
Ansible teeb sama asja korraga ja kontrollib iga serveri seisundit. Kui midagi ebaõnnestub, näitab täpselt kus ja miks.

**B3**
Näiteks notifikatsioonide või logianalüüsi ülesanded sobiksid Ansible’iga, kui neid tuleb teha mitmes serveris korraga.

**B4**
Idempotentsus tähendab, et sama käsk annab sama tulemuse ka mitmekordsel käivitamisel ilma lisamuutusteta.

---

### C osa

**C1**
See playbook töötab grupil "veebid". Seda näeb realt hosts: veebid.

**C2**
``vars:`` osa hoiab muutujaid, mida saab kasutada taskides. See teeb playbook’i paindlikumaks ja lihtsamini muudetavaks.

**C3**
``{{ inventory_hostname }}`` tähendab serveri nime. Kui on web1, web2, web3, siis igaühel on erinev tekst avalehel.

**C4**
Task ``"Restart nginx"`` oleks tavaline käsk, aga handler käivitub ainult siis, kui midagi muutus (nt fail muutus).

**C5**
Teisel käivitamisel midagi ei muutu. Ansible näitab, et kõik on juba korras (ok), mitte changed.

---

### D osa

**D1**
Praktilises suhtes mul ilmub mingi segadus, kuidas see kõik toimib, sest pole kudagi olnud ansible kasutanud.

**D2**
Üllatav oli see, et Ansible ei vaja agenti serverites.

**D3**
Ansible oleks kasulik serverite seadistamisel, eriti kui on palju masinaid (nt web serverid).

**D4**
Kuidas hoitakse Ansible’is turvaliselt paroole ja tundlikke andmeid?

---