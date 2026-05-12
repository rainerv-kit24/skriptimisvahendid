# =====================================================
#  10 kõige suuremat faili kasutaja kodukaustas
#  Kursus: KIT-24  |  Õpetaja: Toivo Pärnpuu
#  Autor:  Mark L.
#  Keel:   PowerShell
# =====================================================
#
#  Skript otsib rekursiivselt kasutaja kodukaustast (või
#  käsureal antud kaustast) 10 kõige suuremat faili ja
#  salvestab tulemuse faili suurimad_failid.csv.
#
#  Lisaülesanded:
#   - param() blokk: otsingukoht käsurea argumendina
#   - AppData kausta välistamine
#   - lisaveerg "Muudetud" (faili viimase muutmise kuupäev)

# ------------------------------------------------------
# Käsurea argumendid
# ------------------------------------------------------
param(
    # Otsingukoht — vaikimisi kasutaja kodukaust
    [string]$Otsingukaust = $HOME,

    # Lipp, mis lülitab AppData filtri välja
    [switch]$LisaAppData
)


# ------------------------------------------------------
# Abifunktsioon — teisenda baidid loetavasse ühikusse
# ------------------------------------------------------
function Convert-Suurus {
    param([long]$Baidid)

    if ($Baidid -ge 1GB) {
        return "{0:N1} GB" -f ($Baidid / 1GB)
    }
    elseif ($Baidid -ge 1MB) {
        return "{0:N1} MB" -f ($Baidid / 1MB)
    }
    else {
        return "{0:N1} KB" -f ($Baidid / 1KB)
    }
}


# ------------------------------------------------------
# 1. Leia kõik failid rekursiivselt
# ------------------------------------------------------
Write-Host "Otsin faile kaustast: $Otsingukaust"

if (-not $LisaAppData) {
    Write-Host "(AppData kaust on välja jäetud — kasuta -LisaAppData, et lisada)"
}
Write-Host ""

$failid = Get-ChildItem -Path $Otsingukaust -Recurse -File -ErrorAction SilentlyContinue

# AppData välistamine (kui lippu pole antud)
if (-not $LisaAppData) {
    $failid = $failid | Where-Object { $_.FullName -notmatch "\\AppData\\" }
}

Write-Host "Leitud faile kokku: $($failid.Count)"


# ------------------------------------------------------
# 2. Sorteeri suuruse järgi ja võta 10 esimest
# ------------------------------------------------------
$top10 = $failid |
    Sort-Object -Property Length -Descending |
    Select-Object -First 10


# ------------------------------------------------------
# 3 + 4. Ehita iga faili kohta objekt koos vorminduse ja
#         viimase muutmise kuupäevaga
# ------------------------------------------------------
$tulemus = foreach ($fail in $top10) {
    [PSCustomObject]@{
        Tee      = $fail.FullName
        Nimi     = $fail.Name
        Suurus   = Convert-Suurus -Baidid $fail.Length
        Muudetud = $fail.LastWriteTime.ToString("yyyy-MM-dd")
    }
}


# ------------------------------------------------------
# Kuva ekraanile
# ------------------------------------------------------
Write-Host ""
Write-Host "10 suurimat faili:"
Write-Host ("-" * 70)
$i = 1
foreach ($rida in $tulemus) {
    $jrk = "{0,2}." -f $i
    $sz  = "{0,10}" -f $rida.Suurus
    Write-Host "  $jrk $sz  $($rida.Muudetud)  $($rida.Nimi)"
    $i++
}


# ------------------------------------------------------
# 5. Salvesta CSV-faili (skripti kõrvale)
# ------------------------------------------------------
$skriptiKaust = Split-Path -Parent $MyInvocation.MyCommand.Path
$väljund      = Join-Path -Path $skriptiKaust -ChildPath "suurimad_failid.csv"

$tulemus | Export-Csv -Path $väljund -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Salvestatud: $väljund"
