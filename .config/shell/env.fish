set -Ux FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -Ux FZF_CTRL_T_COMMAND  $FZF_DEFAULT_COMMAND
set -Ux FZF_ALT_C_COMMAND   'fd --type d --hidden --follow --exclude .git'
set -Ux FZF_DEFAULT_OPTS '--height=40% --layout=reverse --info=inline --border --prompt="❯ "'
