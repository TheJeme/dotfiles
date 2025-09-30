# Windows setup

## Update winget sources
```
winget source update
```

## Enable WSL2 and install Ubuntu
```sh
wsl --install -d Ubuntu
```

## Enable dev mode and long paths
```sh
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /v "AllowDevelopmentWithoutDevLicense" /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /t REG_DWORD /v LongPathsEnabled /d 1 /f
```

## Install applications
```sh
$ids = @('AutoHotkey.AutoHotkey','Microsoft.PowerShell','7zip.7zip','Microsoft.PowerToys','Microsoft.WindowsTerminal','voidtools.Everything','File-New-Project.EarTrumpet','Starship.Starship','ShareX.ShareX','AntibodySoftware.WizTree','SumatraPDF.SumatraPDF','Mozilla.Firefox','Google.Chrome','Brave.Brave','Git.Git','GitHub.GitLFS','Microsoft.VisualStudioCode','Anysphere.Cursor','Neovim.Neovim','Docker.DockerDesktop','Kitware.CMake','OpenJS.NodeJS.LTS','pnpm.pnpm','Python.Python.3.12','Rustlang.Rust.MSVC','GoLang.Go','Inkscape.Inkscape','dotPDN.PaintDotNet','KDE.Krita','OBSProject.OBSStudio','mpv.net','SpeedCrunch.SpeedCrunch','Discord.Discord','WhatsApp.WhatsApp','CiderCollective.Cider','WinSCP.WinSCP','TheDocumentFoundation.LibreOffice','Tailscale.Tailscale','WireGuard.WireGuard','Rufus.Rufus','qBittorrent.qBittorrent','LocalSend.LocalSend','Valve.Steam','EpicGames.EpicGamesLauncher','NVIDIA.GeForceExperience'); winget source update; foreach ($id in $ids) { winget install -e --id $id --accept-source-agreements --accept-package-agreements }
```

## Update applications
```sh
winget source update
winget upgrade --all --accept-source-agreements --accept-package-agreements
```

## Install Scoop
```sh
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
iwr -useb get.scoop.sh | iex
```

## Install fonts
```sh
scoop bucket add nerd-fonts
scoop install JetBrainsMono-NF CascadiaCode-NF FiraCode-NF
```

## Installed applications
- [AutoHotkey]()
- [PowerToys]()
- [Terminal]()
- [Everything]()
- [EarTrumpet]()
- [ShareX]()
- [WizTree]()
- [SumatraPDF]()
- [Firefox](https://www.mozilla.org/en-US/firefox)
- [Chrome](https://www.google.com/intl/fi_fi/chrome/)
- [Brave]()
- [Git]()
- [Git LFS]()
- [VS Code](https://code.visualstudio.com)
- [Cursor]()
- [Neovim](https://neovim.io/)
- [Docker Desktop]()
- [CMake]()
- [Node.js]()
- [pnpm]()
- [Python]()
- [Rust]()
- [Go]()
- [Inkscape](https://inkscape.org/)
- [Paint.NET](https://www.getpaint.net/)
- [Krita]()
- [OBS Studio]()
- [mpv](https://mpv.io/)
- [SpeedCrunch]()
- [Discord]()
- [Whatsapp](https://www.whatsapp.com/)
- [Cider]()
- [WinSCP]()
- [LibreOffice]()
- [Tailscale]()
- [WireGuard]()
- [Rufus]()
- [qBittorrent]()
- [LocalSend]()
- [Steam](https://store.steampowered.com)
- [Epic Games Launcher]()
- [Nvidia GeForce Experience](https://www.nvidia.com/geforce/geforce-experience/)


