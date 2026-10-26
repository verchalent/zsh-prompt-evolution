# Everything the portable shell puts on PATH.
{
  lib,
  pkgs,
  config,
  ttt,
}:
let
  # helix only takes its config by flag, so wrap it to read the store copy
  # instead of the guest's ~/.config/helix.
  hx = pkgs.writeShellScriptBin "hx" ''
    exec ${lib.getExe pkgs.helix} -c ${config}/helix/config.toml "$@"
  '';

  # atuin reads ATUIN_CONFIG_DIR but still creates an empty
  # $XDG_CONFIG_HOME/atuin; send that into the state dir instead of the guest's ~.
  atuin = pkgs.writeShellScriptBin "atuin" ''
    XDG_CONFIG_HOME="$ZSH_PROMPT_STATE/atuin/xdg-config" exec ${lib.getExe pkgs.atuin} "$@"
  '';
in
{
  core = with pkgs; [
    zsh
    starship
    git
  ];

  experience = [
    hx
    atuin
    ttt
  ]
  ++ (with pkgs; [
    zellij
    ripgrep # ttt workspace search
    lsd
    bat
    fd
    fzf
    zoxide
    direnv
    pay-respects
    procs
    duf
    ncdu
    fastfetch
  ]);
}
