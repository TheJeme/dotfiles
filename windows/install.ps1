[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Force,
    [ValidateSet('Copy', 'Symlink')]
    [string]$Mode = 'Copy'
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$startupDir = [Environment]::GetFolderPath('Startup')
$downloadsDir = Join-Path $env:USERPROFILE 'Downloads'

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Ensure-Directory {
    param([string]$Path)

    if (Test-Path -LiteralPath $Path) {
        return
    }

    if ($DryRun) {
        Write-Host "[dry-run] mkdir $Path"
        return
    }

    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

function Sync-Directory {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "Source directory not found: $Source"
    }

    Ensure-Directory -Path $Destination

    Get-ChildItem -LiteralPath $Source -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Substring($Source.Length).TrimStart('\')
        $targetPath = Join-Path $Destination $relativePath
        Sync-File -Source $_.FullName -Destination $targetPath -Label "$Label $relativePath"
    }
}

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

    Ensure-Directory -Path (Split-Path -Parent $Destination)

    $destinationExists = Test-Path -LiteralPath $Destination
    $destinationItem = if ($destinationExists) { Get-Item -LiteralPath $Destination -Force } else { $null }

    if ($destinationExists -and $destinationItem.PSIsContainer) {
        throw "Destination is a directory, expected a file: $Destination"
    }

    if ($destinationExists -and -not $Force) {
        $sameContent = $false

        try {
            $sameContent = ((Get-FileHash -LiteralPath $Source).Hash -eq (Get-FileHash -LiteralPath $Destination).Hash)
        }
        catch {
            $sameContent = $false
        }

        if ($sameContent) {
            Write-Host "[skip] $Label is already up to date"
            return
        }

        Backup-ExistingFile -Path $Destination
    }

    if ($DryRun) {
        Write-Host "[dry-run] $Mode $Source -> $Destination"
        return
    }

    if ($destinationExists) {
        Remove-Item -LiteralPath $Destination -Force
    }

    switch ($Mode) {
        'Copy' {
            Copy-Item -LiteralPath $Source -Destination $Destination -Force
        }
        'Symlink' {
            New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -Force | Out-Null
        }
    }

    Write-Host "[ok] $Label -> $Destination"
}

function Get-TerminalSettingsTargets {
    $patterns = @(
        'Microsoft.WindowsTerminal_*',
        'Microsoft.WindowsTerminalPreview_*'
    )

    $targets = foreach ($pattern in $patterns) {
        Get-ChildItem -Path (Join-Path $env:LOCALAPPDATA 'Packages') -Directory -Filter $pattern -ErrorAction SilentlyContinue |
            ForEach-Object { Join-Path $_.FullName 'LocalState\settings.json' }
    }

    $targets | Select-Object -Unique
}

$mappings = @(
    @{
        Label = 'PowerShell profile'
        Source = Join-Path $PSScriptRoot 'powershell\Microsoft.PowerShell_profile.ps1'
        Destination = $PROFILE.CurrentUserCurrentHost
    }
    @{
        Label = 'Starship config'
        Source = Join-Path $PSScriptRoot 'starship\starship.toml'
        Destination = Join-Path $env:USERPROFILE '.config\starship.toml'
    }
    @{
        Label = 'AutoHotkey startup loader'
        Source = Join-Path $PSScriptRoot 'ahk\startup.ahk'
        Destination = Join-Path $startupDir 'dotfiles.ahk'
    }
    @{
        Label = 'TETR.IO config export'
        Source = Join-Path $PSScriptRoot 'tetrio\tetrio-config.ttc'
        Destination = Join-Path $downloadsDir 'tetrio-config.ttc'
    }
    @{
        Label = 'VS Code settings'
        Source = Join-Path $PSScriptRoot 'vscode\settings.json'
        Destination = Join-Path $env:APPDATA 'Code\User\settings.json'
    }
)

Write-Step "Deploying Windows dotfiles from $repoRoot"

foreach ($mapping in $mappings) {
    Sync-File -Source $mapping.Source -Destination $mapping.Destination -Label $mapping.Label
}

Sync-Directory `
    -Source (Join-Path $PSScriptRoot 'powershell\profile.d') `
    -Destination (Join-Path (Split-Path -Parent $PROFILE.CurrentUserCurrentHost) 'profile.d') `
    -Label 'PowerShell module'

Sync-File `
    -Source (Join-Path $PSScriptRoot 'powershell\Microsoft.PowerShell_profile.local.ps1.example') `
    -Destination (Join-Path (Split-Path -Parent $PROFILE.CurrentUserCurrentHost) 'Microsoft.PowerShell_profile.local.ps1.example') `
    -Label 'PowerShell local profile example'

Sync-Directory `
    -Source (Join-Path $PSScriptRoot 'ahk\modules') `
    -Destination (Join-Path $env:USERPROFILE 'Documents\AutoHotkey\dotfiles\modules') `
    -Label 'AutoHotkey module'

Sync-Directory `
    -Source (Join-Path $PSScriptRoot 'ahk\games') `
    -Destination (Join-Path $env:USERPROFILE 'Documents\AutoHotkey\dotfiles\games') `
    -Label 'AutoHotkey game helper'

$terminalTargets = Get-TerminalSettingsTargets

if (-not $terminalTargets) {
    Write-Host "[skip] Windows Terminal settings target not found"
}
else {
    foreach ($target in $terminalTargets) {
        Sync-File `
            -Source (Join-Path $PSScriptRoot 'windows-terminal\settings.json') `
            -Destination $target `
            -Label "Windows Terminal settings"
    }
}

Write-Host ""
Write-Host "Completed." -ForegroundColor Green
Write-Host "Mode: $Mode"
Write-Host "Dry run: $DryRun"
Write-Host "Startup folder: $startupDir"
Write-Host "PowerShell modules: $(Join-Path (Split-Path -Parent $PROFILE.CurrentUserCurrentHost) 'profile.d')"
Write-Host "AutoHotkey modules: $(Join-Path $env:USERPROFILE 'Documents\AutoHotkey\dotfiles\modules')"
Write-Host "TETR.IO config was copied to: $(Join-Path $downloadsDir 'tetrio-config.ttc')"
