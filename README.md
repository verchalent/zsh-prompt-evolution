# zsh-prompt-evolution

Migrating amatarsu (Fedora) and a Macbook Air (nix) off oh-my-zsh +
powerlevel10k onto [antidote](https://github.com/getantidote/antidote) +
[starship](https://github.com/starship/starship), while keeping the prompt
look and feel as close to identical as possible. Full plan, decisions, and
rationale: [`roughplan.md`](roughplan.md) (symlink to the Obsidian vault note
that's the actual source of truth). Baseline capture, plugin mapping, and a
log of every bug found/fixed during testing: [`baseline-checklist.md`](baseline-checklist.md).

Live dotfiles (chezmoi source, both machines) for eventual cutover:
https://github.com/verchalent/dotfiles

## Why a repo instead of editing dotfiles directly

Test configs live here — not in `~` and not in the dotfiles repo — so
iteration is version-controlled and auditable before anything touches a real
system. Nothing here is applied to `~/.zshrc` or the dotfiles repo until
you've validated it and folded it in yourself (see "Cutover" below).

## What's in this repo

```
zdotdir/
  .zshrc            isolated test shell config (ZDOTDIR-scoped)
  starship.toml     prompt config, tuned for parity with the current p10k setup
  .zsh_plugins.txt  antidote plugin bundle (oh-my-zsh plugin equivalents)
baseline-checklist.md   baseline capture + parity checklist + bug log
roughplan.md            symlink to the actual plan/decisions doc (Obsidian vault)
```

`zdotdir/.antidote/`, `zdotdir/.cache/`, `zdotdir/.zsh_plugins.zsh`, and
`zdotdir/.zcompdump*` are runtime-generated (git-ignored) — antidote clones
plugins and caches completions into them on first run.

## Tools/plugins in use

Installed via linuxbrew on amatarsu (`brew install antidote starship`); same
binaries-only approach planned for the Mac via home-manager. Config for both
lives in this repo / the dotfiles repo, not in nix or brew.

| Tool | Role |
|---|---|
| [antidote](https://github.com/getantidote/antidote) | zsh plugin manager, replaces oh-my-zsh |
| [starship](https://github.com/starship/starship) | prompt, replaces powerlevel10k |

Antidote plugin bundle (`zdotdir/.zsh_plugins.txt`), mapped 1:1 from the
current oh-my-zsh plugin list — see `baseline-checklist.md` for the full
mapping table and rationale:

```
zsh-users/zsh-autosuggestions
ohmyzsh/ohmyzsh path:plugins/git
ohmyzsh/ohmyzsh path:plugins/1password
ohmyzsh/ohmyzsh path:plugins/chezmoi
ohmyzsh/ohmyzsh path:plugins/podman
ohmyzsh/ohmyzsh path:plugins/dnf
ohmyzsh/ohmyzsh path:plugins/systemd
MichaelAquilina/zsh-you-should-use
zsh-users/zsh-syntax-highlighting   # must load last
```

`starship.toml` reproduces the current p10k "lean" preset: os icon, directory,
git branch/status, prompt character on the left; exit status, command
duration, background jobs, direnv, nix_shell, time on the right. Nerd-font
icon codepoints are pulled from p10k's own `internal/icons.zsh` (not a
generic Nerd Font icon-name lookup — two different icon sets can assign
different codepoints to the same concept, and only some render correctly on
a given font build; see `baseline-checklist.md` rounds 2–4 for the bugs this
caused and how they were diagnosed). Covers os icons for Fedora, macOS,
Ubuntu, Debian, Arch, Mint, openSUSE/SUSE, CentOS, RHEL, Alpine, Manjaro,
Gentoo, Raspbian, NixOS, Windows, and a generic-Linux fallback for distros
p10k itself has no unique icon for (Kali, Void, EndeavourOS, RockyLinux,
AlmaLinux).

## Install / test steps

Prerequisites (installed via brew/linuxbrew; nix/home-manager on the Mac):

```sh
brew install antidote starship
```

Run the isolated test shell — this does **not** touch your real `~/.zshrc`,
`~/.p10k.zsh`, or the dotfiles repo:

```sh
cd zsh-prompt-evolution
ZDOTDIR=$(pwd)/zdotdir zsh
```

First run clones antidote's plugin bundles and generates completion caches
under `zdotdir/.cache/` and `zdotdir/.antidote/` (both git-ignored). Exit the
test shell any time with `exit` — your real shell is untouched.

To reset and force a clean re-run (e.g. after editing `.zsh_plugins.txt`):

```sh
rm -rf zdotdir/.cache zdotdir/.zsh_plugins.zsh* zdotdir/.zcompdump*
```

## Cutover (not done yet)

Once you've validated the look/behavior against the live p10k prompt:
1. Copy/merge `zdotdir/starship.toml` and `zdotdir/.zsh_plugins.txt` into the
   `verchalent/dotfiles` chezmoi source repo's proper structure.
2. Remove the oh-my-zsh/p10k lines from the real `dot_zshrc_xterm-256color`.
3. `chezmoi apply`, remove old oh-my-zsh/p10k files.
4. Repeat validation on the Mac before doing the same there.

See `roughplan.md` for the full phased plan.
