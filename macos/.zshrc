# ~/.zshrc

# Set up the prompt with Starship
eval "$(starship init zsh)"

# Enable zoxide (if installed)
eval "$(zoxide init zsh)"

# Enable fzf keybindings
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Enable auto-completion
autoload -U compinit && compinit

# Set up custom aliases
alias ll='eza -l --color=auto'  # Use eza instead of ls
alias grep='grep --color=auto'   # Enable color in grep

# Enable auto-cd for directories
setopt auto_cd

# Set history settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Customize the history search behavior
bindkey '^R' history-incremental-search-backward

# Set default editor to nvim
export EDITOR="nvim"

# Disable the annoying 'Press any key to continue' prompt
DISABLE_AUTO_TITLE="true"