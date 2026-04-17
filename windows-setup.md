# Windows setup

## Deploy dotfiles

```powershell
pwsh -ExecutionPolicy Bypass -File .\windows\install.ps1
```

This deploys the repo's Windows files to the user-scoped paths for a modular PowerShell profile, an AutoHotkey startup loader plus module files, and Windows Terminal. `tetrio-config.ttc` is copied to `%USERPROFILE%\Downloads\` for manual import.

## Configure Git

```powershell
pwsh -ExecutionPolicy Bypass -File .\windows\configure-git.ps1
```

This installs a managed `%USERPROFILE%\.gitconfig`, points Git at `%USERPROFILE%\.gitignore_global`, and writes `%USERPROFILE%\.gitconfig.local` with your current `user.name`, `user.email`, and `core.editor` so personal values stay local.

## Configure Windows defaults

```powershell
pwsh -ExecutionPolicy Bypass -File .\windows\configure-windows.ps1 -InstallWslConfig
```

This applies Explorer defaults, taskbar/search cleanup, developer defaults such as execution policy and long paths, optional consumer-noise reduction, and can import or export PowerToys settings backups.

When `-InstallWslConfig` is used, it deploys `%USERPROFILE%\.wslconfig` and stages `wsl.conf` to `%USERPROFILE%\Downloads\wsl.conf` for manual copy into `/etc/wsl.conf` inside the distro.

## Install packages

```powershell
pwsh -ExecutionPolicy Bypass -File .\windows\install-packages.ps1
```

Package groups live in `windows/packages.psd1`.

## Update applications

```
pwsh -ExecutionPolicy Bypass -File .\windows\update-packages.ps1
```

## Bootstrap everything

```powershell
pwsh -ExecutionPolicy Bypass -File .\bootstrap.ps1 -InstallWslConfig
```

## Check setup

```powershell
pwsh -ExecutionPolicy Bypass -File .\check.ps1
```

## Ubuntu on WSL

After cloning this repo inside Ubuntu, run:

```bash
~/dotfiles/windows/wsl/bootstrap-ubuntu.sh
```

This installs a lightweight CLI tool baseline and deploys managed `.bashrc` and Linux-side Git defaults.

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
