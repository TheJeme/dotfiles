[CmdletBinding()]
param(
    [switch]$DryRun,
    [string]$UserName,
    [string]$UserEmail,
    [string]$Editor
)

$ErrorActionPreference = 'Stop'

$gitConfigPath = Join-Path $env:USERPROFILE '.gitconfig'
$gitLocalConfigPath = Join-Path $env:USERPROFILE '.gitconfig.local'
$gitIgnoreGlobalPath = Join-Path $env:USERPROFILE '.gitignore_global'
$managedGitConfigSource = Join-Path $PSScriptRoot 'git\.gitconfig'
$managedGitIgnoreSource = Join-Path $PSScriptRoot 'git\.gitignore_global'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message" -ForegroundColor Cyan
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

    $destinationExists = Test-Path -LiteralPath $Destination

    if ($destinationExists) {
        try {
            if ((Get-FileHash -LiteralPath $Source).Hash -eq (Get-FileHash -LiteralPath $Destination).Hash) {
                Write-Host "[skip] $Label is already up to date"
                return
            }
        }
        catch {
        }

        Backup-ExistingFile -Path $Destination
    }

    if ($DryRun) {
        Write-Host "[dry-run] copy $Source -> $Destination"
        return
    }

    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    Write-Host "[ok] $Label -> $Destination"
}

function Get-ExistingGitValue {
    param([string]$Key)

    try {
        $value = git config --global --get $Key 2>$null
        if ([string]::IsNullOrWhiteSpace($value)) {
            return $null
        }
        return $value.Trim()
    }
    catch {
        return $null
    }
}

function Set-GitConfigValue {
    param(
        [string]$FilePath,
        [string]$Key,
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return
    }

    if ($DryRun) {
        Write-Host "[dry-run] git config --file `"$FilePath`" $Key `"$Value`""
        return
    }

    git config --file "$FilePath" $Key "$Value"
}

Write-Step 'Deploying managed Git config'
Sync-File -Source $managedGitConfigSource -Destination $gitConfigPath -Label 'Global Git config'
Sync-File -Source $managedGitIgnoreSource -Destination $gitIgnoreGlobalPath -Label 'Global Git ignore'

$resolvedUserName = if ($PSBoundParameters.ContainsKey('UserName')) { $UserName } else { Get-ExistingGitValue -Key 'user.name' }
$resolvedUserEmail = if ($PSBoundParameters.ContainsKey('UserEmail')) { $UserEmail } else { Get-ExistingGitValue -Key 'user.email' }
$resolvedEditor = if ($PSBoundParameters.ContainsKey('Editor')) { $Editor } else { Get-ExistingGitValue -Key 'core.editor' }

Write-Step 'Writing local Git overrides'

if (-not (Test-Path -LiteralPath $gitLocalConfigPath)) {
    if ($DryRun) {
        Write-Host "[dry-run] create $gitLocalConfigPath"
    }
    else {
        New-Item -ItemType File -Path $gitLocalConfigPath -Force | Out-Null
    }
}

Set-GitConfigValue -FilePath $gitLocalConfigPath -Key 'user.name' -Value $resolvedUserName
Set-GitConfigValue -FilePath $gitLocalConfigPath -Key 'user.email' -Value $resolvedUserEmail
Set-GitConfigValue -FilePath $gitLocalConfigPath -Key 'core.editor' -Value $resolvedEditor

Write-Host ''
Write-Host 'Completed.' -ForegroundColor Green
Write-Host "Dry run: $DryRun"
Write-Host "Managed config: $gitConfigPath"
Write-Host "Local overrides: $gitLocalConfigPath"
