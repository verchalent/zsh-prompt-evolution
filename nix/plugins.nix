# Ordered list of zsh plugin files, all from nixpkgs (no runtime git clones).
# Host-specific oh-my-zsh plugins (1password, chezmoi, podman, dnf) are left out.
{
  lib,
  stdenv,
  oh-my-zsh,
  zsh-autosuggestions,
  zsh-syntax-highlighting,
  zsh-you-should-use,
}:
let
  omz = name: "${oh-my-zsh}/share/oh-my-zsh/plugins/${name}/${name}.plugin.zsh";
in
[
  "${zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  (omz "git")
]
++ lib.optional stdenv.hostPlatform.isLinux (omz "systemd")
++ [
  "${zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh"
  # must load last
  "${zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
]
