Import-Module .\Saada-Teavitus.psm1

Write-Host "Kontrollin ID-tarkvara versiooni... $(Get-Date)"

# 🔹 1. Võta uusim versioon veebist
    $response = Invoke-WebRequest -Uri "https://installer.id.ee/media/win/" -UseBasicParsing
    $content = $response.Content

    # Leia versioon (nt 25.10.23.8403)
$versions = [regex]::Matches($content, '\d+\.\d+\.\d+\.\d+') | ForEach-Object {
    try { [Version]$_.Value } catch {}
}

$latestVersion = $versions | Sort-Object -Descending | Select-Object -First 1

# 🔹 2. Leia kohalik versioon registrist
$uninstallTeed = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$paigaldatud = Get-ItemProperty $uninstallTeed -ErrorAction SilentlyContinue |
               Where-Object { $_.DisplayName -match "Open-EID|Estonian ID|DigiDoc4" } |
               Select-Object -First 1

if ($paigaldatud) {
    try {
        $localVersion = [Version]$paigaldatud.DisplayVersion
    } catch {
        $localVersion = $null
    }
} else {
    $localVersion = $null
}
# 🔹 3. Kuvamine
Write-Host "  Kohalik versioon:     $(if ($localVersion) { $localVersion } else { 'PUUDUB' })"
Write-Host "  Uusim saadaval:      " $latestVersion

# 🔹 4. Loogika
if (-not $localVersion) {
    Write-Host "  Staatus:             POLE PAIGALDATUD"

    Send-AlertMessage -Message "ID-tarkvara puudub arvutist" -Severity Warning
}
else {
    if ($localVersion -eq $latestVersion) {
        Write-Host "  Staatus:             OK"

        # valikuline:
        # Send-AlertMessage -Message "ID-tarkvara on ajakohane" -Severity Info
    }
    elseif ($localVersion -lt $latestVersion) {

        # kontroll: kas väga vana (üle 2 major versiooni)
        if (($latestVersion.Major - $localVersion.Major) -ge 2) {
            Write-Host "  Staatus:             VÄGA AEGUNUD"

            Send-AlertMessage -Message "ID-tarkvara väga vana. Kohalik: $localVersion | Uus: $latestVersion" -Severity Critical
        }
        else {
            Write-Host "  Staatus:             AEGUNUD — uuendus soovitatav"

            Send-AlertMessage -Message "ID-tarkvara vajab uuendust ($localVersion → $latestVersion)" -Severity Warning
        }
    }
}