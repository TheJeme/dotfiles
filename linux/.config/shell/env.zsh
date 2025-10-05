# use fd for listings
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
# appearance
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --info=inline --border --prompt="❯ "'
