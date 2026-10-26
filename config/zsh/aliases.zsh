# Command aliases from the home ~/.zshrc, minus host-specific ones
# (brew, docker=podman, xdg-open, sudo bandwhich).

alias cat=bat
alias cd=z
alias find=fd
alias ll='lsd -l'
alias ls='lsd'
alias ps=procs
alias vi=hx
alias df=duf
alias du='ncdu --group-directories-first --color dark'
alias neofetch=fastfetch

# Remote hosts often lack terminfo for these terminals.
case "$TERM" in
  alacritty|xterm-ghostty)
    alias ssh="TERM=xterm-256color ssh"
    ;;
esac
