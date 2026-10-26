# Read-only ZDOTDIR in the store. Its .zshrc only wires store paths into
# variables, then hands off to the plain config/zsh/zshrc.
{
  lib,
  runCommand,
  coreutils,
  config,
  plugins,
}:
runCommand "zsh-prompt-zdotdir" { } ''
  mkdir -p $out
  cat > $out/.zshrc <<'EOF'
  ZSH_PROMPT_CONFIG=${config}
  ZSH_PROMPT_DIRCOLORS=${coreutils}/bin/dircolors
  ZSH_PROMPT_PLUGINS=(${lib.escapeShellArgs plugins})
  source "$ZSH_PROMPT_CONFIG/zsh/zshrc"
  EOF
''
