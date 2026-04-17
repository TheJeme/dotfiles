[CmdletBinding()]
param(
    [switch]$DryRun,
    [string[]]$Groups = @('Core', 'Dev', 'Apps', 'Creative', 'Gaming'),
    [switch]$InstallFonts
)

$ErrorActionPreference = 'Stop'
$packageData = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot 'packages.psd1')

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message" -ForegroundColor Cyan
}

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

Write-Step 'Updating winget sources'
Invoke-LoggedCommand -Description 'winget source update' -Action { winget source update }

foreach ($group in $Groups) {
    $ids = $packageData.Winget[$group]
    if (-not $ids) {
        Write-Host "[skip] Unknown package group: $group"
        continue
    }

    Write-Step "Installing winget group $group"
    foreach ($id in $ids) {
        Invoke-LoggedCommand -Description "winget install $id" -Action {
            winget install -e --id $id --accept-source-agreements --accept-package-agreements
        }
    }
}

if ($InstallFonts) {
    Write-Step 'Installing Scoop font bucket and fonts'
    foreach ($bucket in $packageData.Scoop.Buckets) {
        Invoke-LoggedCommand -Description "scoop bucket add $bucket" -Action { scoop bucket add $bucket }
    }

    foreach ($font in $packageData.Scoop.Fonts) {
        Invoke-LoggedCommand -Description "scoop install $font" -Action { scoop install $font }
    }
}

Write-Host ''
Write-Host 'Completed.' -ForegroundColor Green
Write-Host "Dry run: $DryRun"
