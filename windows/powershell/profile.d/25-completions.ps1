function Register-NativeCompletion {
    param(
        [Parameter(Mandatory)][string]$CommandName,
        [Parameter(Mandatory)][scriptblock]$ScriptBlock
    )

    if (-not (Test-Command -Name $CommandName)) {
        return
    }

    Register-ArgumentCompleter -Native -CommandName $CommandName -ScriptBlock $ScriptBlock
}

function Invoke-CompletionScript {
    param([Parameter(Mandatory)][scriptblock]$ScriptBlock)

    try {
        $script = & $ScriptBlock
        if (-not [string]::IsNullOrWhiteSpace($script)) {
            Invoke-Expression $script
        }
    }
    catch {
    }
}

Register-NativeCompletion -CommandName 'dotnet' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    dotnet complete --position $cursorPosition $commandAst.ToString() 2>$null |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

if (Test-Command -Name 'pnpm') {
    Invoke-CompletionScript { pnpm completion pwsh }
}

if (Test-Command -Name 'npm') {
    Register-NativeCompletion -CommandName 'npm' -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        npm help 2>$null |
            ForEach-Object {
                if ($_ -match '^\s+([a-z][a-z0-9:-]+)\s') {
                    $name = $matches[1]
                    if ([string]::IsNullOrWhiteSpace($wordToComplete) -or $name -like "$wordToComplete*") {
                        [System.Management.Automation.CompletionResult]::new($name, $name, 'ParameterValue', $name)
                    }
                }
            }
    }
}

if (Test-Command -Name 'kubectl') {
    Invoke-CompletionScript { kubectl completion powershell }
}

Register-NativeCompletion -CommandName 'cargo' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    cargo --list 2>$null |
        Select-Object -Skip 1 |
        ForEach-Object {
            if ($_ -match '^\s*([a-zA-Z0-9:_-]+)\s{2,}') {
                $name = $matches[1]
                if ([string]::IsNullOrWhiteSpace($wordToComplete) -or $name -like "$wordToComplete*") {
                    [System.Management.Automation.CompletionResult]::new($name, $name, 'ParameterValue', $name)
                }
            }
        }
}

if (Test-Command -Name 'uv') {
    Invoke-CompletionScript { uv generate-shell-completion powershell }
}

if (Test-Command -Name 'just') {
    Invoke-CompletionScript { just --completions powershell }
}

if (Test-Command -Name 'go') {
    Register-NativeCompletion -CommandName 'go' -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        go help 2>$null |
            ForEach-Object {
                if ($_ -match '^\s{4}([a-z][a-z0-9]+)\s') {
                    $name = $matches[1]
                    if ([string]::IsNullOrWhiteSpace($wordToComplete) -or $name -like "$wordToComplete*") {
                        [System.Management.Automation.CompletionResult]::new($name, $name, 'ParameterValue', $name)
                    }
                }
            }
    }
}

if (Test-Command -Name 'docker') {
    Register-NativeCompletion -CommandName 'docker' -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        docker --help 2>$null |
            ForEach-Object {
                if ($_ -match '^\s{2}([a-z][a-z0-9]+)\s') {
                    $name = $matches[1]
                    if ([string]::IsNullOrWhiteSpace($wordToComplete) -or $name -like "$wordToComplete*") {
                        [System.Management.Automation.CompletionResult]::new($name, $name, 'ParameterValue', $name)
                    }
                }
            }
    }
}

if (Test-Command -Name 'winget') {
    Register-NativeCompletion -CommandName 'winget' -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        @('search', 'show', 'install', 'upgrade', 'uninstall', 'list', 'source', 'settings', 'configure', 'download', 'export', 'import') |
            Where-Object { [string]::IsNullOrWhiteSpace($wordToComplete) -or $_ -like "$wordToComplete*" } |
            ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
    }
}

if (Test-Command -Name 'gh') {
    Invoke-CompletionScript { gh completion -s powershell }
}

if (Test-Command -Name 'chezmoi') {
    Invoke-CompletionScript { chezmoi completion powershell }
}
