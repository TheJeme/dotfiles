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
$ids = @('AutoHotkey.AutoHotkey','sharkdp.fd','ajeetdsouza.zoxide','junegunn.fzf','Microsoft.PowerShell','7zip.7zip','Microsoft.PowerToys','Microsoft.WindowsTerminal','voidtools.Everything','File-New-Project.EarTrumpet','Starship.Starship','ShareX.ShareX','AntibodySoftware.WizTree','SumatraPDF.SumatraPDF','Mozilla.Firefox','Google.Chrome','Brave.Brave','Git.Git','GitHub.GitLFS','Microsoft.VisualStudioCode','Anysphere.Cursor','Neovim.Neovim','Docker.DockerDesktop','Kitware.CMake','OpenJS.NodeJS.LTS','pnpm.pnpm','Python.Python.3.12','Rustlang.Rust.MSVC','GoLang.Go','Inkscape.Inkscape','dotPDN.PaintDotNet','KDE.Krita','OBSProject.OBSStudio','mpv.net','SpeedCrunch.SpeedCrunch','Discord.Discord','WhatsApp.WhatsApp','CiderCollective.Cider','WinSCP.WinSCP','TheDocumentFoundation.LibreOffice','Tailscale.Tailscale','WireGuard.WireGuard','Rufus.Rufus','qBittorrent.qBittorrent','LocalSend.LocalSend','Valve.Steam','EpicGames.EpicGamesLauncher','NVIDIA.GeForceExperience'); winget source update; foreach ($id in $ids) { winget install -e --id $id --accept-source-agreements --accept-package-agreements }
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

## Set Git username and email

```
git config --global user.name "Eemeli Mark"
git config --global user.email "eemelijoonatan@gmail.com"
```

## Installed applications

- [AutoHotkey](https://www.autohotkey.com/)
- [PowerToys](https://docs.microsoft.com/powertoys/)
- [Terminal](https://aka.ms/terminal)
- [Everything](https://www.voidtools.com/)
- [EarTrumpet](https://eartrumpet.app/)
- [ShareX](https://getsharex.com/)
- [WizTree](https://diskanalyzer.com/)
- [SumatraPDF](https://www.sumatrapdfreader.org/free-pdf-reader.html)
- [Firefox](https://www.mozilla.org/en-US/firefox)
- [Chrome](https://www.google.com/intl/fi_fi/chrome/)
- [Brave](https://brave.com/)
- [Git](https://git-scm.com/)
- [Git LFS](https://git-lfs.com/)
- [VS Code](https://code.visualstudio.com)
- [Cursor](https://www.cursor.so/)
- [Neovim](https://neovim.io/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [CMake](https://cmake.org/)
- [Node.js](https://nodejs.org/)
- [pnpm](https://pnpm.io/)
- [Python](https://www.python.org/)
- [Rust](https://rust-lang.org/)
- [Go](https://go.dev/)
- [Inkscape](https://inkscape.org/)
- [Paint.NET](https://www.getpaint.net/)
- [Krita](https://krita.org/)
- [OBS Studio](https://obsproject.com/)
- [mpv](https://mpv.io/)
- [SpeedCrunch](https://speedcrunch.org/)
- [Discord](https://discord.com/)
- [Whatsapp](https://www.whatsapp.com/)
- [Cider](https://cider.sh/)
- [WinSCP](https://winscp.net/)
- [LibreOffice](https://www.libreoffice.org/)
- [Tailscale](https://tailscale.com/)
- [WireGuard](https://www.wireguard.com/)
- [Rufus](https://rufus.ie/)
- [qBittorrent](https://www.qbittorrent.org/)
- [LocalSend](https://localsend.org/)
- [Steam](https://store.steampowered.com)
- [Epic Games Launcher](https://www.epicgames.com/store/en-US/download)
- [Nvidia GeForce Experience](https://www.nvidia.com/geforce/geforce-experience/)