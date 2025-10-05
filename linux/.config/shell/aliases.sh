# --- eza replaces ls ---
if command -v eza >/dev/null; then
  alias ls='eza -al --group-directories-first --icons --time-style=long-iso'
  alias ll='eza -l --group-directories-first --icons --time-style=long-iso'
  alias la='eza -a --group-directories-first --icons'
  alias lt='eza -l --sort=modified --group-directories-first --icons'
  alias tree='eza --tree --level=2 --icons'
else
  alias ls='ls -al --group-directories-first --time-style=long-iso'
fi

# --- fd replaces find (common defaults) ---
if command -v fd >/dev/null; then
  alias fd='fd --hidden --follow --exclude .git'
fi

# --- ripgrep replaces grep ---
if command -v rg >/dev/null; then
  alias grep='rg'
  alias rga='rg --hidden --glob "!.git"'
fi

# --- bat replaces cat ---
if command -v batcat >/dev/null; then
  alias bat='batcat'
fi
if command -v bat >/div/null; then :; else
  alias bat='cat'
fi
alias cat='bat --paging=never'

# --- delta for git diffs ---
if command -v delta >/dev/null; then
  git config --global pager.diff delta
  git config --global pager.log delta
  git config --global pager.reflog delta
  git config --global interactive.diffFilter 'delta --color-only'
  git config --global delta.navigate true
  git config --global delta.line-numbers true
fi

# quality-of-life
alias hl='history | tail -200'
alias pls='sudo $(history -p !!)'
