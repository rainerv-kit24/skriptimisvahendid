<#
.SYNOPSIS
    Kontrollib ID-tarkvara uuendusi ja saadab teavituse.

.DESCRIPTION
    Kontrollib Open-EID uusimat versiooni veebist ja votleb seda
    lokaalse versiooniga registris. Vajadusel saadab teavituse.

.PARAMETER KriitilineErinevus
    Mitme peaversiooni erinevuse korral saadetakse Critical (default 2)

.PARAMETER TeataAjakohasusest
    Kui maaratud, saadab teate ka siis kui versioon on OK

.EXAMPLE
    .\kontrolli-id-tarkvara.ps1
#>

[CmdletBinding()]
param(
    [int]$KriitilineErinevus = 2,
    [switch]$TeataAjakohasusest
)

# --- konstandid ---
$SK_URL = "https://installer.id.ee/media/win/"
$MUSTER = 'Open-EID-(\d+\.\d+\.\d+\.\d+)\.exe'

Write-Host "Kontrollin ID-tarkvara versiooni..." -ForegroundColor Cyan

# --- lae moodul ---
$moodul = Join-Path $PSScriptRoot "Saada-Teavitus.psm1"

if (-not (Test-Path $moodul)) {
    Write-Error "Saada-Teavitus.psm1 puudub"
    exit 1
}

Import-Module $moodul -Force

# --- 1. vota uusim versioon veebist ---
try {
    $leht = Invoke-WebRequest -Uri $SK_URL -UseBasicParsing -ErrorAction Stop
}
catch {
    Send-AlertMessage `
        -Message ("ID-tarkvara kontroll ebaonnestus: " + $_.Exception.Message) `
        -Severity Warning `
        -Source "ID-monitor"
    exit 1
}

$versioonid = [regex]::Matches($leht.Content, $MUSTER) |
    ForEach-Object { [Version]$_.Groups[1].Value } |
    Sort-Object -Descending

if (-not $versioonid -or $versioonid.Count -eq 0) {
    throw "Versioone ei leitud - regex voib olla vale"
}

$uusim = $versioonid[0]

# $kohalik = $uusim
# $staatus = "OK"

# --- 2. vota kohalik versioon registrist ---
$uninstallTeed = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$paigaldatud = Get-ItemProperty $uninstallTeed -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -match "Open-EID|Estonian ID|DigiDoc4|DigiDoc3" } |
    Select-Object -First 1

if ($paigaldatud -and $paigaldatud.DisplayVersion) {
    try {
        $kohalik = [Version]$paigaldatud.DisplayVersion
    }
    catch {
        $kohalik = $null
    }
} else {
    $kohalik = $null
}

# --- valjund ---
Write-Host ("  Kohalik versioon:     " + ($kohalik))
Write-Host ("  Uusim saadaval:       " + ($uusim))

# --- 3. staatus ---
if (-not $kohalik) {
    $staatus  = "POLE_PAIGALDATUD"
    $severity = "Warning"
    $sonum    = "Open-EID pole paigaldatud. Uusim: " + $uusim
}
elseif ($kohalik -eq $uusim) {
    $staatus  = "OK"
    $severity = "Info"
    $sonum    = "Open-EID " + $kohalik + " on ajakohane"
}
elseif (($uusim.Major - $kohalik.Major) -ge $KriitilineErinevus) {
    $staatus  = "PALJU_VANEM"
    $severity = "Critical"
    $sonum    = "Open-EID " + $kohalik + " on vaga vana. Uusim: " + $uusim
}
else {
    $staatus  = "AEGUNUD"
    $severity = "Warning"
    $sonum    = "Open-EID uuendus saadaval: " + $kohalik + " -> " + $uusim
}

Write-Host ("  Staatus:              " + $staatus)

# --- 4. teavitus ---
if ($staatus -ne "OK" -or $TeataAjakohasusest) {
    try {
        Send-AlertMessage `
            -Message $sonum `
            -Severity $severity `
            -Source "ID-monitor"

        Write-Host ("[" + $severity + " teavitus saadetud]") -ForegroundColor Yellow
    }
    catch {
        Write-Error ("Teavituse saatmine ebaonnestus: " + $_.Exception.Message)
    }
}