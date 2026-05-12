#Serverite saadavuse monitor (Ülesanne B)

param(
    [string]$InputFile = "hostid.csv"
)

# Kontroll fail olemas
if (!(Test-Path $InputFile)) {
    Write-Host "Faili ei leitud: $InputFile" -ForegroundColor Red
    exit 1
}

$hosts = Import-Csv -Path $InputFile
$results = @()

Write-Host "Kontrollin $($hosts.Count) hosti..." -ForegroundColor Cyan
Write-Host ""

$okCount = 0

foreach ($h in $hosts) {
    $nimi = $h.nimi
    $hostname = $h.host
    $port = $h.port
    $kirjeldus = $h.kirjeldus

    $status = "FAIL"
    $latency = "-"

    try {
        if ($port -and $port -ne "") {
            # TCP kontroll
            $res = Test-NetConnection -ComputerName $hostname -Port $port -WarningAction SilentlyContinue

            if ($res.TcpTestSucceeded) {
                $status = "OK"
                if ($res.PingSucceeded) {
                    $latency = $res.PingReplyDetails.RoundtripTime
                }
            }
        }
        else {
            # Ping kontroll
            $ping = Test-Connection -ComputerName $host -Count 1 -ErrorAction Stop
            $status = "OK"
            $latency = $ping.ResponseTime
        }
    }
    catch {
        $status = "FAIL"
    }

    if ($status -eq "OK") {
        $okCount++
        Write-Host ("  {0,-15} {1,-25} OK    {2} ms" -f $nimi, $host, $latency) -ForegroundColor Green
    }
    else {
        Write-Host ("  {0,-15} {1,-25} FAIL  -" -f $nimi, $host) -ForegroundColor Red
    }

    $results += [PSCustomObject]@{
        Nimi            = $nimi
        Host            = $host
        Port            = $port
        Olek            = $status
        Viivitus_ms     = $latency
        Kontrollitud    = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        Kirjeldus       = $kirjeldus
    }
}

# Kokkuvõte
$total = $hosts.Count
$failCount = $total - $okCount

Write-Host ""
Write-Host "Kokkuvõte: $okCount / $total OK, $failCount maas" -ForegroundColor Yellow

# CSV salvestus kuupäevaga
$date = Get-Date -Format "yyyy-MM-dd"
$outputFile = "saadavus_$date.csv"

$results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Host "Tulemus salvestatud: $outputFile" -ForegroundColor Cyan