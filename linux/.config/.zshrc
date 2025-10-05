# env first
[ -f ~/.config/shell/env.zsh ] && source ~/.config/shell/env.zsh

# plugins if you use them (optional)
# source /usr/share/fzf/key-bindings.zsh 2>/dev/null || true
# source /usr/share/fzf/completion.zsh 2>/dev/null || true

# zoxide & starship (if installed)
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"

# eza colors (optional)
export EZA_CONFIG_DIR="$HOME/.config/eza"
export EZA_COLORS="di=34:ex=32"   # keep simple; colors.yml augments

# aliases last
[ -f ~/.config/shell/aliases.sh ] && source ~/.config/shell/aliases.sh
