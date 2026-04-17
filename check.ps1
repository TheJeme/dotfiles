[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$results = [System.Collections.Generic.List[object]]::new()

function Add-Result {
    param(
        [string]$Category,
        [string]$Name,
        [ValidateSet('ok', 'warn', 'missing', 'error')]
        [string]$Status,
        [string]$Detail
    )

    $results.Add([pscustomobject]@{
            Category = $Category
            Name     = $Name
            Status   = $Status
            Detail   = $Detail
        })
}

function Test-FilePath {
    param(
        [string]$Category,
        [string]$Name,
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path) {
        Add-Result -Category $Category -Name $Name -Status ok -Detail $Path
    }
    else {
        Add-Result -Category $Category -Name $Name -Status missing -Detail $Path
    }
}

function Test-CommandPath {
    param([string]$Name)

    $command = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $command) {
        Add-Result -Category 'Commands' -Name $Name -Status missing -Detail ''
        return
    }

    Add-Result -Category 'Commands' -Name $Name -Status ok -Detail $command.Source
}

function Test-JsonFile {
    param(
        [string]$Category,
        [string]$Name,
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        Add-Result -Category $Category -Name $Name -Status missing -Detail $Path
        return
    }

    try {
        Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json | Out-Null
        Add-Result -Category $Category -Name $Name -Status ok -Detail $Path
    }
    catch {
        Add-Result -Category $Category -Name $Name -Status error -Detail $_.Exception.Message
    }
}

function Test-GitConfig {
    $gitConfigPath = Join-Path $env:USERPROFILE '.gitconfig'
    $gitLocalConfigPath = Join-Path $env:USERPROFILE '.gitconfig.local'
    $gitIgnoreGlobalPath = Join-Path $env:USERPROFILE '.gitignore_global'

    Test-FilePath -Category 'Git' -Name 'Managed config' -Path $gitConfigPath
    Test-FilePath -Category 'Git' -Name 'Local overrides' -Path $gitLocalConfigPath
    Test-FilePath -Category 'Git' -Name 'Global ignore' -Path $gitIgnoreGlobalPath

    if (Test-Path -LiteralPath $gitConfigPath) {
        $gitConfigContent = Get-Content -LiteralPath $gitConfigPath -Raw

        if ($gitConfigContent -match '(?m)^\[include\]\s+path = ~/.gitconfig.local$') {
            Add-Result -Category 'Git' -Name 'Includes local overrides' -Status ok -Detail '~/.gitconfig.local'
        }
        else {
            Add-Result -Category 'Git' -Name 'Includes local overrides' -Status warn -Detail 'Managed .gitconfig does not include ~/.gitconfig.local'
        }

        try {
            $excludeFile = git config --global core.excludesfile 2>$null
            if ($excludeFile -eq '~/.gitignore_global') {
                Add-Result -Category 'Git' -Name 'core.excludesfile' -Status ok -Detail $excludeFile
            }
            else {
                Add-Result -Category 'Git' -Name 'core.excludesfile' -Status warn -Detail ($excludeFile | Out-String).Trim()
            }
        }
        catch {
            Add-Result -Category 'Git' -Name 'core.excludesfile' -Status error -Detail $_.Exception.Message
        }
    }
}

function Test-PowerShellProfile {
    $profilePath = $PROFILE.CurrentUserCurrentHost
    $profileDir = Split-Path -Parent $profilePath
    $moduleDir = Join-Path $profileDir 'profile.d'

    Test-FilePath -Category 'PowerShell' -Name 'Profile' -Path $profilePath
    Test-FilePath -Category 'PowerShell' -Name 'Module directory' -Path $moduleDir
    Test-FilePath -Category 'PowerShell' -Name 'Local profile example' -Path (Join-Path $profileDir 'Microsoft.PowerShell_profile.local.ps1.example')

    if (Test-Path -LiteralPath $moduleDir) {
        $expectedModules = @(
            '00-core.ps1'
            '10-prompt.ps1'
            '15-psreadline.ps1'
            '20-tools.ps1'
            '25-completions.ps1'
            '30-aliases.ps1'
            '35-utils.ps1'
            '40-git.ps1'
        )

        foreach ($module in $expectedModules) {
            Test-FilePath -Category 'PowerShell' -Name "Module $module" -Path (Join-Path $moduleDir $module)
        }
    }

    try {
        $script = @'
. $PROFILE.CurrentUserCurrentHost
"loaded"
Get-Command Edit-Profile, Reload-Profile, ff, fdh, fr, fp, frg, gst -ErrorAction Stop | Select-Object -ExpandProperty Name
'@
        $output = $script | pwsh -NoProfile -Command -
        if ($LASTEXITCODE -eq 0 -and $output -contains 'loaded') {
            Add-Result -Category 'PowerShell' -Name 'Profile load' -Status ok -Detail 'Profile loads in pwsh -NoProfile'
        }
        else {
            Add-Result -Category 'PowerShell' -Name 'Profile load' -Status error -Detail (($output | Out-String).Trim())
        }
    }
    catch {
        Add-Result -Category 'PowerShell' -Name 'Profile load' -Status error -Detail $_.Exception.Message
    }
}

function Test-AutoHotkeySetup {
    $startupLoader = Join-Path ([Environment]::GetFolderPath('Startup')) 'dotfiles.ahk'
    $moduleRoot = Join-Path $env:USERPROFILE 'Documents\AutoHotkey\dotfiles'

    Test-FilePath -Category 'AutoHotkey' -Name 'Startup loader' -Path $startupLoader
    Test-FilePath -Category 'AutoHotkey' -Name 'Module root' -Path $moduleRoot
    Test-FilePath -Category 'AutoHotkey' -Name 'Launchers module' -Path (Join-Path $moduleRoot 'modules\launchers.ahk')
    Test-FilePath -Category 'AutoHotkey' -Name 'Games module' -Path (Join-Path $moduleRoot 'games\wasd.ahk')
}

function Test-TerminalSetup {
    $stableSettings = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'

    Test-JsonFile -Category 'Terminal' -Name 'Stable settings JSON' -Path $stableSettings

    if (Test-Path -LiteralPath $stableSettings) {
        try {
            $settings = Get-Content -LiteralPath $stableSettings -Raw | ConvertFrom-Json
            $profileNames = @($settings.profiles.list | ForEach-Object { $_.name })
            foreach ($required in @('PowerShell', 'Ubuntu', 'Git Bash', 'Docker CLI')) {
                if ($profileNames -contains $required) {
                    Add-Result -Category 'Terminal' -Name "Profile $required" -Status ok -Detail $required
                }
                else {
                    Add-Result -Category 'Terminal' -Name "Profile $required" -Status warn -Detail 'Missing from terminal settings'
                }
            }
        }
        catch {
            Add-Result -Category 'Terminal' -Name 'Profile inspection' -Status error -Detail $_.Exception.Message
        }
    }
}

function Test-WslSetup {
    Test-FilePath -Category 'WSL' -Name '.wslconfig' -Path (Join-Path $env:USERPROFILE '.wslconfig')
    Test-FilePath -Category 'WSL' -Name 'staged wsl.conf' -Path (Join-Path $env:USERPROFILE 'Downloads\wsl.conf')
}

Test-PowerShellProfile
Test-GitConfig
Test-AutoHotkeySetup
Test-TerminalSetup
Test-WslSetup

foreach ($command in @('pwsh', 'git', 'starship', 'rg', 'fd', 'fzf', 'zoxide', 'winget', 'docker', 'kubectl')) {
    Test-CommandPath -Name $command
}

$orderedCategories = @('PowerShell', 'Git', 'AutoHotkey', 'Terminal', 'WSL', 'Commands')

foreach ($category in $orderedCategories) {
    Write-Host $category -ForegroundColor Cyan
    foreach ($result in $results | Where-Object Category -eq $category) {
        Write-Host ("[{0}] {1}: {2}" -f $result.Status, $result.Name, $result.Detail)
    }
    Write-Host ''
}

$summary = $results | Group-Object Status | Sort-Object Name
Write-Host 'Summary' -ForegroundColor Cyan
foreach ($item in $summary) {
    Write-Host ("{0}: {1}" -f $item.Name, $item.Count)
}

if ($results.Status -contains 'error') {
    exit 1
}
