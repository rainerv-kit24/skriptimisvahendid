Import-Module .\Saada-Teavitus.psm1 -Force

$homeDir = $HOME
$appData = Join-Path $homeDir "AppData"

function Format-Size($bytes) {
    if ($bytes -ge 1GB) { "{0:N2} GB" -f ($bytes / 1GB) }
    elseif ($bytes -ge 1MB) { "{0:N2} MB" -f ($bytes / 1MB) }
    else { "{0:N2} KB" -f ($bytes / 1KB) }
}

$failid = Get-ChildItem -Path $homeDir -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notlike "$appData*" } |
    Sort-Object Length -Descending |
    Select-Object -First 10

$tulemus = foreach ($fail in $failid) {
    [PSCustomObject]@{
        Tee    = $fail.FullName
        Nimi   = $fail.Name
        Bytes  = $fail.Length
        Suurus = Format-Size $fail.Length
    }
}

$foundLarge = $false

foreach ($fail in $tulemus) {
    if ($fail.Bytes -ge 1GB) {
        $foundLarge = $true
    }

    if ($fail.Bytes -ge 5GB) {
        Send-AlertMessage -Message "Väga suur fail: $($fail.Nimi) ($($fail.Suurus))" -Severity Critical
    }
    elseif ($fail.Bytes -ge 1GB) {
        Send-AlertMessage -Message "Suur fail: $($fail.Nimi) ($($fail.Suurus))" -Severity Warning
    }
}

if (-not $foundLarge) {
    Send-AlertMessage -Message "Suuri faile ei leitud" -Severity Info
}

# --- REPLACED CSV EXPORT (masked paths) ---
$masked = $tulemus | ForEach-Object {
    $parts = $_.Tee -split '\\'

    if ($parts.Count -ge 4) {
        $parts[0] = "X:"
        $parts[1] = "X"
        $parts[2] = "X"
    }

    [PSCustomObject]@{
        Tee    = $parts -join '\'
        Nimi   = $_.Nimi
        Bytes  = $_.Bytes
        Suurus = $_.Suurus
    }
}

$masked | Export-Csv -Path "suurimad_failid.csv" -NoTypeInformation -Encoding UTF8
$masked