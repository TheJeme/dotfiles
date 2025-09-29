# fzf keybindings (if package provides)
status is-interactive; and test -f /usr/share/fzf/key-bindings.fish; and source /usr/share/fzf/key-bindings.fish

# zoxide & starship (if installed)
type -q zoxide; and zoxide init fish | source
type -q starship; and starship init fish | source

# eza colors env
set -Ux EZA_CONFIG_DIR "$HOME/.config/eza"
set -Ux EZA_COLORS "di=34:ex=32"

# aliases
test -f ~/.config/shell/aliases.sh; and bass source ~/.config/shell/aliases.sh
