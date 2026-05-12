<#
.SYNOPSIS
Serverite saadavuse monitor (ICMP + TCP kontroll)

.DESCRIPTION
Loeb hostid CSV failist, kontrollib nende saadavust (ping või TCP port),
salvestab tulemused CSV faili ning kuvab kokkuvõtte.

.PARAMETER InputFile
Sisend CSV fail (vaikimisi hostid.csv)

.PARAMETER OutputFolder
Kaust kuhu tulemused salvestatakse

.EXAMPLE
.\kontrolli-hostid.ps1
.\kontrolli-hostid.ps1 -InputFile "minuhostid.csv"
#>

[CmdletBinding()]
param(
    [string]$InputFile = "hostid.csv",
    [string]$OutputFolder = "."
)

# -----------------------------
# 1. SISEND
# -----------------------------
if (!(Test-Path $InputFile)) {
    throw "Sisendfaili ei leitud: $InputFile"
}

$hostid = Import-Csv $InputFile

Write-Host "Kontrollin $($hostid.Count) hosti..." -ForegroundColor Cyan

# -----------------------------
# 2. FUNKTSIOON (hosti test)
# -----------------------------
function Test-HostStatus {
    [CmdletBinding()]
    param(
        [string]$ComputerName,
        [int]$Port = 0
    )

    try {

        # -------------------------
        # TCP kontroll
        # -------------------------
        if ($Port -gt 0) {

            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

            $tcp = Test-NetConnection -ComputerName $ComputerName -Port $Port -WarningAction SilentlyContinue

            $stopwatch.Stop()

            return [PSCustomObject]@{
                Olek        = if ($tcp.TcpTestSucceeded) { "OK" } else { "FAIL" }
                Viivitus_ms = $stopwatch.ElapsedMilliseconds
            }
        }

        # -------------------------
        # ICMP ping + mõõtmine
        # -------------------------
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        $ping = Test-Connection -ComputerName $ComputerName -Count 1 -ErrorAction Stop

        $stopwatch.Stop()

        return [PSCustomObject]@{
            Olek        = "OK"
            Viivitus_ms = $stopwatch.ElapsedMilliseconds
        }
    }
    catch {
        return [PSCustomObject]@{
            Olek        = "FAIL"
            Viivitus_ms = $null
        }
    }
}

# -----------------------------
# 3. KONTROLL LOOP
# -----------------------------
$tulemus = foreach ($h in $hostid) {

    $port = if ($h.port) { [int]$h.port } else { 0 }

    $test = Test-HostStatus -ComputerName $h.host -Port $port

    # Konsooli väljund
    $color = if ($test.Olek -eq "OK") { "Green" } else { "Red" }

    $lat = if ($test.Viivitus_ms -ne $null) {
    "$($test.Viivitus_ms) ms"
} else {
    "-"
}

Write-Host ("{0,-15} {1,-25} {2,-5} {3}" -f `
    $h.nimi, $h.host, $test.Olek, $lat) -ForegroundColor $color

    # Tulemus objektiks
    [PSCustomObject]@{
        Nimi          = $h.nimi
        Host          = $h.host
        Port          = $h.port
        Olek          = $test.Olek
        Viivitus_ms   = $test.Viivitus_ms
        Kontrollitud  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Kirjeldus     = $h.kirjeldus
    }
}

# -----------------------------
# 4. SALVESTUS
# -----------------------------
$kuupäev = Get-Date -Format "yyyy-MM-dd"
$failinimi = Join-Path $OutputFolder "saadavus_$kuupäev.csv"

$tulemus | Export-Csv -Path $failinimi -NoTypeInformation -Encoding UTF8

# -----------------------------
# 5. STATISTIKA
# -----------------------------
$ok = ($tulemus | Where-Object Olek -eq "OK").Count
$fail = ($tulemus | Where-Object Olek -eq "FAIL").Count

Write-Host ""
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "KOKKUVÕTE" -ForegroundColor Cyan
Write-Host "OK:   $ok" -ForegroundColor Green
Write-Host "FAIL: $fail" -ForegroundColor Red
Write-Host "Kokku: $($tulemus.Count)" -ForegroundColor Cyan
Write-Host "Fail salvestatud: $failinimi" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# -----------------------------
# 6. (VALIKULINE) HOIATUS
# -----------------------------
if ($fail -gt 0) {
    Write-Host "HOIATUS: vähemalt üks host on maas!" -ForegroundColor Yellow
}