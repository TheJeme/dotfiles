if (Test-Command -Name 'zoxide') {
    Invoke-Expression (& { zoxide init powershell | Out-String })
}

if (Test-Command -Name 'direnv') {
    try {
        Invoke-Expression (& direnv hook pwsh)
    }
    catch {
    }
}
