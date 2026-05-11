# Ülesanne B — Serverite saadavuse monitor

**Kursus:** KIT-24
**Keel:** PowerShell
**Moodul:** `Test-Connection`, `Test-NetConnection`, `Import-Csv`, `Export-Csv`
**Raskusaste:** ★★☆ (keskmine) · **Aeg:** ~1–1.5 tundi

---

## Eesmärk

Kirjuta skript, mis võtab nimekirja serveritest/hostidest ja kontrollib, kas nad on kättesaadavad. Salvesta tulemus CSV-i. Kui mõni host on maas ja sul on eelmise tunni teavituste moodul olemas, saada teate (valikuline — ei kohustuslik punkt).

---

## Sisend

Loo fail `hostid.csv` oma kaustas:

```csv
nimi,host,port,kirjeldus
google,google.com,443,Avalik võrgutest
github,github.com,443,Git push
oma-ruuter,192.168.1.1,80,Koduvõrgu gateway
olematu,ei-ole-olemas.invalid,443,Peab maas olema (test)
localhost-ssh,127.0.0.1,22,Lokaalne SSH
```

Kaks esimest peavad töötama. Kaks viimast võivad olla olematud — neid testitakse, et sa näeksid, kuidas `FAIL` voogu käsitletakse.

---

## Tulemus

Skripti käivitus:

```powershell
.\kontrolli-hostid.ps1
```

Konsoolis:

```
Kontrollin 5 hosti...

  google          google.com                OK    23 ms
  github          github.com                OK    31 ms
  oma-ruuter      192.168.1.1               OK     2 ms
  olematu         ei-ole-olemas.invalid     FAIL  -
  localhost-ssh   127.0.0.1:22              OK     1 ms

Kokkuvõte: 4 / 5 OK, 1 maas
Tulemus salvestatud: saadavus_2026-04-21.csv
```

CSV-fail `saadavus_<kuupäev>.csv`:

```
Nimi,Host,Port,Olek,Viivitus_ms,Kontrollitud,Kirjeldus
google,google.com,443,OK,23,2026-04-21 10:15:02,Avalik võrgutest
...
```

---

## Nõuded

- Sisend-CSV on parameetriseeritav (vaikimisi `hostid.csv`)
- Iga host kontrollitakse — kui `port` on määratud, kasutatakse `Test-NetConnection` (TCP), muidu `Test-Connection` (ICMP ping)
- Skript ei jookse kokku ühe hosti veast — teised saavad ikka kontrollitud
- Viivitus (`Latency`) salvestatakse millisekundites, kui teadaolev
- CSV nimi sisaldab kuupäeva (et saaks mitu jooksu hoida)
- Jätab konsoolile mõistliku kokkuvõtte

---

## Hea tava — checklist

- [ ] **`[CmdletBinding()]`** ja `param()` blokk
- [ ] **Parameetrid** — sisend ja väljund on ümberseadistatavad
- [ ] **`try/catch`** iga hosti kontrolli ümber — üks katki ei peata teisi
- [ ] **Kommentaaripõhine abi** (`.SYNOPSIS` jne)
- [ ] **Verb-Noun funktsioonid** — nt `Test-HostStatus`, mitte `kontrolli`
- [ ] **Kokkuvõtva statistika** — mitu OK, mitu FAIL
- [ ] **Valikuline: teavitus** — kui moodul olemas, saadab Warning, kui ≥1 host maas

---

## Samm-sammult

---

### Samm 1 — loe hostide CSV

<details>
<summary>Vihje</summary>

```powershell
$hostid = Import-Csv -Path "hostid.csv"

$hostid | Format-Table nimi, host, port -AutoSize
```

`Import-Csv` teeb igast reast PSCustomObject'i, mille veergude nimed vastavad CSV päisele. Saab kohe kasutada `$_.host`, `$_.port` jne.

</details>

---

### Samm 2 — ühe hosti test

Kui `port` on määratud — TCP-ühendus. Kui pole — ICMP ping.

**Mida vajad:** `Test-NetConnection -ComputerName $x -Port $y`, `Test-Connection -ComputerName $x -Count 1`.

<details>
<summary>Vihje</summary>

```powershell
function Test-HostStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Host,
        [int]$Port = 0
    )

    try {
        if ($Port -gt 0) {
            # TCP — kontrollib kindlalt porti
            $r = Test-NetConnection -ComputerName $Host -Port $Port `
                                    -WarningAction SilentlyContinue -ErrorAction Stop
            return [PSCustomObject]@{
                Olek        = if ($r.TcpTestSucceeded) { "OK" } else { "FAIL" }
                Viivitus_ms = $r.PingReplyDetails.RoundtripTime
            }
        }
        else {
            # ICMP — tavaline ping
            $r = Test-Connection -ComputerName $Host -Count 1 -Quiet -ErrorAction Stop
            $v = (Test-Connection -ComputerName $Host -Count 1 -ErrorAction Stop).ResponseTime
            return [PSCustomObject]@{
                Olek        = if ($r) { "OK" } else { "FAIL" }
                Viivitus_ms = $v
            }
        }
    }
    catch {
        return [PSCustomObject]@{
            Olek        = "FAIL"
            Viivitus_ms = $null
        }
    }
}
```

**NB:** `Test-NetConnection` loeb samamoodi `WARNING`-id kui tavalised õigsus­tulemused. `-WarningAction SilentlyContinue` peidab need, muidu logi täitub.

</details>

---

### Samm 3 — tsükkel üle kõigi

<details>
<summary>Vihje</summary>

```powershell
$tulemus = foreach ($h in $hostid) {
    $port = if ($h.port) { [int]$h.port } else { 0 }
    $test = Test-HostStatus -Host $h.host -Port $port

    [PSCustomObject]@{
        Nimi          = $h.nimi
        Host          = $h.host
        Port          = $h.port
        Olek          = $test.Olek
        Viivitus_ms   = $test.Viivitus_ms
        Kontrollitud  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        Kirjeldus     = $h.kirjeldus
    }

    # Kuva progress
    $värv = if ($test.Olek -eq "OK") { "Green" } else { "Red" }
    Write-Host ("  {0,-15} {1,-25} {2,-5} {3} ms" -f `
        $h.nimi, $h.host, $test.Olek, $test.Viivitus_ms) `
        -ForegroundColor $värv
}
```

`{0,-15}` formaadi­string tähendab "vasakule joonda 15 tähekohta". Nii tabel konsoolis on ühtlane.

</details>

---

### Samm 4 — salvesta CSV ja prindi kokkuvõte

<details>
<summary>Vihje</summary>

```powershell
$kuupäev = Get-Date -Format "yyyy-MM-dd"
$failinimi = "saadavus_$kuupäev.csv"

$tulemus | Export-Csv -Path $failinimi -NoTypeInformation -Encoding UTF8

$ok   = ($tulemus | Where-Object Olek -eq "OK").Count
$fail = ($tulemus | Where-Object Olek -eq "FAIL").Count

Write-Host ""
Write-Host "Kokkuvõte: $ok / $($tulemus.Count) OK, $fail maas" -ForegroundColor Cyan
Write-Host "Tulemus salvestatud: $failinimi" -ForegroundColor Cyan
```

</details>

---

### Samm 5 (valikuline) — teavitus kui host maas

Kui sul on eelmise harjutuse `Saada-Teavitus.psm1` olemas, kasuta seda. Kui pole — jäta see samm vahele (ei mõjuta hinnet).

<details>
<summary>Vihje</summary>

```powershell
$moodul = Join-Path $PSScriptRoot "Saada-Teavitus.psm1"

if ((Test-Path $moodul) -and $fail -gt 0) {
    Import-Module $moodul -Force
    $maas = ($tulemus | Where-Object Olek -eq "FAIL" | Select-Object -Expand Nimi) -join ", "
    Send-AlertMessage -Message "Hosti(d) maas: $maas" -Severity Warning -Source "Saadavuse monitor"
}
```

`-join ", "` teeb listist ühe stringi — "google, github" mitte kaks eraldi teadet.

</details>

---

## Mida sa õppisid

| Käsk | Tähendus |
|---|---|
| `Test-Connection -Count 1 -Quiet` | ICMP ping, tagastab `$true`/`$false` |
| `Test-NetConnection -Port` | TCP-ühenduse kontroll konkreetsele pordile |
| `Import-Csv` | CSV → PSCustomObject kogu |
| `Export-Csv -NoTypeInformation` | Kogu → CSV ilma tüübireata |
| `Where-Object` | Filter (nt `Where-Object Olek -eq "OK"`) |
| `-join ", "` | Listist string |
| `-f` formaadistring | Väljundi joondamine tabelites |
| `Write-Host -ForegroundColor` | Värviline konsooliväljund |

---

## Lisaküsimused (valikuline)

1. **Paralleelne kontroll.** 100 hosti järjest võtab aega. Kuidas kontrollida neid paralleelselt? Uuri `ForEach-Object -Parallel` (PS 7+) või `Start-Job`-e.
2. **Ajalugu ühes failis.** Praegu tekib iga päev uus CSV. Tee ka üks kumulatiivne `saadavus_ajalugu.csv`, kuhu igal käivitusel loeb uued read juurde.
3. **Statistika ajaloo põhjal.** Loe ajalugu sisse ja kuva, milline host on kõige rohkem maas olnud viimasel nädalal.
4. **DNS-i kontroll eraldi.** Lisa veel veerg "DNS_resolve_ms" — kui kaua DNS-päring võttis. Uuri `Resolve-DnsName`.

---

## Esitamine

```
tulemused/Eesnimi_P/
├── kontrolli-hostid.ps1
├── hostid.csv                    <- näidis­sisend
├── saadavus_2026-04-21.csv       <- näidis­väljund
└── README.md
```
