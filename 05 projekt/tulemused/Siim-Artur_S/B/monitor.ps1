<#
.SYNOPSIS
    Kontrollib CSV-st loetud hostide võrguühendust (ping või TCP).

.PARAMETER SisendCSV
    Sisend-CSV faili tee. Vaikimisi: hostid.csv
    Eeldatavad veerud: Nimi, Host, Port (valikuline)

.PARAMETER VäljundKaust
    Kaust, kuhu tulemus-CSV salvestatakse. Vaikimisi: skripti kaust.

.EXAMPLE
    .\kontrolli-hostid.ps1

.EXAMPLE
    .\kontrolli-hostid.ps1 -SisendCSV serverid.csv -VäljundKaust C:\Raportid
#>
[CmdletBinding()]
param(
    [string]$SisendCSV    = "hostid.csv",
    [string]$VäljundKaust = $PSScriptRoot
)

# --- 1. Sisend-CSV lugemine --------------------------------------
$csvTee = Join-Path $PSScriptRoot $SisendCSV

if (-not (Test-Path $csvTee)) {
    Write-Error "Sisend-CSV ei leitud: $csvTee"
    exit 1
}

$hostid = Import-Csv -Path $csvTee -Encoding UTF8

if (-not $hostid) {
    Write-Warning "CSV on tühi, midagi kontrollida pole."
    exit 0
}

# --- 2. Iga hosti kontrollimine ----------------------------------
Write-Host ""
Write-Host "Kontrollin $($hostid.Count) hosti..." -ForegroundColor Cyan
Write-Host ""

$tulemused = foreach ($rida in $hostid) {
    $nimi      = $rida.nimi
    $host_nimi = $rida.host
    $port      = $rida.port
    $kirjeldus = $rida.kirjeldus

    $õnnestus  = $false
    $latency   = $null
    $viga      = ""

    # Host:Port kuju kuvamiseks
    $hostPort = if ($port) { "$host_nimi`:$port" } else { $host_nimi }

    try {
        if ($port) {
            # TCP kontroll
            $tulemus  = Test-NetConnection -ComputerName $host_nimi -Port $port -WarningAction SilentlyContinue
            $õnnestus = $tulemus.TcpTestSucceeded
            if ($õnnestus) {
                $stopper = [System.Diagnostics.Stopwatch]::StartNew()
                $null    = Test-NetConnection -ComputerName $host_nimi -Port $port -WarningAction SilentlyContinue
                $stopper.Stop()
                $latency = $stopper.ElapsedMilliseconds
            }
        } else {
            # ICMP ping
            $tulemus  = Test-Connection -ComputerName $host_nimi -Count 1 -ErrorAction Stop
            $õnnestus = $true
            $latency  = $tulemus.ResponseTime
        }
    } catch {
        $õnnestus = $false
        $viga     = $_.Exception.Message
    }

    [PSCustomObject]@{
        Nimi       = $nimi
        Host       = $host_nimi
        HostPort   = $hostPort
        Port       = if ($port) { $port } else { "-" }
        Kirjeldus  = $kirjeldus
        Staatus    = if ($õnnestus) { "OK" } else { "FAIL" }
        Latency_ms = if ($null -ne $latency) { $latency } else { "-" }
        Viga       = $viga
        Kontrollitud = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    }
}

# --- 3. Konsooli väljund -----------------------------------------
$nimeLaius  = ($tulemused | ForEach-Object { $_.Nimi.Length }     | Measure-Object -Maximum).Maximum
$hostLaius  = ($tulemused | ForEach-Object { $_.HostPort.Length } | Measure-Object -Maximum).Maximum

foreach ($r in $tulemused) {
    $nimi     = $r.Nimi.PadRight($nimeLaius)
    $hostPort = $r.HostPort.PadRight($hostLaius)
    $latency  = if ($r.Latency_ms -ne "-") { "$($r.Latency_ms) ms".PadLeft(6) } else { "-".PadLeft(6) }

    Write-Host "  $nimi  $hostPort  " -NoNewline
    if ($r.Staatus -eq "OK") {
        Write-Host "OK  " -ForegroundColor Green -NoNewline
    } else {
        Write-Host "FAIL" -ForegroundColor Red -NoNewline
    }
    Write-Host "  $latency"
}

# --- 4. Kokkuvõte ------------------------------------------------
$kokku       = $tulemused.Count
$õnnestus    = ($tulemused | Where-Object Staatus -eq "OK").Count
$ebaõnnestus = $kokku - $õnnestus
$kuupäev     = Get-Date -Format "yyyy-MM-dd"
$väljundFail = Join-Path $VäljundKaust "saadavus_$kuupäev.csv"

Write-Host ""
Write-Host -NoNewline "Kokkuvõte: "
Write-Host -NoNewline "$õnnestus / $kokku OK" -ForegroundColor Green
Write-Host -NoNewline ", "
if ($ebaõnnestus -gt 0) {
    Write-Host "$ebaõnnestus maas" -ForegroundColor Red
} else {
    Write-Host "kõik OK" -ForegroundColor Green
}

# --- 5. CSV salvestamine -----------------------------------------
$tulemused | Select-Object Nimi, Host, Port, Kirjeldus, Staatus, Latency_ms, Viga, Kontrollitud | Export-Csv -Path $väljundFail -NoTypeInformation -Encoding UTF8
Write-Host "Tulemus salvestatud: saadavus_$kuupäev.csv" -ForegroundColor DarkGray
Write-Host ""