function Set-SmartAlias {
    param(
        [Parameter(Mandatory)][string]$Alias,
        [Parameter(Mandatory)][string]$Command
    )

    if (Test-Command -Name $Command) {
        Set-Alias -Name $Alias -Value $Command
    }
}

Set-SmartAlias -Alias ls -Command eza
Set-SmartAlias -Alias cat -Command bat
Set-SmartAlias -Alias find -Command fd
Set-SmartAlias -Alias grep -Command rg
Set-SmartAlias -Alias vim -Command nvim
Set-SmartAlias -Alias g -Command git

function ll {
    if (Test-Command -Name 'eza') {
        eza -la
        return
    }

    Get-ChildItem -Force
}

function la {
    if (Test-Command -Name 'eza') {
        eza -a
        return
    }

    Get-ChildItem -Force
}

function .. { Set-Location .. }
function ... { Set-Location ../.. }
