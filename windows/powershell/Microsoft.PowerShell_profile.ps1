$profileRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleRoot = Join-Path $profileRoot 'profile.d'

if (Test-Path -LiteralPath $moduleRoot) {
    Get-ChildItem -LiteralPath $moduleRoot -Filter '*.ps1' | Sort-Object Name | ForEach-Object {
        . $_.FullName
    }
}

$localProfile = Join-Path $profileRoot 'Microsoft.PowerShell_profile.local.ps1'
if (Test-Path -LiteralPath $localProfile) {
    . $localProfile
}
