# MacOS setup

## Install Xcode Command Line Tools

```sh
xcode-select --install
```

## Install Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade
brew doctor
```

## Show hidden files in Finder

```sh
defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder
```

## Enable keyrepeat

```sh
defaults write -g ApplePressAndHoldEnabled -bool false
```

# Faster key repeat

```sh
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10
```

## Prevent .DS_STORE on network/USB volumes

```sh
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
```

## Scroll direction natural

```sh
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
```

## Install CLI applications

```sh
brew install \
    git \
    git-lfs \
    wget \
    curl \
    neovim \
    starship \
    zoxide \
    fzf \
    fd \
    ripgrep \
    bat \
    eza \
    lazygit \
    gh \
    python@3.12 \
    go \
    rustup-init \
    node \
    pnpm \
    cmake \
    ninja \
    htop \
    httpie \
    tldr \
    imagemagick \
    neofetch \
    mas
```

## Install GUI applications

```sh
brew install --cask \
    visual-studio-code \
    cursor \
    iterm2 \
    docker \
    postman \
    tableplus \
    stats \
    alt-tab \
    raycast \
    rectangle \
    kap \
    the-unarchiver \
    discord \
    google-chrome \
    steam \
    inkscape \
    tailscale \
    protonvpn
```

## Install nerd fonts

```sh
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font font-fira-code-nerd-font font-cascadia-code-nerd-font
```

## Install Xcode

```sh
mas install 497799835
```

## Set Git username and email

```sh
git config --global user.name "Eemeli Mark"
git config --global user.email "eemelijoonatan@gmail.com"
```

## Cleanup

```sh
brew cleanup
brew doctor
softwareupdate --all --install --force
```