# Baseline: current p10k / oh-my-zsh setup

Captured from `verchalent/dotfiles` (SSH clone, commit `10519e9`), amatarsu's active
terminal path (`xterm-256color` / ghostty / alacritty all resolve here).

Source files:
- `dot_config/zsh/dot_zshrc_xterm-256color` — loads oh-my-zsh + p10k
- `dot_p10k.zsh` — prompt config, **stock `p10k-lean.zsh` wizard output**, barely modified

## oh-my-zsh plugins in use

```
plugins=(git zsh-syntax-highlighting zsh-autosuggestions you-should-use 1password chezmoi podman dnf systemd)
```

Antidote mapping (target for `zdotdir/.zsh_plugins.txt`):

| oh-my-zsh plugin | antidote source | notes |
|---|---|---|
| git | `ohmyzsh/ohmyzsh path:plugins/git` | aliases only, no framework needed |
| zsh-syntax-highlighting | `zsh-users/zsh-syntax-highlighting` | standalone repo, **must load last** |
| zsh-autosuggestions | `zsh-users/zsh-autosuggestions` | standalone repo |
| you-should-use | `MichaelAquilina/zsh-you-should-use` | standalone repo (omz plugin is a mirror of this) |
| 1password | `ohmyzsh/ohmyzsh path:plugins/1password` | completions |
| chezmoi | `ohmyzsh/ohmyzsh path:plugins/chezmoi` | completions |
| podman | `ohmyzsh/ohmyzsh path:plugins/podman` | completions/aliases |
| dnf | `ohmyzsh/ohmyzsh path:plugins/dnf` | aliases |
| systemd | `ohmyzsh/ohmyzsh path:plugins/systemd` | aliases |

Also: `ENABLE_CORRECTION="true"` in omz → zsh native `setopt correct`.

## p10k wizard options (from `dot_p10k.zsh` header comment)

`nerdfont-complete + powerline, small icons, unicode, lean, 24h time, 1 line, compact,
many icons, concise, transient_prompt, instant_prompt=verbose`

## Visible segments (parity checklist for starship.toml)

**Left prompt:**
| segment | detail |
|---|---|
| os_icon | distro icon |
| dir | current directory, fg `31`, anchor `39`, shortened `103`, max 80 chars |
| vcs (git) | clean fg `76`, modified fg `178`, branch icon, ahead/behind counts |
| prompt_char | `❯` ok=`76` (green) / error=`196` (red); `❮` in vicmd — **low priority, shell is emacs-mode (no explicit `bindkey -v`), vicmd char essentially never shown in practice** |

**Right prompt (segments actually likely to render day-to-day; full p10k list includes ~40
env-manager segments that only show when relevant — e.g. pyenv, nvm, kubecontext — those
are conditional and starship has near-1:1 equivalents if/when they trigger):**
| segment | detail |
|---|---|
| status | exit code of last command |
| command_execution_time | duration of last command |
| background_jobs | job count indicator |
| direnv | direnv loaded/allowed status |
| nix_shell | nix-shell indicator |
| context | user@hostname — p10k default hides this outside SSH; skip unless it shows locally |
| time | 24h clock |

## Step 3/4 smoke test (this sandbox, first pass)

Ran `ZDOTDIR=$(pwd)/zdotdir zsh` against `zdotdir/.zshrc` + `starship.toml` +
`.zsh_plugins.txt`. Fixed two real bugs surfaced along the way:

- **antidote source URL** — corrected to `getantidote/antidote` (was pointed at
  `getantidote/zdotdir`, a different project, then briefly `mattmc3/antidote` in my
  draft; user caught this and fixed it. `.zshrc` now prefers the brew-installed
  antidote already on this box, `getantidote/antidote` only as clone fallback).
- **`compdef: command not found`** — omz plugins loaded standalone via antidote
  (no full `oh-my-zsh.sh`) call `compdef` before completion system is up. Fixed by
  running `compinit` before `antidote load`.
- **`process substitution failed` + `munmap_chunk(): invalid pointer` crash** —
  chezmoi/podman omz plugins write generated completions to `$ZSH_CACHE_DIR`,
  an oh-my-zsh global that's never set when plugins load standalone. Falls back
  to a bogus root path and corrupts the shell. Fixed by setting
  `ZSH_CACHE_DIR="${ZDOTDIR}/.cache"` (+ `mkdir -p`) before `antidote load`.

After both fixes: clean load, no errors. Verified: dir/git/prompt-char colors
match baseline, exit-status coloring (red `✘1` / red `❯` on nonzero exit),
zsh-autosuggestions + zsh-syntax-highlighting widgets active, async completion
generation for chezmoi/podman/1password works (first run generates cache,
registers on next shell start — expected omz pattern, not a bug).

**Not yet checked here** (needs the real amatarsu terminal, not this sandbox):
actual font/nerd-font icon rendering, `you-should-use` trigger behavior,
`dnf`/`systemd` plugin aliases (no dnf/systemctl in this sandbox), real visual
side-by-side against the live p10k prompt.

## Round 2 — user screenshot (real terminal), two issues found and fixed

1. **No nerd-font glyphs in the prompt at all** (os icon, git branch icon both
   blank). Root cause: my first draft of `starship.toml` had the glyph
   characters silently dropped on write — `Fedora = ""`, git_branch
   `symbol = " "` were empty strings, not the intended icons. Fixed by
   rewriting them as TOML `\uXXXX` escapes instead of pasting literal glyph
   characters (had to correct twice — first attempt used Rust-style
   `\u{XXXX}` braces, which TOML's parser rejects; TOML wants bare `\uXXXX`,
   4 hex digits, no braces). Verified via `od -c` that the config now emits
   the correct raw UTF-8 bytes for `` (Fedora devicon) and ``
   (git-branch — same codepoint as `POWERLEVEL9K_VCS_BRANCH_ICON` in the real
   `dot_p10k.zsh`, for exact parity). `Macos` symbol set to ``. Dropped
   a similarly-corrupted `nix_shell` symbol override in favor of starship's
   built-in default (plain snowflake emoji, no nerd font required).
2. **`ls` + Tab rendered with no color/icons vs. current setup.** Not a
   starship/antidote bug — the icons/color come from `alias ls='lsd'` in the
   real dot_zshrc, which the test `.zshrc` deliberately didn't carry over
   (out of scope for the prompt/plugin swap, untouched either way at
   cutover). Added `ls`/`ll`/`cat`/`find` aliases to `zdotdir/.zshrc` purely
   so the test env is a fair visual side-by-side.

**Lesson for any future edits to `starship.toml`:** always use `\uXXXX`
escapes for nerd-font/PUA glyphs, never paste the literal character —
confirmed the literal-paste path silently drops bytes when written through
tooling.

## Round 3 — real screenshot after round-2 fix

git_branch icon (``) now renders correctly — confirms the TOML-escape
fix was right. OS/Fedora icon still garbled: `` (nf-**dev**-fedora, from
Nerd Fonts' generic glyphnames.json) is a different codepoint than the one
p10k itself actually uses. Checked p10k's own `internal/icons.zsh`: its
`nerdfont-complete`/`nerdfont-v3` mode (matches the wizard options recorded in
`dot_p10k.zsh`) maps `LINUX_FEDORA_ICON` to `` (nf-**linux**-fedora, a
different icon set than devicons) — since that's the exact codepoint already
proven to render on their installed font today, switched to it. Also
cross-checked `Macos = ` against p10k's `APPLE_ICON` — already an exact
match, no change needed there.

**Lesson:** don't source nerd-font codepoints from the generic glyphnames.json
icon-name search — different icon sets (devicons vs linux vs font-awesome)
can assign different codepoints to conceptually-the-same icon, and only some
sets may be present/correctly-patched in a given font build. Pull codepoints
from p10k's own `internal/icons.zsh` instead — it's the exact reference the
current, working setup already renders correctly.

## Round 4 — os icon "too small" + wrong color

Codepoint (``) confirmed correct by this point. Two remaining gaps:

- **Color** — I'd arbitrarily set `style = "bold 39"` (blue) with no source.
  Checked p10k's actual `prompt_os_icon` in `internal/p10k.zsh`: its real
  default foreground is plain **white** (`black`/`white` segment colors, no
  `POWERLEVEL9K_OS_ICON_FOREGROUND` override in `dot_p10k.zsh` either).
  Switched `style` to `"white"`.
- **"Too small to see"** — not actually a glyph-size issue (starship/p10k
  don't control font glyph metrics, only the font does). Root cause: our
  `[os]` block had no `format` override, so starship's default packs the icon
  directly against `$directory` with zero separating space — cramped kerning
  read as "too small." Added `format = "[$symbol]($style) "` for a trailing
  space, same pattern `git_branch`'s symbol already had baked in (which is
  why that one read fine).

## Known gaps — no direct starship equivalent, flag for step 4 (human validation)

- **instant_prompt** — p10k-specific technique to render prompt before full init; starship
  has no equivalent but starts fast enough natively that it's likely a non-issue. Watch for
  perceived startup lag during validation.
- **transient_prompt** — p10k collapses old prompts to a minimal form after Enter. Starship
  has no built-in equivalent; achievable later via a custom `precmd`/`preexec` hook if the
  look-and-feel gap bothers you after testing. Not blocking for first pass.
- **vicmd prompt_char (`❮`)** — see above, likely moot since shell isn't in vi keybinding mode.
