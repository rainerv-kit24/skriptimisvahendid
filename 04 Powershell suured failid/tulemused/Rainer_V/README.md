# PowerShell harjutused — Rainer V

KIT-24

## Teavituste moodul

Discord webhook kaudu teavituste saatmine.

```powershell
Import-Module .\Saada-Teavitus.psm1 -Force
Send-AlertMessage -Message "Test" -Severity Info
```

Seadistamine: kopeeri `config.example.psd1` -> `config.psd1` ja lisa webhook URL.

## ID-tarkvara kontroll

Kontrollib kas Open-EID on ajakohane, võrdleb installer.id.ee lehelt leitud versiooni registris olevaga.

```powershell
.\kontrolli-id-tarkvara.ps1
```

Saadab Warning kui versioon on aegunud, Critical kui väga vana.

## Suurimad failid

```powershell
.\suurimad_failid.ps1
```

Leiab top 10 suurimat faili ja saadab teavituse kui üle 1GB.
