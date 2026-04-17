[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$IncludeOptionalCleanup,
    [switch]$InstallWslConfig,
    [switch]$ImportPowerToys,
    [switch]$ExportPowerToys,
    [switch]$RestartExplorer
)

$ErrorActionPreference = 'Stop'

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$powerToysSourceDir = Join-Path $env:LOCALAPPDATA 'Microsoft\PowerToys'
$powerToysBackupDir = Join-Path $PSScriptRoot 'powertoys\backup'
$wslConfigSource = Join-Path $PSScriptRoot 'wsl\.wslconfig'
$wslConfigDestination = Join-Path $env:USERPROFILE '.wslconfig'
$wslConfSource = Join-Path $PSScriptRoot 'wsl\wsl.conf'
$wslConfDestination = Join-Path $env:USERPROFILE 'Downloads\wsl.conf'

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Action {
    param([string]$Message)
    if ($DryRun) {
        Write-Host "[dry-run] $Message"
    }
    else {
        Write-Host "[ok] $Message"
    }
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

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [ValidateSet('String', 'ExpandString', 'Binary', 'DWord', 'MultiString', 'QWord')]
        [string]$Type = 'DWord'
    )

    if ($DryRun) {
        Write-Host "[dry-run] reg set $Path :: $Name = $Value ($Type)"
        return
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
}

function Set-ExecutionPolicySafe {
    param(
        [string]$Scope,
        [string]$Policy
    )

    if ($DryRun) {
        Write-Host "[dry-run] Set-ExecutionPolicy -Scope $Scope -ExecutionPolicy $Policy -Force"
        return
    }

    Set-ExecutionPolicy -Scope $Scope -ExecutionPolicy $Policy -Force
}

function Get-PowerToysFiles {
    param([string]$BasePath)

    if (-not (Test-Path -LiteralPath $BasePath)) {
        return @()
    }

    $excludedDirectoryNames = @('Logs', 'RunnerLogs', 'UpdateLogs', 'Updates', 'Backup')

    Get-ChildItem -LiteralPath $BasePath -Recurse -File | Where-Object {
        $parts = $_.FullName.Substring($BasePath.Length).TrimStart('\').Split('\')
        -not ($parts | Where-Object { $_ -in $excludedDirectoryNames })
    }
}

function Sync-PowerToysTree {
    param(
        [string]$SourceBase,
        [string]$DestinationBase,
        [string]$DirectionLabel
    )

    $files = Get-PowerToysFiles -BasePath $SourceBase

    if (-not $files) {
        Write-Host "[skip] No PowerToys settings found for $DirectionLabel"
        return
    }

    foreach ($file in $files) {
        $relativePath = $file.FullName.Substring($SourceBase.Length).TrimStart('\')
        $destination = Join-Path $DestinationBase $relativePath
        Sync-File -Source $file.FullName -Destination $destination -Label "PowerToys $relativePath"
    }
}

function Set-UserDefaults {
    Write-Step 'Applying Explorer, taskbar, and shell defaults'

    $advancedPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    $searchPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
    $contentPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    $privacyPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy'
    $advertisingPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
    $consolePath = 'HKCU:\Console'
    $siufPath = 'HKCU:\Software\Microsoft\Siuf\Rules'
    $feedsPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds'

    Set-RegistryValue -Path $advancedPath -Name Hidden -Value 1
    Set-RegistryValue -Path $advancedPath -Name HideFileExt -Value 0
    Set-RegistryValue -Path $advancedPath -Name ShowSuperHidden -Value 1
    Set-RegistryValue -Path $advancedPath -Name LaunchTo -Value 1
    Set-RegistryValue -Path $advancedPath -Name UseCompactMode -Value 0
    Set-RegistryValue -Path $advancedPath -Name SeparateProcess -Value 1
    Set-RegistryValue -Path $advancedPath -Name ShowSyncProviderNotifications -Value 0

    Set-RegistryValue -Path $advancedPath -Name TaskbarAl -Value 0
    Set-RegistryValue -Path $advancedPath -Name ShowTaskViewButton -Value 0
    Set-RegistryValue -Path $advancedPath -Name TaskbarDa -Value 0
    Set-RegistryValue -Path $advancedPath -Name TaskbarMn -Value 0
    Set-RegistryValue -Path $advancedPath -Name Start_TrackDocs -Value 0
    Set-RegistryValue -Path $advancedPath -Name Start_IrisRecommendations -Value 0

    Set-RegistryValue -Path $searchPath -Name SearchboxTaskbarMode -Value 0
    Set-RegistryValue -Path $feedsPath -Name ShellFeedsTaskbarViewMode -Value 2

    Set-RegistryValue -Path $consolePath -Name CodePage -Value 65001
    Set-RegistryValue -Path $consolePath -Name VirtualTerminalLevel -Value 1

    Set-RegistryValue -Path $contentPath -Name ContentDeliveryAllowed -Value 0
    Set-RegistryValue -Path $contentPath -Name FeatureManagementEnabled -Value 0
    Set-RegistryValue -Path $contentPath -Name OemPreInstalledAppsEnabled -Value 0
    Set-RegistryValue -Path $contentPath -Name PreInstalledAppsEnabled -Value 0
    Set-RegistryValue -Path $contentPath -Name PreInstalledAppsEverEnabled -Value 0
    Set-RegistryValue -Path $contentPath -Name SilentInstalledAppsEnabled -Value 0
    Set-RegistryValue -Path $contentPath -Name SoftLandingEnabled -Value 0
    Set-RegistryValue -Path $contentPath -Name RotatingLockScreenEnabled -Value 0
    Set-RegistryValue -Path $contentPath -Name RotatingLockScreenOverlayEnabled -Value 0
    Set-RegistryValue -Path $contentPath -Name SubscribedContent-310093Enabled -Value 0
    Set-RegistryValue -Path $contentPath -Name SubscribedContent-338388Enabled -Value 0
    Set-RegistryValue -Path $contentPath -Name SubscribedContent-338389Enabled -Value 0
    Set-RegistryValue -Path $contentPath -Name SubscribedContent-338393Enabled -Value 0
    Set-RegistryValue -Path $contentPath -Name SubscribedContent-353694Enabled -Value 0
    Set-RegistryValue -Path $contentPath -Name SubscribedContent-353698Enabled -Value 0
    Set-RegistryValue -Path $contentPath -Name SystemPaneSuggestionsEnabled -Value 0

    Set-RegistryValue -Path $advertisingPath -Name Enabled -Value 0
    Set-RegistryValue -Path $privacyPath -Name TailoredExperiencesWithDiagnosticDataEnabled -Value 0

    if ($IncludeOptionalCleanup) {
        Write-Step 'Applying optional noise cleanup'
        Set-RegistryValue -Path $siufPath -Name NumberOfSIUFInPeriod -Value 0
        Set-RegistryValue -Path $siufPath -Name PeriodInNanoSeconds -Value 0 -Type QWord
    }
}

function Set-MachineDefaults {
    if (-not (Test-IsAdministrator)) {
        Write-Host "[skip] Machine-level defaults require an elevated PowerShell session"
        return
    }

    Write-Step 'Applying machine-level developer defaults'

    Set-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Name AllowDevelopmentWithoutDevLicense -Value 1
    Set-RegistryValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name LongPathsEnabled -Value 1

    if ($IncludeOptionalCleanup) {
        Set-RegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' -Name AllowNewsAndInterests -Value 0
    }
}

function Set-DeveloperDefaults {
    Write-Step 'Applying developer defaults'
    Set-ExecutionPolicySafe -Scope CurrentUser -Policy RemoteSigned
    Set-MachineDefaults
}

function Install-WslConfigFile {
    if (-not $InstallWslConfig) {
        return
    }

    Write-Step 'Deploying WSL config template'
    Sync-File -Source $wslConfigSource -Destination $wslConfigDestination -Label 'WSL config'
    Sync-File -Source $wslConfSource -Destination $wslConfDestination -Label 'WSL distro config'
}

function Export-PowerToysSettings {
    if (-not $ExportPowerToys) {
        return
    }

    Write-Step 'Exporting PowerToys settings backup'
    Sync-PowerToysTree -SourceBase $powerToysSourceDir -DestinationBase $powerToysBackupDir -DirectionLabel 'export'
}

function Import-PowerToysSettings {
    if (-not $ImportPowerToys) {
        return
    }

    Write-Step 'Importing PowerToys settings backup'
    Sync-PowerToysTree -SourceBase $powerToysBackupDir -DestinationBase $powerToysSourceDir -DirectionLabel 'import'
}

function Restart-ExplorerIfRequested {
    if (-not $RestartExplorer) {
        return
    }

    if ($DryRun) {
        Write-Host '[dry-run] Restart-Process explorer.exe'
        return
    }

    Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Process explorer.exe
    Write-Action 'Restarted Explorer to apply shell changes'
}

Set-UserDefaults
Set-DeveloperDefaults
Install-WslConfigFile
Export-PowerToysSettings
Import-PowerToysSettings
Restart-ExplorerIfRequested

Write-Host ''
Write-Host 'Completed.' -ForegroundColor Green
Write-Host "Dry run: $DryRun"
Write-Host "Optional cleanup: $IncludeOptionalCleanup"
Write-Host "Install WSL config: $InstallWslConfig"
Write-Host "WSL distro config staging path: $wslConfDestination"
Write-Host "Export PowerToys: $ExportPowerToys"
Write-Host "Import PowerToys: $ImportPowerToys"
Write-Host "Restart Explorer: $RestartExplorer"
