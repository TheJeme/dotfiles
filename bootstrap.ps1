[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$InstallPackages,
    [switch]$InstallFonts,
    [switch]$IncludeOptionalCleanup,
    [switch]$InstallWslConfig
)

$ErrorActionPreference = 'Stop'

function Invoke-Step {
    param(
        [string]$Name,
        [scriptblock]$Action
    )

    Write-Host "==> $Name" -ForegroundColor Cyan
    & $Action
}

Invoke-Step -Name 'Configure Git' -Action {
    & (Join-Path $PSScriptRoot 'windows\configure-git.ps1') -DryRun:$DryRun
}

Invoke-Step -Name 'Deploy dotfiles' -Action {
    & (Join-Path $PSScriptRoot 'windows\install.ps1') -DryRun:$DryRun
}

Invoke-Step -Name 'Configure Windows' -Action {
    & (Join-Path $PSScriptRoot 'windows\configure-windows.ps1') -DryRun:$DryRun -IncludeOptionalCleanup:$IncludeOptionalCleanup -InstallWslConfig:$InstallWslConfig
}

if ($InstallPackages) {
    Invoke-Step -Name 'Install packages' -Action {
        & (Join-Path $PSScriptRoot 'windows\install-packages.ps1') -DryRun:$DryRun -InstallFonts:$InstallFonts
    }
}
