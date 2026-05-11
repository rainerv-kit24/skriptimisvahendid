<#
.SYNOPSIS
    Teavitusmoodul sõnumite saatmiseks erinevate kanalite kaudu.

.DESCRIPTION
    Pakub funktsiooni Send-AlertMessage, mis saadab teavitusi konsooli,
    logifaili ja Windowsi sundmuselogi kaudu. Tosidusastmed: Info,
    Warning, Critical.

.NOTES
    Versioon:  1.0
    Autor:     Techno-TLN labori haldur
    Eesmärk:   Kasutatav teiste skriptide poolt sõltuvusena (import-module)
#>

#region --- Seadistus (muuda siia, mitte funktsiooni sisse) ---

# Logifaili asukoht. $null = ara kirjuta faili.
$script:LogFile = Join-Path $env:TEMP "teavitused.log"

# Kas kirjutada Windowsi sundmuselogi? Vajab administraatoriõigusi esimesel korral.
$script:KasKirjutaSyndmuselogi = $false

# Sundmuselogis kasutatav allikas
$script:SyndmuseAllikas = "TechnoTLN-Monitor"

#endregion

function Send-AlertMessage {
    <#
    .SYNOPSIS
        Saadab teavituse maaratud tosidusastmega.

    .DESCRIPTION
        Kirjutab sõnumi konsooli (varviliselt), logifaili ja valikuliselt
        Windowsi sundmuselogi. Tosidusaste maarab varvi ja EventLog-i taseme.

    .PARAMETER Message
        Saadetava teavituse tekst.

    .PARAMETER Severity
        Tosidusaste: Info, Warning või Critical. Vaikimisi Warning.

    .PARAMETER Source
        Teate allikas (nt skripti nimi või arvuti nimi).
        Vaikimisi kasutatakse arvuti nime.

    .EXAMPLE
        Send-AlertMessage -Message "Kõik on korras" -Severity Info

    .EXAMPLE
        Send-AlertMessage -Message "Uuendus saadaval!" -Severity Warning -Source "ID-tarkvara monitor"

    .EXAMPLE
        Send-AlertMessage -Message "Kriitiline tõrge!" -Severity Critical -Source "ID-tarkvara monitor"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Message,

        [ValidateSet("Info", "Warning", "Critical")]
        [string]$Severity = "Warning",

        [string]$Source = $env:COMPUTERNAME
    )

    process {
        $ajatempel = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $rida      = "[$ajatempel] [$Severity] [$Source] $Message"

        # --- 1. Konsool (varviline) ---
        $varv = switch ($Severity) {
            "Info"     { "Cyan"   }
            "Warning"  { "Yellow" }
            "Critical" { "Red"    }
        }

        $ikoon = switch ($Severity) {
            "Info"     { "[i]" }
            "Warning"  { "[!]" }
            "Critical" { "[X]" }
        }

        Write-Host "$ikoon $rida" -ForegroundColor $varv

        # --- 2. Logifail ---
        if ($script:LogFile) {
            try {
                Add-Content -Path $script:LogFile -Value $rida -Encoding UTF8 -ErrorAction Stop
                Write-Verbose "Logifaili kirjutatud: $($script:LogFile)"
            }
            catch {
                Write-Warning "Logifaili kirjutamine ebaõnnestus: $_"
            }
        }

        # --- 3. Windowsi sundmuselogi (valikuline) ---
        if ($script:KasKirjutaSyndmuselogi) {
            $entryType = switch ($Severity) {
                "Info"     { "Information" }
                "Warning"  { "Warning"     }
                "Critical" { "Error"       }
            }

            try {
                if (-not [System.Diagnostics.EventLog]::SourceExists($script:SyndmuseAllikas)) {
                    New-EventLog -LogName Application -Source $script:SyndmuseAllikas -ErrorAction Stop
                }
                Write-EventLog -LogName Application `
                               -Source $script:SyndmuseAllikas `
                               -EventId 1000 `
                               -EntryType $entryType `
                               -Message $Message `
                               -ErrorAction Stop
                Write-Verbose "Sundmuselogi kirje lisatud"
            }
            catch {
                Write-Warning "Sundmuselogi kirjutamine ebaõnnestus: $_"
            }
        }
    }
}

Export-ModuleMember -Function Send-AlertMessage
