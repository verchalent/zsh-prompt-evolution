# The `zsh-prompt` launcher: the `nix run` target.
#
# Points every tool at its store config by env var or flag, keeps state in
# two namespaced dirs, then execs the pinned zsh. The guest's ~/.zshrc and
# ~/.config are never read or written.
{
  lib,
  pkgs,
  config,
  ttt,
}:
let
  packages = pkgs.callPackage ./packages.nix { inherit config ttt; };
  plugins = pkgs.callPackage ./plugins.nix { };
  zdotdir = pkgs.callPackage ./zdotdir.nix { inherit config plugins; };

  # nix-direnv is enabled through direnvrc, so give direnv its own config dir.
  direnvConfig = pkgs.writeTextDir "direnvrc" ''
    source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
  '';
in
pkgs.writeShellApplication {
  name = "zsh-prompt";
  runtimeInputs = packages.core ++ packages.experience;
  text = ''
    if [[ "''${1:-}" == --no-zellij ]]; then
      export ZSH_PROMPT_NO_ZELLIJ=1
      shift
    fi

    ZSH_PROMPT_STATE="''${XDG_STATE_HOME:-$HOME/.local/state}/zsh-prompt"
    ZSH_PROMPT_CACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh-prompt"
    mkdir -p "$ZSH_PROMPT_STATE" "$ZSH_PROMPT_CACHE"
    export ZSH_PROMPT_STATE ZSH_PROMPT_CACHE

    export ZDOTDIR=${zdotdir}
    # zellij starts panes with $SHELL; make that this zsh, not the guest's.
    export SHELL=${lib.getExe pkgs.zsh}
    # macOS /etc/zshrc_Apple_Terminal would write sessions into the read-only ZDOTDIR.
    export SHELL_SESSIONS_DISABLE=1

    export STARSHIP_CONFIG=${config}/starship.toml
    export STARSHIP_CACHE="$ZSH_PROMPT_CACHE/starship"
    export ZELLIJ_CONFIG_FILE=${config}/zellij/config.kdl
    export ATUIN_CONFIG_DIR=${config}/atuin
    export ATUIN_DATA_DIR="$ZSH_PROMPT_STATE/atuin"
    export _ZO_DATA_DIR="$ZSH_PROMPT_STATE"
    export BAT_CONFIG_PATH=${config}/bat/config
    export DIRENV_CONFIG=${direnvConfig}

    exec ${lib.getExe pkgs.zsh} "$@"
  '';
}
