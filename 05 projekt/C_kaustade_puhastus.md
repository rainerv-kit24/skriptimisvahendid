# Ülesanne C — Kaustade puhastus

**Kursus:** KIT-24
**Keel:** Bash
**Tööriistad:** `find`, `tar`, `du`, `test`, käsurea argumendid
**Raskusaste:** ★★★ (raskemat laadi — turvalisus) · **Aeg:** ~1–1.5 tundi

---

## Eesmärk

Kirjuta Bashi skript, mis leiab kaustas vanu faile, arhiveerib nad `tar.gz`-i ja seejärel kustutab originaalid. See on päriselu admin­ülesanne: server hakkab ketta täis saama, `/tmp` ja vanade logide puhastus on rutiin.

**Tähelepanu: see skript kustutab faile.** Vigane skript võib kustutada, mida ei tohi. Üks osa ülesandest ongi õppida, **kuidas turvaliselt** kirjutada.

---

## Tulemus

Skripti käivitus:

```bash
./puhasta.sh /tmp/test-kaust 7
```

Tähendus: "puhasta kaustast `/tmp/test-kaust` kõik failid, mis on vanemad kui 7 päeva".

Väljund:

```
Puhastus: /tmp/test-kaust
Vanusepiir: 7 päeva
Leidsin 23 faili (86 MB).
Arhiveerin: arhiiv_2026-04-21_101502.tar.gz
Arhiiv loodud (24 MB).
Kustutan 23 faili...
Valmis! Vabanes 86 MB.
```

Kui asjad lähevad valesti (näiteks ketas täis, õigused puuduvad), skript ei jätka kustutamisega — arhiiv on turvavõrk.

---

## Nõuded

- **Kaks argumenti:** kaust ja päevade arv
- **Kontrollid enne:**
  - kas kaust on olemas
  - kas päevade arv on positiivne täisarv
  - kas kaust pole ohtlik (mitte `/`, `/home`, `$HOME`, `/usr` jne — mõtle, mis loend sobib)
- **`--dry-run` lipuga** skript näitab, mida teeks, aga ei tee midagi
- **Arhiveerimine enne kustutamist** — kui arhiivi loomine ebaõnnestub, skript **ei kustuta midagi**
- **Arhiivi nimi** sisaldab ajatemplit (kuupäev + kellaaeg)
- **Kõrvaldab vaid failid**, mitte kaustu (lõpus kaustad jäävad alles)
- **Korrektne väljumisstaatus** — edu = 0, viga = mittenull

---

## Hea tava — checklist

- [ ] **`set -euo pipefail`** skripti alguses (selgitus sammus 1)
- [ ] **Tsiteeritud muutujad** — `"$kaust"` mitte `$kaust` (mis juhtub, kui nimes on tühik?)
- [ ] **Input valideerimine** — kaks argumenti olemas, kaust olemas, vanus number
- [ ] **Mustade nimekiri** — ei puhasta `/`, `/home` jne
- [ ] **`--dry-run` tugi** — saab testida ilma midagi tegemata
- [ ] **`--help` tugi** — skript seletab ise oma kasutamist
- [ ] **Edukusstaatused** — `exit 0` eduga, `exit 1`/`2` erinevate vigade puhul
- [ ] **Informatiivne väljund** — kasutaja näeb, mis toimub
- [ ] **Kommentaarid funktsioonide kohal** — mida teeb, mis sisend, mis väljund

---

## Test-andmete loomine

Enne skripti katsetamist tee endale ohutu test-kaust:

```bash
mkdir -p /tmp/test-puhastus
cd /tmp/test-puhastus

# Loo 5 "vana" faili (muutmise aeg 10 päeva tagasi)
for i in 1 2 3 4 5; do
    echo "Vana fail $i sisu" > "vana_$i.log"
    touch -d "10 days ago" "vana_$i.log"
done

# Loo 3 värsket faili
for i in 1 2 3; do
    echo "Värske fail $i" > "varske_$i.txt"
done

ls -la
```

`touch -d "10 days ago"` muudab faili ajatemplit. Nii saad kohe testida — peaks leidma 5 faili, 3 jätma.

---

## Samm-sammult

---

### Samm 1 — turvaline skripti algus

<details>
<summary>Vihje — `set -euo pipefail`</summary>

```bash
#!/bin/bash
set -euo pipefail
```

- `set -e` — skript katkeb kohe, kui mõni käsk läheb viga. Ilma selleta jookseks skript edasi ka pärast viga (ohtlik, kui arhiveerimine ebaõnnestub, aga kustutus jätkub).
- `set -u` — kasutamata muutuja andmine on viga. Tõkestab typo-vead (`$kausst` asemel `$kaust`).
- `set -o pipefail` — torustikus (`cmd1 | cmd2`) kui esimene käsk läheb viga, kogu torustik loetakse vigaseks.

Need kolm rida eraldavad "amatöör­skriptid" "admin­skriptidest".

</details>

---

### Samm 2 — argumentide parsing ja valideerimine

**Mida vajad:** `$1`, `$2`, `[[ ... ]]` tingimused, `case`.

<details>
<summary>Vihje</summary>

```bash
kasuta() {
    cat <<EOF
Kasutamine: $0 <kaust> <päevi> [--dry-run]

  <kaust>     Kaust, mida puhastada
  <päevi>     Faile vanemaid kui see päevade arv arhiveerida ja kustutada
  --dry-run   Näita mida teeks, aga ära muuda midagi
  --help      Näita seda abi

Näide: $0 /tmp/test 7
       $0 /tmp/test 7 --dry-run
EOF
}

# --- parsi argumendid ---
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)    kasuta; exit 0 ;;
        --dry-run)    DRY_RUN=true; shift ;;
        *)            break ;;
    esac
done

if [[ $# -ne 2 ]]; then
    echo "Viga: peab olema täpselt kaks positsioonilist argumenti." >&2
    kasuta
    exit 2
fi

KAUST="$1"
PÄEVI="$2"

# --- valideeri ---
if [[ ! -d "$KAUST" ]]; then
    echo "Viga: kaust '$KAUST' ei ole olemas." >&2
    exit 2
fi

if ! [[ "$PÄEVI" =~ ^[0-9]+$ ]] || [[ "$PÄEVI" -lt 1 ]]; then
    echo "Viga: päevade arv peab olema positiivne täisarv." >&2
    exit 2
fi
```

**Miks `>&2`?** See saadab veateate `stderr`-ile, mitte `stdout`-ile. Päriselt töötavas skriptis saab `stdout` minna torustikku, `stderr` ekraanile. Hea tava.

</details>

---

### Samm 3 — mustade nimekiri (OHUTUS)

Sa ei taha, et keegi kirjutaks `./puhasta.sh / 0` ja hävitaks süsteemi. Mõned teed on alati liiga ohtlikud.

<details>
<summary>Vihje</summary>

```bash
# Normaliseeri tee (eemalda lõpu "/")
KAUST="${KAUST%/}"
KAUST_REAL="$(realpath "$KAUST")"

# Keeldutud teed
KEELATUD=("/" "/home" "/root" "/usr" "/etc" "/var" "/bin" "/sbin" "/boot" "/opt" "$HOME")

for k in "${KEELATUD[@]}"; do
    if [[ "$KAUST_REAL" == "$k" ]]; then
        echo "Viga: kaust '$KAUST_REAL' on kaitstud." >&2
        exit 3
    fi
done
```

`realpath` lahendab sümbol­lingid ja suhtelise tee — nii et `./../../../..` ei tähenda trikitamist.

**Mõtle ise läbi:** kas sa tahad ka kontrolli, et kaust ei ole *liiga kõrge tasandi* (nt `/tmp` on OK, aga mitte midagi selle kohal)? See on disaini­otsus — dokumenteeri oma valik README-s.

</details>

---

### Samm 4 — leia vanad failid

<details>
<summary>Vihje — `find` käsk</summary>

```bash
# Leia failid, mis on vanemad kui $PÄEVI päeva, ainult failid (-type f)
# Kasuta -print0 ja null-baite, et nimed tühikute/erisümbolitega töötaks
FAILE=$(find "$KAUST" -type f -mtime +$PÄEVI | wc -l)

if [[ $FAILE -eq 0 ]]; then
    echo "Ei leidnud vastavaid faile. Pole midagi teha."
    exit 0
fi

SUURUS=$(find "$KAUST" -type f -mtime +$PÄEVI -print0 | \
         xargs -0 du -bc 2>/dev/null | tail -1 | awk '{print $1}')
SUURUS_MB=$((SUURUS / 1024 / 1024))

echo "Puhastus: $KAUST"
echo "Vanusepiir: $PÄEVI päeva"
echo "Leidsin $FAILE faili ($SUURUS_MB MB)."
```

`-mtime +7` — muutmise aeg üle 7 päeva tagasi. `-mtime -7` — viimase 7 päeva jooksul.

**NB:** `find ... | wc -l` ei tööta õigesti, kui failinimes on reavahetus. Produktsioonis kasutataks `find ... -print0 | tr -cd '\0' | wc -c`. See ülesanne lubab lihtsama variandi, aga maini seda README-s.

</details>

---

### Samm 5 — arhiveeri ja kustuta (enne dry-run kontroll!)

<details>
<summary>Vihje</summary>

```bash
ARHIIV="arhiiv_$(date +%Y-%m-%d_%H%M%S).tar.gz"

if $DRY_RUN; then
    echo "DRY RUN — järgmist teeksin:"
    echo "  1. Arhiveeriks $FAILE faili → $ARHIIV"
    echo "  2. Kustutaks originaalid"
    find "$KAUST" -type f -mtime +$PÄEVI -print | head -10
    [[ $FAILE -gt 10 ]] && echo "  ... ja veel $((FAILE - 10)) faili"
    exit 0
fi

# --- päris arhiveerimine ---
echo "Arhiveerin: $ARHIIV"

# -print0 + --null et nimed tühikutega töötaks
if ! find "$KAUST" -type f -mtime +$PÄEVI -print0 | \
     tar --null -czf "$ARHIIV" -T -; then
    echo "Viga: arhiveerimine ebaõnnestus. Ei kustuta midagi." >&2
    exit 4
fi

ARHIIVI_SUURUS=$(du -h "$ARHIIV" | awk '{print $1}')
echo "Arhiiv loodud ($ARHIIVI_SUURUS)."

# --- kustutus ---
echo "Kustutan $FAILE faili..."
find "$KAUST" -type f -mtime +$PÄEVI -delete

echo "Valmis! Vabanes $SUURUS_MB MB."
```

**Loogika võti:** kustutus **on eraldi käsk peale** arhiveerimise õnnestumist. `set -e` garanteerib, et kui `tar` läheb viga, skript katkeb enne `-delete`-i. See on kaitse­võrk.

</details>

---

## Mida sa õppisid

| Mõiste | Tähendus |
|---|---|
| `set -euo pipefail` | Turvaline skripti algus |
| `[[ ... ]]` | Tingimus (bash-laiendiga, `[ ... ]`-st parem) |
| `>&2` | Suuna väljund stderr-ile |
| `find -mtime +N` | Muutmise aeg üle N päeva tagasi |
| `find -print0` + `xargs -0` | Turvaline nimede käsitlus (tühikud, reavahetused) |
| `tar -czf ... -T -` | Tar loeb failide nimekirja stdin-ist |
| `realpath` | Tegelik absoluutne tee (lahendab lingid) |
| `[[ $x =~ ^[0-9]+$ ]]` | Regex-kontroll |
| `cat <<EOF` | Mitmerealine string |
| `exit <kood>` | Väljumisstaatus (0 = edu, mitte-null = viga) |

---

## Lisaküsimused (valikuline)

1. **Logimine failis.** Lisa skripti, et iga jooks kirjutaks ühe rea `~/puhastus.log`-i: kuupäev, kaust, mitu faili, mitu MB. Nii näed ajalugu hiljem.
2. **Arhiivi säilitamine.** Praegu arhiiv jääb ürgselt kuhugi. Lisa `--arhiivi-kaust <tee>` argument, kuhu see liigub. Loo kaust kui pole.
3. **Laiendi filter.** Puhasta ainult teatud laiendiga faile (`*.log`, `*.tmp`). Lisa `--laiend <muster>` argument.
4. **Vanim arhiiv.** Kui sama skript on jooksnud 30 päeva, sul on 30 arhiivi. Kuidas kustutada arhiive, mis on vanemad kui 6 kuud? Vihje: `find $ARHIIVIKAUST -name "arhiiv_*.tar.gz" -mtime +180 -delete`.

---

## Esitamine

```
tulemused/Eesnimi_P/
├── puhasta.sh                  <- peab olema käivitatav (chmod +x)
├── test-andmed-setup.sh        <- skript test-kausta loomiseks
└── README.md
```

`README.md`-s kirjelda:

- **Turvalisuse otsused:** miks valisid need keelatud teed, mitte teised?
- **Dry-run tähtsus:** kuidas sa seda testisid?
- **Puudused:** mida sa ei jõudnud teha või mida teeksid teistmoodi?
