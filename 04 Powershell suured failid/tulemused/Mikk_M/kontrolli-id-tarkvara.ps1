<# 
.SYNOPSIS
Kontrollib ID-tarkvara (Open-EID) versiooni ja võrdleb seda uusima saadaval oleva versiooniga.

.DESCRIPTION
Skript laadib RIA Open-EID installerilehelt uusima versiooni,
loeb kohaliku versiooni Windowsi registrist ja võrdleb neid.
Kui vaja, saadab teavituse eelmise harjutuse mooduli kaudu.

.EXAMPLE
.\kontrolli-id-tarkvara.ps1
#>

[CmdletBinding()]
param(
    [switch]$DisableNotification
)

# ----------------------------
# KONSTANDID
# ----------------------------
$url = "https://installer.id.ee/media/win/"
$regexPattern = "Open-EID-(\d+\.\d+\.\d+\.\d+)\.exe"
$criticalMajorDiff = 2

# ----------------------------
# MOODUL
# ----------------------------
Import-Module ".\Saada-Teavitus.psm1" -ErrorAction SilentlyContinue

Write-Host "Kontrollin ID-tarkvara versiooni..." -ForegroundColor Cyan

# ----------------------------
# 1. VEEBIST UUSIM VERSIOON
# ----------------------------
try {
    $response = Invoke-WebRequest -Uri $url -ErrorAction Stop
    $content = $response.Content
}
catch {
    Write-Warning "Veebipäring ebaõnnestus: $($_.Exception.Message)"
    return
}

$matches = [regex]::Matches($content, $regexPattern)

if ($matches.Count -eq 0) {
    Write-Warning "Uusimat versiooni ei leitud."
    return
}

$versioonid = $matches | ForEach-Object {
    [Version]$_.Groups[1].Value
} | Sort-Object -Descending

$uusim = $versioonid[0]

# ----------------------------
# 2. KOHALIK VERSIOON (REGISTRY)
# ----------------------------
$paths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$program = Get-ItemProperty $paths -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -match "ID|EID|Open-EID" } |
    Select-Object -First 1

$kohalik = $null

if ($program -and $program.DisplayVersion) {

    # ----------------------------
    # PARANDUS: puhastame versiooni tekstist
    # ----------------------------
    $versionMatch = [regex]::Match($program.DisplayVersion, "\d+(\.\d+)+")

    if ($versionMatch.Success) {
        try {
            $kohalik = [Version]$versionMatch.Value
        }
        catch {
            $kohalik = $null
        }
    }
}

# ----------------------------
# 3. STAATUS
# ----------------------------
if (-not $kohalik) {
    $status = "POLE_PAIGALDATUD"
    $severity = "Warning"
    $message = "ID-tarkvara ei ole paigaldatud. Uusim versioon: $uusim"
}
elseif ($kohalik -eq $uusim) {
    $status = "OK"
    $severity = "Info"
    $message = "ID-tarkvara on ajakohane ($kohalik)"
}
elseif ($kohalik.Major -lt ($uusim.Major - $criticalMajorDiff)) {
    $status = "PALJU_VANEM"
    $severity = "Critical"
    $message = "ID-tarkvara on OLULISELT aegunud! Kohalik: $kohalik, uusim: $uusim"
}
else {
    $status = "AEGUNUD"
    $severity = "Warning"
    $message = "ID-tarkvara on aegunud. Kohalik: $kohalik, uusim: $uusim"
}

# ----------------------------
# 4. VÄLJUND
# ----------------------------
Write-Host "  Kohalik versioon: $kohalik"
Write-Host "  Uusim saadaval:   $uusim"
Write-Host "  Staatus:          $status"

# ----------------------------
# 5. TEAVITUS
# ----------------------------
if (-not $DisableNotification -and $status -ne "OK") {
    try {
        Send-AlertMessage -Message $message -Severity $severity
        Write-Host "[Teavitus saadetud]" -ForegroundColor Yellow
    }
    catch {
        Write-Warning "Teavituse saatmine ebaõnnestus: $($_.Exception.Message)"
    }
}
