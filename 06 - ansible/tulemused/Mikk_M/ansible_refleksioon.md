# Ansible refleksioon
## Mikk Maasik KIT-24

### A-osa
**A1.1**  Ansible automatiseerib serverite haldamist, näiteks tarkvara paigaldamist, seadistamist ja teenuste käivitamist. See aitab teha samu tegevusi paljudes masinates korraga.
**A1.2**  Ansible erineb skriptidest selle poolest, et see kirjeldab soovitud lõpptulemust, mitte samme.  
**A2.1**  Control node on masin, kust Ansible käske käivitab. Managed node on sihtmasin, mida hallatakse. Minu arvutis oleks control node minu enda arvuti ja managed node’d oleksid serverid, kuhu SSH-ga ligi pääsen.  
**A2.2**  Esimene käsk oli ``pip install ansible``. See paigaldab Ansible masinasse.  
**A2.3**  Ei nõua eraldi tarkvara sihtmasinas, sest kasutab SSH-d ja käivitab seal Pythonit.  
**A3.1**  Inventory on nimekiri serveritest, mida Ansible haldab. Seal saab määrata ka gruppe ja muutujad.  
**A3.2**  Inventory võib olla näiteks INI-formaadis või YAML-formaadis.  
**A3.3**  Grupid võimaldavad sama konfiguratsiooni rakendada mitmele serverile korraga. Näiteks saab kõikidele veebiserveritele nginx paigaldada ühe käsuga.  
**A4.1**  Playbook’id on kirjutatud YAML-is. See on deklaratiivne ja lihtsam lugeda kui Bashi või Pythonit.  
**A4.2**  Task on üks konkreetne tegevus, näiteks paketi paigaldamine või faili kopeerimine.  
**A4.3**  Hosts määrab, millistele masinatele playbook rakendub.
Become tähendab, et kasutatakse admin õigusi.  
**A5 tabel**  
- Control node — masin, kust Ansible töötab
- Managed node — masin, mida hallatakse
- Inventory — nimekiri sihtmasinatest
- Playbook — YAML fail, mis kirjeldab tegevused
- Play — üks osa playbook’is konkreetsete hostidega
- Task — üks tegevus play sees
- Module — valmis funktsioon (nt apt, copy)
- Handler — task, mis käivitub ainult vajadusel
- Collection — moodulite ja pluginate kogum  
**A5.1**  Module teeb konkreetse töö (nt installib paketi), plugin laiendab Ansible käitumist.  
**A5.2**  Task käivitub alati, handler ainult siis, kui midagi muutus.  

### B-osa
**B1**  Bashiga kirjutaks skripti, mis SSH kaudu igasse serverisse läheb ja käsud käivitab. Probleem on see, et kui üks server kukub ära või install katkeb, siis süsteem jääb poolikusse olekusse.  
**B2**  Ansible teeb sama asja deklaratiivselt ja kontrollib seisundit. Kui midagi on juba tehtud, ei tee ta seda uuesti ja vigadega saab paremini hakkama.  
**B3**  Logide jälgimine koos alertidega sobib Ansible-sse paremini, eriti kui seda on vaja teha mitmes serveris korraga. Ansible sobib paremini olukordadesse, kus on vaja hallata ja standardiseerida süsteemi konfiguratsiooni mitmes masinas, samas kui skriptid on paremad ühekordseks töötluseks või keerukama loogikaga ülesannete lahendamiseks.   
**B4**  Idempotentsus tähendab, et sama käsku saab mitu korda käivitada, kuid süsteemi lõpptulemus jääb alati samaks, ilma kõrvalmõjudeta.  

### C-osa
**C1**  See töötab gruppi “veebid” kuuluvatel serveritel. Seda näeb realt hosts: veebid.  
**C2**  `vars:` hoiab muutujad eraldi, et koodi oleks lihtsam muuta ja lugeda. Sama väärtust saab mitmes kohas kasutada.  
**C3**  ``{{ inventory_hostname }}`` asendatakse serveri nimega.
Seega iga server saab erineva avalehe.  
**C4**  Task “Restart nginx” oleks tavaline tegevus, aga handler käivitub ainult siis, kui notify seda kutsub.
See juhtub siis, kui avaleht muutub.  
**C5**  Teisel käivitamisel midagi ei muudeta, sest kõik on juba õigesti seadistatud. Väljund näitab “ok”, mitte “changed”.Teisel käivitamisel midagi ei muudeta, sest kõik on juba õigesti seadistatud. Väljund näitab “ok”, mitte “changed”.  

### D-osa
**D1**  Hetkel kui seda päriselt pole kasutanud, siis on kogu see süsteem natuke segane.  
**D2**  Et sihtmasinas pole jooksutamiseks vaja agenti.  
**D3**  Kasulik oleks serverite seadistamisel, eriti kui servereid on palju.  
**D4**  Kui suur peab infrastruktuur olema, et Ansible hakkaks päriselt aega säästma?  
