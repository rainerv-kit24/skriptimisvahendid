# PowerShell suured failid harjutus — Mark L.

**Kursus:** KIT-24
**Õpetaja:** Toivo Pärnpuu
**Keel:** PowerShell

## Mida see kaust sisaldab

| Fail | Kirjeldus |
|---|---|
| `suurimad_failid.ps1` | PowerShell skript, mis leiab 10 kõige suuremat faili. |
| `suurimad_failid.csv` | Skripti väljund — top 10 koos teega, suuruse ja muutmise kuupäevaga. |
| `readme.md` | See fail. |

## Kuidas käivitada

```powershell
cd "04 Powershell suured failid\tulemused\Mark_L"

# Vaikimisi: otsi kasutaja kodukaustast, AppData välja jäetud
.\suurimad_failid.ps1

# Otsi konkreetsest kaustast
.\suurimad_failid.ps1 -Otsingukaust C:\Users\Mark\Downloads

# Kaasa ka AppData (mis vaikimisi välja jääb)
.\suurimad_failid.ps1 -LisaAppData
```

CSV salvestatakse alati skripti kõrvale (`suurimad_failid.csv`), olenemata sellest, kust skript käivitati. Selleks kasutab skript `$MyInvocation.MyCommand.Path`-i.

### Kui PowerShell ei luba skripti käivitada

Kui näed viga "running scripts is disabled on this system", luba käivitamine üks kord administraatori PowerShellis:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## Mida skript teeb (samm-sammult)

1. **Loeb käsurea argumendid** — `param()` plokk. Vaikimisi otsingukoht on `$HOME`, vabatahtlik lipp `-LisaAppData` lülitab AppData filtri välja.
2. **Otsib rekursiivselt** kõik failid `Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue` käsuga (vahele jätab kaustad ja failid millele puudub ligipääs).
3. **Filtreerib AppData välja** `Where-Object { $_.FullName -notmatch "\\AppData\\" }` abil, kui `-LisaAppData` lippu pole antud.
4. **Sorteerib** suuruse järgi kahanevalt: `Sort-Object -Property Length -Descending`.
5. **Võtab esimesed 10**: `Select-Object -First 10`.
6. **Vormindab suuruse** loetavasse ühikusse (GB / MB / KB) abifunktsiooniga `Convert-Suurus` — kasutab PowerShelli sisseehitatud konstante `1GB`, `1MB`, `1KB`.
7. **Lisab muutmise kuupäeva** `$fail.LastWriteTime.ToString("yyyy-MM-dd")` abil.
8. **Loob `[PSCustomObject]`** iga faili kohta veergudega `Tee, Nimi, Suurus, Muudetud`.
9. **Kirjutab CSV** `Export-Csv -NoTypeInformation -Encoding UTF8`-ga.

## Lahendatud lisaülesanded

| Lisaülesanne | Kus koodis |
|---|---|
| AppData välistamine | `Where-Object { $_.FullName -notmatch "\\AppData\\" }` |
| Muudetud kuupäev | `$fail.LastWriteTime.ToString("yyyy-MM-dd")` |
| Käsurea argument | `param([string]$Otsingukaust = $HOME, [switch]$LisaAppData)` |

## Õpitud PowerShelli vahendid

| Vahend | Kasutus |
|---|---|
| `Get-ChildItem -Recurse -File` | rekursiivne faililoend (ainult failid) |
| `-ErrorAction SilentlyContinue` | jäta vahele kaustad ilma õigusteta |
| `Sort-Object -Property Length -Descending` | sorteerimine baitide järgi kahanevalt |
| `Select-Object -First 10` | võta esimesed 10 |
| `Where-Object { ... }` | filtreerimine tingimuse alusel |
| `[PSCustomObject]@{...}` | kohandatud objekti loomine |
| `Export-Csv -NoTypeInformation -Encoding UTF8` | objektide salvestamine CSV-sse |
| `1GB`, `1MB`, `1KB` | sisseehitatud baidikonstandid |
| `"{0:N1}" -f $arv` | arvu vormindamine ühe kümnendkohaga |
| `param()` | käsurea argumentide deklareerimine |
| `[switch]` | tõene/väär lipp (true/false flag) |
| `$MyInvocation.MyCommand.Path` | skripti enda asukoht |
| `$HOME` | kasutaja kodukaust |
| `Split-Path -Parent` | võta tee vanemkaust |
| `Join-Path` | ühenda kaks teed |
