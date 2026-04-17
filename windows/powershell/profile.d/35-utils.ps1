function Edit-Profile {
    $profilePath = $PROFILE.CurrentUserCurrentHost

    if (Test-Command -Name 'code') {
        code $profilePath
        return
    }

    if (Test-Command -Name 'notepad') {
        notepad $profilePath
        return
    }

    Write-Host $profilePath
}

function Reload-Profile {
    . $PROFILE.CurrentUserCurrentHost
}

function which {
    param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]]$Name)

    foreach ($item in $Name) {
        Get-Command $item -ErrorAction SilentlyContinue
    }
}

function touch {
    param([Parameter(Mandatory)][string[]]$Path)

    foreach ($item in $Path) {
        if (Test-Path -LiteralPath $item) {
            (Get-Item -LiteralPath $item).LastWriteTime = Get-Date
        }
        else {
            New-Item -ItemType File -Path $item | Out-Null
        }
    }
}

function mkcd {
    param([Parameter(Mandatory)][string]$Path)

    $directory = New-Item -ItemType Directory -Path $Path -Force
    Set-Location $directory.FullName
}

function Get-RepoRoot {
    param([string]$Path = (Get-Location).Path)

    if (-not (Test-Command -Name 'git')) {
        return $null
    }

    $root = git -C $Path rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($root)) {
        return $null
    }

    return $root.Trim()
}

function Get-ProjectRoots {
    $localRoots = @()

    if (-not [string]::IsNullOrWhiteSpace($env:DOTFILES_PROJECT_ROOTS)) {
        $localRoots = $env:DOTFILES_PROJECT_ROOTS.Split(';') | ForEach-Object { $_.Trim() }
    }

    $candidates = @(
        $env:USERPROFILE
        'D:\others'
        'D:\work'
    ) + $localRoots | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and (Test-Path -LiteralPath $_) }

    return $candidates | Select-Object -Unique
}

function Find-Files {
    param([string]$Query = '')

    if (Test-Command -Name 'fd') {
        $args = @('--type', 'file', '--hidden', '--follow', '--exclude', '.git')
        if (-not [string]::IsNullOrWhiteSpace($Query)) {
            $args += $Query
        }

        & fd @args 2>$null
        return
    }

    Get-ChildItem -Path . -Recurse -File -ErrorAction SilentlyContinue |
        ForEach-Object { $_.FullName }
}

function Search-Content {
    param([Parameter(Mandatory)][string]$Pattern)

    if (Test-Command -Name 'rg') {
        rg --line-number --column --smart-case $Pattern
        return
    }

    Get-ChildItem -Path . -Recurse -File -ErrorAction SilentlyContinue |
        Select-String -Pattern $Pattern
}

function Find-Directories {
    param([string]$Query = '')

    if (Test-Command -Name 'fd') {
        $args = @('--type', 'directory', '--hidden', '--follow', '--exclude', '.git')
        if (-not [string]::IsNullOrWhiteSpace($Query)) {
            $args += $Query
        }

        & fd @args 2>$null
        return
    }

    Get-ChildItem -Path . -Recurse -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { $_.FullName }
}

function croot {
    $root = Get-RepoRoot
    if ($null -eq $root) {
        Write-Error 'Not inside a Git repository.'
        return
    }

    Set-Location $root
}

function ff {
    param([string]$Query = '')

    if (-not (Test-Command -Name 'fzf')) {
        Write-Error 'fzf is not installed.'
        return
    }

    $files = Find-Files -Query $Query
    $selection = $files | fzf --query=$Query --preview 'if (Get-Command bat -ErrorAction SilentlyContinue) { bat --style=numbers --color=always --line-range=:200 {} } else { Get-Content {} -TotalCount 200 }'

    if (-not [string]::IsNullOrWhiteSpace($selection)) {
        if (-not [System.IO.Path]::IsPathRooted($selection)) {
            $selection = Join-Path (Get-Location) $selection
        }

        if (Test-Command -Name 'code') {
            code $selection
        }
        else {
            Write-Host $selection
        }
    }
}

function frg {
    param([Parameter(Mandatory)][string]$Pattern)

    if (-not (Test-Command -Name 'fzf')) {
        Write-Error 'fzf is not installed.'
        return
    }

    if (-not (Test-Command -Name 'rg')) {
        Write-Error 'rg is not installed.'
        return
    }

    $selection = rg --line-number --column --smart-case --color=always $Pattern 2>$null |
        fzf --ansi --delimiter ':' --preview 'if (Get-Command bat -ErrorAction SilentlyContinue) { $parts = "{}" -split ":"; bat --style=numbers --color=always --highlight-line $parts[1] $parts[0] }'

    if (-not [string]::IsNullOrWhiteSpace($selection)) {
        $parts = $selection -split ':', 4
        if ($parts.Length -ge 2) {
            $path = $parts[0]
            $line = $parts[1]

            if (Test-Command -Name 'code') {
                code --goto "${path}:${line}"
            }
            else {
                Write-Host "${path}:${line}"
            }
        }
    }
}

function fdh {
    param([string]$Query = '')

    if (-not (Test-Command -Name 'fzf')) {
        Write-Error 'fzf is not installed.'
        return
    }

    $directories = Find-Directories -Query $Query
    $selection = $directories | fzf --query=$Query
    if (-not [string]::IsNullOrWhiteSpace($selection)) {
        if (-not [System.IO.Path]::IsPathRooted($selection)) {
            $selection = Join-Path (Get-Location) $selection
        }

        Set-Location $selection
    }
}

function fr {
    param([string]$Query = '')

    if (-not (Test-Command -Name 'fzf')) {
        Write-Error 'fzf is not installed.'
        return
    }

    $roots = Get-ProjectRoots

    $selection = $roots | fzf --query=$Query
    if (-not [string]::IsNullOrWhiteSpace($selection)) {
        Set-Location $selection
    }
}

function fp {
    param([string]$Query = '')

    if (-not (Test-Command -Name 'fzf')) {
        Write-Error 'fzf is not installed.'
        return
    }

    $projects = foreach ($root in Get-ProjectRoots) {
        if (Test-Command -Name 'fd') {
            & fd --max-depth 3 --hidden --follow --type directory --exclude .git . $root 2>$null |
                ForEach-Object {
                    if (Test-Path -LiteralPath (Join-Path $root $_ '.git')) {
                        Join-Path $root $_
                    }
                }
        }
        else {
            Get-ChildItem -Path $root -Directory -Recurse -Depth 3 -ErrorAction SilentlyContinue |
                Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName '.git') } |
                ForEach-Object { $_.FullName }
        }
    }

    $selection = $projects | Select-Object -Unique | Sort-Object | fzf --query=$Query
    if (-not [string]::IsNullOrWhiteSpace($selection)) {
        Set-Location $selection
    }
}

function fz {
    param([string]$Query = '')

    if (Test-Command -Name 'zoxide') {
        zoxide query --interactive $Query
        return
    }

    fdh -Query $Query
}

function dev {
    fp
}

function work {
    $path = 'D:\work'
    if (Test-Path -LiteralPath $path) {
        Set-Location $path
        return
    }

    fp -Query 'work'
}

function others {
    $path = 'D:\others'
    if (Test-Path -LiteralPath $path) {
        Set-Location $path
    }
}

function home {
    Set-Location $env:USERPROFILE
}

function dotfiles {
    $path = Join-Path (Get-ProjectRoots | Where-Object { $_ -eq 'D:\others' } | Select-Object -First 1) 'dotfiles'
    if (Test-Path -LiteralPath $path) {
        Set-Location $path
    }
}

function downloads {
    Set-Location (Join-Path $env:USERPROFILE 'Downloads')
}

function notes {
    $candidates = @(
        (Join-Path $env:USERPROFILE 'Documents\notes')
        (Join-Path $env:USERPROFILE 'Documents\Notes')
        'D:\others\notes'
    )

    $path = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if ($null -ne $path) {
        Set-Location $path
    }
}

function fbr {
    if (-not (Test-Command -Name 'git')) {
        Write-Error 'git is not installed.'
        return
    }

    if (-not (Test-Command -Name 'fzf')) {
        Write-Error 'fzf is not installed.'
        return
    }

    $branches = git for-each-ref --sort=-committerdate refs/heads refs/remotes --format='%(refname:short)' 2>$null
    $selection = $branches | Select-Object -Unique | fzf

    if (-not [string]::IsNullOrWhiteSpace($selection)) {
        git checkout $selection
    }
}
