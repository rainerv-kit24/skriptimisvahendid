<#
.SYNOPSIS
    Kontrollib ID-tarkvara uuendusi ja teavitab, kui uus versioon on saadaval.

.DESCRIPTION
    Paerib uusima Open-EID versiooni installer.id.ee veebilehelt, vordleb seda
    Windowsi registris registreeritud paigaldatud versiooniga ning saadab
    vajaliku tosidusastmega teate Saada-Teavitus mooduli kaudu.

    Neli kasitletud olekut:
      POLE_PAIGALDATUD  - tarkvara pole registris     -> Warning
      OK                - versioonid kattuvad         -> vaikib (v.a -TeataAjakohasusest)
      AEGUNUD           - uuem versioon saadaval      -> Warning
      PALJU_VANEM       - erinevus >= KriitilineErinevus peaversiooni -> Critical

.PARAMETER KriitilineErinevus
    Mitme peaversiooni erinevuse korral saadetakse Critical, mitte Warning.
    Vaikimisi 2.

.PARAMETER TeataAjakohasusest
    Kui maaratud, saadab Info-teate ka siis, kui tarkvara on ajakohane.
    Muidu vaikib (soovitatav igapaevsel ajastamisel - vahem mura).

.EXAMPLE
    .\kontrolli-id-tarkvara.ps1

.EXAMPLE
    .\kontrolli-id-tarkvara.ps1 -TeataAjakohasusest -Verbose

.EXAMPLE
    .\kontrolli-id-tarkvara.ps1 -KriitilineErinevus 3

.NOTES
    Soltuvus: Saada-Teavitus.psm1 peab asuma samas kaustas selle skriptiga.
    Autor:    Techno-TLN labori haldur
    Versioon: 1.0
#>
[CmdletBinding()]
param(
    [int]   $KriitilineErinevus = 2,
    [switch]$TeataAjakohasusest
)

#region --- Konstandid ---

$SK_URL            = "https://installer.id.ee/media/win/"
# Regex: tapselt Open-EID-<versioon>.exe
# Ei taba -plugins.exe ega _x86.exe variante, sest nende eel on kriips/allakiri.
$INSTALLER_MUSTER  = 'Open-EID-(\d+\.\d+\.\d+\.\d+)\.exe'
$TEAVITUSE_ALLIKAS = "ID-tarkvara monitor"

# Registriteed, kus Windows hoiab paigaldatud programmide andmeid
$REGISTER_TEED = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

#endregion

#region --- Mooduli laadimine ---

$moodul = Join-Path $PSScriptRoot "Saada-Teavitus.psm1"
if (-not (Test-Path $moodul)) {
    Write-Error "Saada-Teavitus.psm1 ei leitud kaustast: $PSScriptRoot"
    exit 1
}
Import-Module $moodul -Force
Write-Verbose "Teavitusmoodul laaditud: $moodul"

#endregion

Write-Host "Kontrollin ID-tarkvara versiooni..." -ForegroundColor White

#region --- Samm 1: Uusima versiooni parimine SK veebilehelt ---

Write-Verbose "Parin versiooniinfot aadressilt: $SK_URL"

try {
    $leht = Invoke-WebRequest -Uri $SK_URL -UseBasicParsing -ErrorAction Stop
}
catch {
    $veateade = "Ei onnestunud uhendust luua aadressiga $SK_URL - $($_.Exception.Message)"
    Write-Warning $veateade
    Send-AlertMessage -Message $veateade -Severity Warning -Source $TEAVITUSE_ALLIKAS
    exit 1
}

#endregion

#region --- Samm 2: Regex - leia koik Open-EID versioonid ja sorteeri ---

$vasted = [regex]::Matches($leht.Content, $INSTALLER_MUSTER)

if (-not $vasted -or $vasted.Count -eq 0) {
    $veateade = "SK lehelt ($SK_URL) ei leitud uhtegi Open-EID installerit. " +
                "Voimalik, et faili nimetamise muster on muutunud."
    Write-Warning $veateade
    Send-AlertMessage -Message $veateade -Severity Warning -Source $TEAVITUSE_ALLIKAS
    exit 1
}

# Teisenda [Version]-tuubiks ja sorteeri kahanevalt - [0] on uusim.
# OLULINE: [Version] vordleb aritmeetiliselt, mitte tahestikuliselt!
# Naide: [Version]"25.10" -gt [Version]"25.6"  =>  $true
#        "25.10" -gt "25.6"                     =>  $false  (VALE!)
$versioonid = $vasted |
              ForEach-Object { [Version]$_.Groups[1].Value } |
              Sort-Object -Descending

$uusim = $versioonid[0]
Write-Verbose "Leitud $($versioonid.Count) versiooni SK lehelt. Uusim: $uusim"

#endregion

#region --- Samm 3: Kohaliku versiooni lugemine Windowsi registrist ---

# Miks kaks teed?
#   HKLM:\Software\...\Uninstall\*     => 64-bitine tarkvara
#   HKLM:\Software\WOW6432Node\...\*   => 32-bitine tarkvara 64-bitises Windowsis
# Ei tea, kumba varianti kasutajal on paigaldatud, seega kontrollime molemat.

$paigaldatud = Get-ItemProperty $REGISTER_TEED -ErrorAction SilentlyContinue |
               Where-Object { $_.DisplayName -match "Open-EID|Estonian ID" } |
               Select-Object -First 1

if ($paigaldatud) {
    Write-Verbose "Registrist leitud: $($paigaldatud.DisplayName) v$($paigaldatud.DisplayVersion)"
    try {
        $kohalik = [Version]$paigaldatud.DisplayVersion
    }
    catch {
        $veateade = "Registrist loetud versioonistring '$($paigaldatud.DisplayVersion)' " +
                    "ei ole teisendatav [Version]-tuubiks: $_"
        Write-Warning $veateade
        Send-AlertMessage -Message $veateade -Severity Warning -Source $TEAVITUSE_ALLIKAS
        exit 1
    }
} else {
    $kohalik = $null
    Write-Verbose "Registrist ei leitud uhtegi Open-EID / Estonian ID kirjet."
}

#endregion

#region --- Samm 4: Staatuse maaramine ---

if (-not $kohalik) {
    # Olek 1: Tarkvara pole paigaldatud
    $staatus  = "POLE_PAIGALDATUD"
    $severity = "Warning"
    $sonum    = "Open-EID ei ole paigaldatud. Uusim saadaval versioon: $uusim"
}
elseif ($kohalik -eq $uusim) {
    # Olek 2: Ajakohane
    $staatus  = "OK"
    $severity = "Info"
    $sonum    = "Open-EID $kohalik on ajakohane (uusim saadaval: $uusim)"
}
elseif (($uusim.Major - $kohalik.Major) -ge $KriitilineErinevus) {
    # Olek 4: Palju vanem (>= KriitilineErinevus peaversiooni erinevust)
    $vahe     = $uusim.Major - $kohalik.Major
    $staatus  = "PALJU_VANEM"
    $severity = "Critical"
    $sonum    = "Open-EID $kohalik on oluliselt vananenud ($vahe peaversiooni maha). " +
                "Uusim saadaval: $uusim. Uuenda esimesel voimalusel!"
}
else {
    # Olek 3: Aegunud (uuem versioon on olemas, aga erinevus on vaike)
    $staatus  = "AEGUNUD"
    $severity = "Warning"
    $sonum    = "Open-EID uuendus on saadaval: $kohalik -> $uusim"
}

#endregion

#region --- Vaeljund konsooli ---

$kohalikTekst = if ($kohalik) { "$kohalik" } else { "(pole paigaldatud)" }

Write-Host ("  Kohalik versioon:".PadRight(24) + $kohalikTekst)
Write-Host ("  Uusim saadaval:".PadRight(24)   + $uusim)
Write-Host ("  Staatus:".PadRight(24)           + $staatus)
Write-Host ""

#endregion

#region --- Samm 5: Teavituse saatmine ---

if ($staatus -ne "OK") {
    # Koigil muudel juhtudel (pole paigaldatud / aegunud / palju vanem) teavitame alati
    Send-AlertMessage -Message $sonum -Severity $severity -Source $TEAVITUSE_ALLIKAS
}
elseif ($TeataAjakohasusest) {
    # OK + -TeataAjakohasusest lueljuti => saadame Info
    Send-AlertMessage -Message $sonum -Severity Info -Source $TEAVITUSE_ALLIKAS
}
else {
    Write-Verbose "Tarkvara on ajakohane - teavitust ei saadeta (kasuta -TeataAjakohasusest, et saata Info)"
}

#endregion
