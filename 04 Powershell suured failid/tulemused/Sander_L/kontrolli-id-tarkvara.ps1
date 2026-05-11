<#
.SYNOPSIS
    Kontrollib ID-tarkvara uuendusi ja teavitab, kui uus versioon on saadaval.

.DESCRIPTION
    Pärib uusima versiooni installer.id.ee veebilehelt, võrdleb Windowsi
    registris oleva paigaldatud versiooniga ja saadab teate eelmise tunni
    Saada-Teavitus mooduli kaudu, kui uuendus on vajalik.

.PARAMETER KriitilineErinevus
    Mitme peaversiooni erinevuse korral saadetakse Critical, mitte Warning.
    Vaikimisi 2.

.PARAMETER TeataAjakohasusest
    Kui määratud, saadab Info-teate ka siis, kui tarkvara on ajakohane.
    Muidu vaikib.

.EXAMPLE
    .\kontrolli-id-tarkvara.ps1

.EXAMPLE
    .\kontrolli-id-tarkvara.ps1 -TeataAjakohasusest -Verbose
#>

[CmdletBinding()]
param(
    [int]   $KriitilineErinevus  = 2,
    [switch]$TeataAjakohasusest
)

# --- konstandid --------------------------------------------------
$URL = "https://installer.id.ee/media/win/"
$muster = 'Open-EID-(\d+\.\d+\.\d+\.\d+)\.exe'

# --- lae moodul --------------------------------------------------
$moodul = Join-Path $PSScriptRoot "Saada-Teavitus.psm1"
if (-not (Test-Path $moodul)) { throw "Saada-Teavitus.psm1 puudub" }
Import-Module $moodul -Force

Write-Host "Kontrollin ID-tarkvara versiooni..." -ForegroundColor Cyan


# --- 1. uusim versioon SK-st -------------------------------------
try {
    $leht = Invoke-WebRequest -Uri $URL -UseBasicParsing -ErrorAction Stop
}
catch {
    # Võrk maas? Anname teada, aga ei kokku jooksе.
    Send-AlertMessage `
        -Message "ID-tarkvara kontroll: ei õnnestunud päringut teha ($($_.Exception.Message))" `
        -Severity Warning -Source "ID-tarkvara monitor"
    exit 1
}

$versioonid = [regex]::Matches($leht.Content, $MUSTER) |
              ForEach-Object { [Version]$_.Groups[1].Value } |
              Sort-Object -Descending

if (-not $versioonid) { throw "SK lehelt ei leitud ühtegi Open-EID versiooni — kas muster muutus?" }

$uusim = $versioonid[0]
Write-Host "Uusim saadaval: $uusim"

# --- 2. kohalik versioon registrist -----------------------------
$uninstallTeed = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$paigaldatud = Get-ItemProperty $uninstallTeed -ErrorAction SilentlyContinue |
               Where-Object { $_.DisplayName -match "Open-EID|Estonian ID" } |
               Select-Object -First 1

if ($paigaldatud) {
    $kohalik = [Version]$paigaldatud.DisplayVersion
    Write-Host "Kohalik versioon: $kohalik"
} else {
    $kohalik = $null
    Write-Host "Open-EID pole paigaldatud"
}

# --- 3. staatus -------------------------------------------------
if (-not $kohalik) {
    $staatus   = "POLE_PAIGALDATUD"
    $severity  = "Warning"
    $sõnum     = "Open-EID pole paigaldatud. Uusim saadaval: $uusim"
}
elseif ($kohalik -eq $uusim) {
    $staatus   = "OK"
    $severity  = "Info"
    $sõnum     = "Open-EID $kohalik on ajakohane"
}
elseif (($uusim.Major - $kohalik.Major) -ge 2) {
    $staatus   = "PALJU_VANEM"
    $severity  = "Critical"
    $sõnum     = "Open-EID $kohalik on oluliselt vananenud. Uusim: $uusim. Uuenda kiiresti!"
}
else {
    $staatus   = "AEGUNUD"
    $severity  = "Warning"
    $sõnum     = "Open-EID uuendus saadaval: $kohalik → $uusim"
}

Write-Host "Staatus: $staatus"

# --- 4. teavita -------------------------------------------------
# Kas moodul on samas kaustas?
$moodul = Join-Path $PSScriptRoot "Saada-Teavitus.psm1"

if (-not (Test-Path $moodul)) {
    Write-Error "Saada-Teavitus.psm1 pole leitud kaustast $PSScriptRoot"
    exit 1
}

Import-Module $moodul -Force

# Saada ainult siis, kui on tegelikult midagi teatada
if ($staatus -ne "OK") {
    Send-AlertMessage -Message $sõnum -Severity $severity -Source "ID-tarkvara monitor"
}