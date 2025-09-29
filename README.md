# dotfiles

## openSUSE setup
### Update
sudo zypper refresh && sudo zypper dup -y

### PipeWire audio stack + session manager
sudo zypper in -y pipewire pipewire-alsa pipewire-pulseaudio pipewire-jack wireplumber

### Wayland portals for screen sharing (Discord, browsers, etc.)
sudo zypper in -y xdg-desktop-portal xdg-desktop-portal-wlr

### Screenshots / screen capture tools
sudo zypper in -y grim slurp wf-recorder swappy wl-clipboard

### Notifications, clipboard, power/lock, media controls
sudo zypper in -y mako cliphist brightnessctl playerctl

### App launcher & bars (nice defaults)
sudo zypper in -y wofi waybar swayidle swaylock-effects wlogout

# Fonts (developer-friendly + symbols)
sudo zypper in -y noto-fonts noto-fonts-cjk noto-fonts-emoji fira-code-fonts nerd-fonts


## Installed applications
- Neovim
- LazyGit
- LazyDocker
- VS Code
- Steam
- 
