# Iseseisev töö — 4-tunnine pakett

**Kursus:** KIT-24
**Õpetaja:** Toivo Pärnpuu
**Maht:** ~4 akadeemilist tundi
**Esitamine:** Pull Request GitHubi

---

## Reeglid

1. **Teed ülesanded A + vähemalt kaks ülesannet B / C / D hulgast** — kokku vähemalt 3 ülesannet.
2. **Sinu töö sisaldab vähemalt kahte erinevat keelt** (Python, PowerShell, Bash) — ehk sa ei saa teha ainult Pythoni ülesandeid.
3. **Iga ülesanne on oma `.md` fail + skriptifail(id)** sinu `tulemused/Eesnimi_P/` kaustas.
4. **Iga ülesande README selgitab:** kuidas käivitada, mis sõltuvused, millise valiku sa tegid vastuoluliste otsuste juures.
5. **Kõik ühes Pull Request-is** — pealkirjaga `Iseseisev töö — Eesnimi P`.

---

## Ülesanded

### A. Logianalüüsi skript (kohustuslik) · Python

Eelmises harjutuses tegid teavituste mooduli, mis kirjutab logifaili. Nüüd loed seda logi ja koostad raporti: mitu teadet päevas, mis raskusastmed, kuidas muutub trend nädala lõikes. Kirjutad tulemuse CSV-i ja konsooli tabelina.

**Aeg:** ~1 tund · **Juhend:** [`A_logianaluus.md`](A_logianaluus.md)

---

### B. Serverite saadavuse monitor · PowerShell

Loed CSV-st hostide nimekirja, pingid igaüht, koostad raporti. Kui host on maas, võib skript (valikuliselt) saata teavituste mooduli kaudu teate.

**Aeg:** ~1–1.5 tundi · **Juhend:** [`B_serverite_monitor.md`](B_serverite_monitor.md)

---

### C. Kaustade puhastus · Bash

Leiab kaustas failid, mis on vanemad kui X päeva, arhiveerib need `tar.gz`-i ja kustutab originaalid. Skript peab olema turvaline — ei kustuta kogemata kõike.

**Aeg:** ~1–1.5 tundi · **Juhend:** [`C_kaustade_puhastus.md`](C_kaustade_puhastus.md)

---

### D. Süsteemi inventuur · Python

Kogub kokku teavet sinu arvutist: OS, protsessor, mälu, kettaruum, võrgukaardid, paigaldatud Python versioon. Salvestab struktureeritud JSON-i. Ristplatformne (Windows / macOS / Linux).

**Aeg:** ~1–1.5 tundi · **Juhend:** [`D_susteemi_inventuur.md`](D_susteemi_inventuur.md)

---

## Esitamine

Kogu töö läheb ühte Pull Requesti:

```bash
git checkout -b iseseisev-too-Eesnimi
git add tulemused/Eesnimi_P/
git commit -m "Iseseisev töö — Eesnimi P"
git push -u origin iseseisev-too-Eesnimi
```

GitHubis **Compare & pull request**, pealkiri:

```
Iseseisev töö — Eesnimi P
```

**PR kirjeldusse:**

- Millised ülesanded lahendasid (A + vähemalt 2)
- Mis oli kõige raskem — mida sa ei tahtnud esialgu lahendada ja kuidas lõpuks sai
- Kus sa pidid lisaks dokumentatsiooni lugema — link(ad) kaasa
- Millised lisaküsimused (kui tegid) — iga ülesande lõpus on neid

---

## Hindamine

Iga ülesanne hinnatakse skaalal 1–5 nelja punktiga:

- **Töötab** — skript käivitub ja annab oodatud väljundi (1 p)
- **Nõuded täidetud** — kõik juhendis loetletud punktid on kaetud (1 p)
- **Hea tava** — koodis järgitud checklist'is nõutud praktikaid (1 p)
- **Dokumenteeritud** — README selgitab, mis ja miks (1 p)
- **Läbi mõtetud** — veakäsitlus, piirjuhud, loetavus (1 p)

Kohustuslik ülesanne (A) annab baasi, valikulised (B/C/D) kogumi.

---

*Kui jooksed mõne ülesande juures kinni, ava GitHubis Issue. Kui jääd pikalt kinni, vaheta ülesannet — sa ei pea kõike tegema, valikuvabadus on teadlik.*
