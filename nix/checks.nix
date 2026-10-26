# `nix flake check` targets: config syntax plus a launcher smoke test.
{
  pkgs,
  config,
  zsh-prompt,
}:
let
  # Fail when a command writes anything to stderr, not just on a bad exit code.
  quiet =
    name: script:
    pkgs.runCommand name { } ''
      export HOME=$TMPDIR TERM=xterm-256color
      ${script} 2> stderr
      if [ -s stderr ]; then
        cat stderr >&2
        exit 1
      fi
      touch $out
    '';
in
{
  zsh-syntax = quiet "zsh-syntax" ''
    for f in ${config}/zsh/*; do ${pkgs.zsh}/bin/zsh -n "$f"; done
  '';

  starship-config = quiet "starship-config" ''
    STARSHIP_CONFIG=${config}/starship.toml ${pkgs.starship}/bin/starship print-config > /dev/null
  '';

  zellij-config = quiet "zellij-config" ''
    ${pkgs.zellij}/bin/zellij --config ${config}/zellij/config.kdl setup --check > /dev/null
  '';

  # Interactive shell loads the full zshrc; zellij skipped since there is no tty.
  # Without a tty, zle-dependent inits warn "can't change option: zle"; ignore only that.
  smoke = quiet "zsh-prompt-smoke" ''
    test "$(${zsh-prompt}/bin/zsh-prompt --no-zellij -i -c 'echo ok' 2> smoke.err)" = ok
    grep -v "can't change option: zle" smoke.err >&2 || true
  '';
}
