# fzf keybindings + options, from the home ~/.zshrc.
# Loaded after atuin, as at home, so fzf owns Ctrl-R.

eval "$(fzf --zsh)"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND=""
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_ALT_C_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
