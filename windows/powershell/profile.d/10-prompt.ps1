if (Test-Command -Name 'starship') {
    Invoke-Expression (& starship init powershell)
}
