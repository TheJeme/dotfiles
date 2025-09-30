# Starship prompt
Invoke-Expression (& starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })
if (Get-Command eza -ea SilentlyContinue) { Set-Alias ls eza }
if (Get-Command fd  -ea SilentlyContinue) { Set-Alias find fd }
if (Get-Command rg  -ea SilentlyContinue) { Set-Alias grep rg }