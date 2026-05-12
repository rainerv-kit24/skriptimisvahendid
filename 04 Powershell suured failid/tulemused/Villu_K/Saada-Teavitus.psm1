function Send-AlertMessage {
<#
.SYNOPSIS
    Saadab teavituse Discordi webhooki kaudu.

.DESCRIPTION
    Send-AlertMessage saadab REST API kaudu teate monitooringukanalisse.

.PARAMETER Message
    Teate tekst. Kohustuslik.

.PARAMETER Severity
    Teate raskusaste: Info, Warning või Critical.

.PARAMETER Source
    Allika nimi (vaikimisi arvuti nimi).
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("Info","Warning","Critical")]
        [string]$Severity = "Info",

        [string]$Source = "LOCAL-PC-1"
    )
    $configPath = Join-Path $PSScriptRoot "config.psd1"
    $config = Import-PowerShellDataFile $configPath
    # $url = $config.WebhookUrl

    $url = $env:ALERT_WEBHOOK
    if (-not $url) { throw "ALERT_WEBHOOK env puudub (Tee powershellile resa v lisa oige url)" }
    
    $color = switch ($Severity) {
        "Info"     { 3447003 }
        "Warning"  { 16776960 }
        "Critical" { 15158332 }
    }

    $payload = @{
        username = "PS-Monitor"
        embeds = @(@{
            title       = "[$Severity] $Source"
            description = $Message
            color       = $color
            timestamp   = (Get-Date).ToString("o")
        })
    } | ConvertTo-Json -Depth 4

    $logPath = Join-Path $PSScriptRoot "ps-alerts.log"
    $aeg = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"

    try {
        Invoke-RestMethod -Uri $url -Method Post -Body $payload -ContentType "application/json" -ErrorAction Stop
        Add-Content -Path $logPath -Value "$aeg [OK]   $Severity | $Source | $Message"
        Write-Verbose "Teavitus saadetud: $Message"
    }
    catch {
        Add-Content -Path $logPath -Value "$aeg [FAIL] $Severity | $Source | $Message | $($_.Exception.Message)"
        Write-Warning "Teavituse saatmine ebaõnnestus: $($_.Exception.Message)"
    }
}