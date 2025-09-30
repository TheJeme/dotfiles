# Starship prompt
Invoke-Expression (& starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView -BellStyle None