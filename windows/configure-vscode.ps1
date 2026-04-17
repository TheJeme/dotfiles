[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$InstallExtensions
)

$ErrorActionPreference = 'Stop'

$settingsSource = Join-Path $PSScriptRoot 'vscode\settings.json'
$settingsDestination = Join-Path $env:APPDATA 'Code\User\settings.json'
$extensionsSource = Join-Path $PSScriptRoot 'vscode\extensions.txt'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Backup-ExistingFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    $backupPath = "$Path.bak.$timestamp"

    if ($DryRun) {
        Write-Host "[dry-run] backup $Path -> $backupPath"
        return
    }

    Copy-Item -LiteralPath $Path -Destination $backupPath -Force
}

function Sync-File {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "Source file not found: $Source"
    }

    $parent = Split-Path -Parent $Destination
    if (-not (Test-Path -LiteralPath $parent)) {
        if ($DryRun) {
            Write-Host "[dry-run] mkdir $parent"
        }
        else {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
    }

    if (Test-Path -LiteralPath $Destination) {
        Backup-ExistingFile -Path $Destination
    }

    if ($DryRun) {
        Write-Host "[dry-run] copy $Source -> $Destination"
        return
    }

    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    Write-Host "[ok] $Label -> $Destination"
}

Sync-File -Source $settingsSource -Destination $settingsDestination -Label 'VS Code settings'

if ($InstallExtensions) {
    Get-Content -LiteralPath $extensionsSource | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object {
        if ($DryRun) {
            Write-Host "[dry-run] code --install-extension $_"
        }
        else {
            code --install-extension $_
        }
    }
}

Write-Host ''
Write-Host 'Completed.' -ForegroundColor Green
Write-Host "Dry run: $DryRun"
Write-Host "Install extensions: $InstallExtensions"
