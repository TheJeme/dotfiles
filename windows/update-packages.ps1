[CmdletBinding()]
param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

function Invoke-LoggedCommand {
    param(
        [string]$Description,
        [scriptblock]$Action
    )

    if ($DryRun) {
        Write-Host "[dry-run] $Description"
        return
    }

    & $Action
}

Invoke-LoggedCommand -Description 'winget source update' -Action { winget source update }
Invoke-LoggedCommand -Description 'winget upgrade --all' -Action {
    winget upgrade --all --accept-source-agreements --accept-package-agreements
}

Write-Host ''
Write-Host 'Completed.' -ForegroundColor Green
Write-Host "Dry run: $DryRun"
