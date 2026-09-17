# Isolated test .zshrc — run with:  ZDOTDIR=$(pwd)/zdotdir zsh
# Does NOT touch ~/.zshrc, ~/.p10k.zsh, or the verchalent/dotfiles repo.
# Scope: prove antidote + starship reproduce the current oh-my-zsh + p10k
# prompt/plugin behavior. Unrelated tool inits (fzf, zoxide, atuin, pyenv, ...)
# from the real dot_zshrc are intentionally left out — they're untouched by
# this migration and stay as-is on cutover.

autoload -Uz compinit
compinit -d "${ZDOTDIR}/.zcompdump"

# Some ohmyzsh plugins (chezmoi, podman) expect omz's $ZSH_CACHE_DIR global to
# write generated completions into. We load them standalone via antidote (no
# full oh-my-zsh.sh), so it's never set otherwise — falls back to a bogus
# root-level path and corrupts the shell on load without this.
export ZSH_CACHE_DIR="${ZDOTDIR}/.cache"
mkdir -p "$ZSH_CACHE_DIR/completions"

# Prefer a package-manager install (brew on both amatarsu/linuxbrew and Mac/nix
# eventually land here too) — matches the "nix/brew install binaries, repo owns
# config" split. Falls back to a repo-local clone if antidote isn't installed yet.
if [[ -n "$(brew --prefix antidote 2>/dev/null)" ]]; then
  source "$(brew --prefix antidote)/share/antidote/antidote.zsh"
else
  ANTIDOTE_HOME="${ZDOTDIR}/.antidote"
  [[ -d $ANTIDOTE_HOME ]] || git clone --quiet --depth 1 https://github.com/getantidote/antidote.git "$ANTIDOTE_HOME"
  source "$ANTIDOTE_HOME/antidote.zsh"
fi
antidote load "${ZDOTDIR}/.zsh_plugins.txt"

# was ENABLE_CORRECTION="true" under oh-my-zsh
setopt correct

export STARSHIP_CONFIG="${ZDOTDIR}/starship.toml"
eval "$(starship init zsh)"

# Carried over from the real dot_zshrc for visual side-by-side fidelity only
# (these aliases are untouched by this migration either way — lsd's icons are
# what make `ls` look iconified/colored today, nothing to do with p10k/omz).
alias ls='lsd'
alias ll='lsd -l'
alias cat='bat'
alias find='fd'
