#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/dotfiles}"
WSL_DIR="$DOTFILES_ROOT/windows/wsl"
PACKAGES=(
  build-essential
  curl
  unzip
  zip
  git
  ripgrep
  fd-find
  fzf
  zoxide
  bat
  jq
  make
)

log() {
  printf '==> %s\n' "$1"
}

ensure_file() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"
  cp "$source" "$target"
}

install_packages() {
  log "Installing Ubuntu packages"
  sudo apt update
  sudo apt install -y "${PACKAGES[@]}"
}

deploy_shell_files() {
  log "Deploying shell and Git config"
  ensure_file "$WSL_DIR/.bashrc" "$HOME/.bashrc"
  ensure_file "$WSL_DIR/.gitconfig-linux" "$HOME/.gitconfig-linux"
}

main() {
  if [[ ! -d "$WSL_DIR" ]]; then
    printf 'Expected WSL config directory at %s\n' "$WSL_DIR" >&2
    exit 1
  fi

  install_packages
  deploy_shell_files

  log "Completed"
}

main "$@"
