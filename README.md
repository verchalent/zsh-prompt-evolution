# zsh-prompt-evolution

A portable shell experience as a Nix flake. One command drops any machine with
Nix into the same zsh setup: starship prompt, plugins, zellij, colours, helix,
[ttt](https://github.com/eugenioenko/ttt) and a set of modern CLI tools —
without touching that machine's own dotfiles.

## Usage

```sh
nix run github:<owner>/zsh-prompt-evolution              # starts inside zellij
nix run github:<owner>/zsh-prompt-evolution -- --no-zellij
nix run .                                                # from a checkout
```

Requires Nix with flakes enabled. Fonts and window colours come from the
terminal you type in; the prompt icons need a
[Nerd Font](https://www.nerdfonts.com/).

## What you get

| Area | Contents |
|---|---|
| Shell | zsh, starship (powerlevel10k "lean" look), autosuggestions, syntax highlighting, you-should-use, oh-my-zsh `git` (+ `systemd` on Linux) |
| Multiplexer | zellij with Dracula theme, compact layout, custom keybinds; auto-starts, copies via OSC 52 |
| Editors | helix (`hx`, `vi`) with Dracula theme, ttt |
| Tools | lsd, bat, fd, ripgrep, fzf, zoxide, atuin (local only), direnv + nix-direnv, pay-respects, procs, duf, ncdu, fastfetch |
| Colours | `LS_COLORS` from Fedora's default `DIR_COLORS` |

Aliases: `ls`/`ll` → lsd, `cat` → bat, `find` → fd, `cd` → z, `ps` → procs,
`vi` → hx, `df` → duf, `du` → ncdu, `neofetch` → fastfetch.

## Leaves no trace

The guest's `~/.zshrc` and `~/.config` are never read or written; every tool is
pointed at its config in the Nix store. History, zoxide and atuin data, and
caches live in two directories:

```sh
rm -rf ~/.local/state/zsh-prompt ~/.cache/zsh-prompt   # full cleanup
```

atuin never syncs and makes no update checks.

## Layout

| Path | Contents |
|---|---|
| `config/` | Plain config files: starship, zsh, zellij, helix, atuin, bat, `DIR_COLORS` |
| `nix/wrapper.nix` | The `zsh-prompt` launcher (`nix run` target) |
| `nix/packages.nix` | Packages put on `PATH` |
| `nix/plugins.nix` | zsh plugins and load order |
| `nix/zdotdir.nix` | Read-only `ZDOTDIR` in the store |
| `nix/checks.nix` | `nix flake check` targets |

## Development

```sh
nix flake check   # zsh syntax, starship + zellij config, launcher smoke test
nix develop       # nixfmt, statix, deadnix, shellcheck, taplo
nix fmt
```

### Updating pins

`flake.lock` pins nixpkgs (`nixos-26.05`) and ttt. As a supply-chain
cooldown, only move an input to a revision at least 8 days old:

```sh
nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/<rev>
nix flake lock --override-input ttt github:eugenioenko/ttt/<rev>
```

## License

MIT
