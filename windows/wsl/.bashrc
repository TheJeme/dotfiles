# ~/.bashrc managed from dotfiles/windows/wsl/.bashrc

export EDITOR="${EDITOR:-code}"
export BAT_THEME="${BAT_THEME:-default}"

if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

if command -v fzf >/dev/null 2>&1 && [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.bash
fi

if command -v fzf >/dev/null 2>&1 && [[ -f /usr/share/doc/fzf/examples/completion.bash ]]; then
  source /usr/share/doc/fzf/examples/completion.bash
fi

if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='eza -la'
  alias la='eza -a'
fi

if command -v batcat >/dev/null 2>&1; then
  alias cat='batcat'
fi

if command -v fd-find >/dev/null 2>&1; then
  alias fd='fdfind'
fi

alias grep='rg'
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe -NoProfile -Command Get-Clipboard'
alias open='explorer.exe .'
alias croot='cd "$(git rev-parse --show-toplevel 2>/dev/null)"'

ff() {
  local query="${1:-}"
  command -v fzf >/dev/null 2>&1 || { echo "fzf is not installed" >&2; return 1; }

  local selection
  if command -v fd >/dev/null 2>&1; then
    selection="$(fd --type file --hidden --follow --exclude .git "$query" | fzf)"
  else
    selection="$(find . -type f 2>/dev/null | fzf --query="$query")"
  fi

  [[ -n "$selection" ]] || return 0

  if command -v code >/dev/null 2>&1; then
    code "$selection"
  else
    printf '%s\n' "$selection"
  fi
}

fdh() {
  local query="${1:-}"
  command -v fzf >/dev/null 2>&1 || { echo "fzf is not installed" >&2; return 1; }

  local selection
  if command -v fd >/dev/null 2>&1; then
    selection="$(fd --type directory --hidden --follow --exclude .git "$query" | fzf)"
  else
    selection="$(find . -type d 2>/dev/null | fzf --query="$query")"
  fi

  [[ -n "$selection" ]] || return 0
  cd "$selection"
}
