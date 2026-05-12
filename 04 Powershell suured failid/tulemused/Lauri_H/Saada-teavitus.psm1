$configPath = Join-Path $PSScriptRoot "config.psd1"
$config = Import-PowerShellDataFile $configPath
$url = $config.WebhookUrl
function Send-AlertMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [ValidateSet("Info","Warning","Critical")]
        [string]$Severity = "Info"
    )

    $config = Import-PowerShellDataFile -Path ".\config.psd1"
    $url = $config.WebhookUrl

    $color = switch ($Severity) {
        "Info"     { 3447003 }
        "Warning"  { 16776960 }
        "Critical" { 15158332 }
    }

    $payload = @{
        username = "PS-Monitor"
        embeds = @(
            @{
                description = "[$Severity] $Message"
                color       = $color
                timestamp   = (Get-Date).ToString("o")
            }
        )
    } | ConvertTo-Json -Depth 4

    Invoke-RestMethod -Uri $url -Method Post -Body $payload -ContentType "application/json"
}
$logPath = Join-Path $env:TEMP "ps-alerts.log"
$aeg = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

try {
    Invoke-RestMethod ... -ErrorAction Stop
    Add-Content -Path $logPath -Value "$aeg [OK]   $Severity | $Source | $Message"
}
catch {
    Add-Content -Path $logPath -Value "$aeg [FAIL] $Severity | $Source | $Message | $($_.Exception.Message)"
}
Export-ModuleMember -Function Send-AlertMessage