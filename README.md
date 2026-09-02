# Workstation configs — Ubuntu + macOS

Two parallel bootstrap stacks for the same DevOps workflow, kept at parity:

- **Ubuntu** (top-level) — Ubuntu 24.04 LTS, GNOME 46, Wayland. Homebrew-on-Linux for
  CLI, apt/deb/snap for GUI.
- **macOS** (`mac/`) — Homebrew for everything, Raycast tiling. See `mac/README.md`.

Both restore dotfiles by **copy, not symlink**, and share `configs/btop/`, the same
`starship.toml`, an effectively identical `nvim/init.lua`, and one skills directory
(`mac/claude/skills/`).

What you get on either OS:
- **zsh + Zinit** (turbo plugins), same `.zshrc`/aliases
- **Ghostty** terminal (Tokyo Night, JetBrains Mono Nerd Font)
- **Neovim 2026** (snacks/blink/Mason v2, Tokyo Night)
- **Starship** prompt with k8s/cloud/terraform modules + **git-delta**
- **Claude Code** — sanitized (generic) config: statusline, safe hooks, permissions
- Launcher + tiling: **Vicinae** + Tiling Shell (Ubuntu) · **Raycast** + JankyBorders + AltTab (macOS)

---

## New machine

### Ubuntu

```bash
git clone https://github.com/matanweisz/linux-configs.git ~/git/linux-configs
cd ~/git/linux-configs
./bootstrap.sh           # option 1 = full run, in dependency order
```

Menu: 1) Full · 2) Homebrew+CLI · 3) Zsh+Zinit · 4) Docker+gcloud · 5) Desktop apps+Ghostty ·
6) Restore configs · 7) Claude Code · 8) Vicinae · 9) GNOME tweaks+polish+fonts ·
10) GNOME Shell extensions · 11) System tuning · 12) Git identity · 0) Exit.

Privileged steps (apt, PPAs, initial Homebrew, Docker) prompt for sudo. Everything
user-level (Vicinae, GNOME settings, fonts, Zinit, Claude config, dotfiles) does not.

Then, by hand:

1. `chsh -s "$(command -v zsh)"` and **log out/in** (also activates the Homebrew PATH,
   the docker group, and *all* GNOME extensions — Wayland cannot load an extension into
   a running shell, so nothing under option 10 appears until you log back in).
2. `gh auth login` · `aws configure` · `gcloud init`
3. `ssh-keygen -t ed25519 -f ~/.ssh/github_ed25519`, add the pubkey to GitHub.
4. Run `nvim` once so lazy.nvim installs plugins.
5. `pre-commit install` in this repo (activates the gitleaks hook).
6. Claude Code: re-add MCP servers and plugins by hand — `mac/claude/RESTORE-NOTES.md`, `mac/claude/plugins.md`.
7. Super+Space for Vicinae; Super+arrows to tile; Super+Shift+Space for US/Hebrew.

### macOS

```bash
git clone https://github.com/matanweisz/linux-configs.git ~/git/linux-configs
cd ~/git/linux-configs/mac
./bootstrap.sh           # option 12 = Run ALL (steps 1–10)
```

Option 11 (cleanup orphaned packages) is opt-in and excluded from Run ALL.

Then, by hand:

1. Open a new terminal, run `nvim` once (lazy.nvim installs plugins).
2. `ssh-keygen -t ed25519 -C "your@email.com"`; `gh auth login`.
3. **Raycast** — the plist restores hotkeys/prefs; snippets and quicklinks need a
   `.rayconfig` import. See `mac/raycast/README.md`.
4. **AltTab** — `mac/alttab/README.md`. Quit the app before re-running option 3 or the
   `defaults import` is skipped.
5. **Claude Code** — re-add `mcpServers` (scrubbed on purpose) and the plugin
   marketplaces: `mac/claude/RESTORE-NOTES.md`, `mac/claude/plugins.md`.
6. `pre-commit install` in this repo.
7. First-run apps: `open -a "Rancher Desktop"` (sets up k8s + container runtime).

---

## Package model

| | Ubuntu | macOS |
|---|---|---|
| CLI tools | Homebrew (`Brewfile`) | Homebrew (`mac/Brewfile`) |
| GUI apps | apt / deb / snap (`install/desktop-apps.sh`) | Homebrew casks |
| Native daemons | apt — Docker Engine, gcloud SDK (`install/devops-tools.sh`) | casks / option 10 |

CLI tool names and versions are identical across both Brewfiles on purpose.

---

## Repository layout

```
linux-configs/
├── bootstrap.sh              # Ubuntu entry point — drives install/*.sh
├── Brewfile                  # Ubuntu CLI tools (Homebrew on Linux)
├── .pre-commit-config.yaml   # gitleaks secret scanning
├── CLAUDE.md                 # repo guidance for Claude Code sessions
├── HANDBACK.md               # machine hand-back checklist (rotate/export/sign-out)
├── install/
│   ├── brew.sh               # Homebrew + brew bundle + krew
│   ├── zsh.sh                # zsh + Zinit (+ chsh hint)
│   ├── devops-tools.sh       # Docker Engine + gcloud (native apt)
│   ├── desktop-apps.sh       # Ghostty, VS Code, Chrome, Slack, WhatsApp, etc.
│   ├── launcher.sh           # Vicinae + GNOME companion + Super+Space
│   ├── gnome-setup.sh        # gsettings + desktop polish + JetBrains Mono Nerd Font
│   ├── gnome-extensions.sh   # Shell extensions from extensions.gnome.org + their dconf
│   ├── system-tuning.sh      # sysctl (swappiness), VA-API video decode, fstrim
│   ├── claude.sh             # Claude Code (native) + sanitized config + shared skills
│   └── restore-configs.sh    # copy dotfiles into place (timestamped backups)
├── zsh/{.zshrc,.zsh_aliases} # shell config
├── bash/.bash_aliases        # bash fallback aliases
├── ghostty/config            # terminal config
├── nvim/init.lua             # editor config (in sync with mac/nvim/init.lua)
├── gnome/extensions.dconf    # GNOME Shell extension settings (source of truth)
├── configs/libinput/         # touchpad scroll-damping quirk (-> /etc/libinput/)
├── configs/                  # shared: starship.toml, .gitconfig, .gitignore_global, btop/
├── claude/                   # Ubuntu Claude Code config (no skills/ — see mac/claude/skills)
├── github/                   # SSH setup guide
├── backup/, gnome-backup.sh  # GNOME state capture (extensions + dconf dump)
├── alacritty/, vim/, wallpaper/   # kept for reference; not installed by any script
└── mac/
    ├── bootstrap.sh          # macOS entry point (menu 0–12)
    ├── Brewfile              # all macOS formulae + casks
    ├── macos-defaults.sh     # developer-friendly system preferences
    ├── zsh/, ghostty/, nvim/, aerospace/
    ├── configs/              # starship, git, borders, tmux, gh, atuin
    ├── raycast/, alttab/     # exported plists + per-app README
    └── claude/               # Claude Code config + skills/ (single source for both OSes)
```

---

## Updating the backup

Restores **copy** files, so live edits never flow back on their own. Copy in the other
direction, then commit on a branch.

### Dotfiles → repo

| Live path | macOS repo path | Ubuntu repo path |
|---|---|---|
| `~/.zshrc` | `mac/zsh/.zshrc` | `zsh/.zshrc` |
| `~/.zsh_aliases` | `mac/zsh/.zsh_aliases` | `zsh/.zsh_aliases` |
| `~/.bash_aliases` | — | `bash/.bash_aliases` |
| `~/.config/nvim/init.lua` | `mac/nvim/init.lua` | `nvim/init.lua` |
| `~/.config/ghostty/config` | `mac/ghostty/config` | `ghostty/config` |
| `~/.config/starship.toml` | `mac/configs/starship.toml` | `configs/starship.toml` |
| `~/.gitconfig` · `~/.gitignore_global` | `mac/configs/` | `configs/` |
| `~/.config/btop/{btop.conf,themes/}` | `configs/btop/` (shared) | `configs/btop/` |
| `~/.config/borders/bordersrc` | `mac/configs/borders/bordersrc` | — |
| `~/.config/aerospace/aerospace.toml` | `mac/aerospace/aerospace.toml` | — |
| `~/.config/tmux/tmux.conf` | `mac/configs/tmux/tmux.conf` | — |
| `~/.config/gh/config.yml` | `mac/configs/gh/config.yml` | — |
| `~/.config/atuin/config.toml` | `mac/configs/atuin/config.toml` | — |

### Claude Code → repo

| Live path | Repo path |
|---|---|
| `~/.claude/CLAUDE.md` · `statusline.sh` | `mac/claude/` (macOS) · `claude/` (Ubuntu) |
| `~/.claude/{agents,commands,hooks,output-styles,rules}/` | same, per OS |
| `~/.claude/skills/` | `mac/claude/skills/` — **single source for both OSes** |
| `~/.claude/settings.json` | `mac/claude/settings.json` · `claude/settings.json` |
| `~/.claude/settings.personal.json` | `mac/claude/settings.personal.json` · `claude/settings.personal.json` |
| `~/.claude-personal/settings.json` | `mac/claude/settings.claude-personal.json` · `claude/settings.claude-personal.json` |

Both OSes populate **both** profiles (`~/.claude` and `~/.claude-personal`) — Ubuntu via
`install/claude.sh`, macOS via `restore_configs()`. `install/claude.sh` copies
`mac/claude/skills/` into each profile's `skills/` — skills are deliberately not duplicated
under `claude/`.

**Before committing any settings file, empty every `mcpServers` block** — that's where
tokens live:

```bash
jq '.mcpServers = {}' ~/.claude/settings.json > mac/claude/settings.json
```

Details and the full profile map: `mac/claude/RESTORE-NOTES.md`.

### App plists (macOS)

```bash
# Raycast — mac/raycast/README.md
osascript -e 'quit app "Raycast"' 2>/dev/null
defaults export com.raycast.macos mac/raycast/com.raycast.macos.plist
plutil -convert xml1 mac/raycast/com.raycast.macos.plist
open -a Raycast

# AltTab — mac/alttab/README.md (telemetry keys must be stripped)
osascript -e 'quit app "AltTab"' 2>/dev/null
defaults export com.lwouis.alt-tab-macos mac/alttab/com.lwouis.alt-tab-macos.plist
for k in MSAppCenterInstallId MSAppCenterPastDevices MSAppCenterSessionIdHistory MSAppCenterUserIdHistory; do
    /usr/libexec/PlistBuddy -c "Delete :$k" mac/alttab/com.lwouis.alt-tab-macos.plist 2>/dev/null || true
done
plutil -convert xml1 mac/alttab/com.lwouis.alt-tab-macos.plist
open -a AltTab
```

Raycast snippets, quicklinks, and extension prefs are **not** in the plist — they need a
`.rayconfig` export kept outside git. See `mac/raycast/README.md`.

### Brewfile

Prefer hand-editing: both Brewfiles are grouped and commented, and `brew bundle dump`
overwrites all of it. If you dump anyway:

```bash
brew bundle dump --file=mac/Brewfile --force --describe --no-vscode
```

- `--describe` writes a comment per formula (still loses the section headers).
- Without `--no-vscode` the dump **silently injects a `vscode "..."` line per installed
  VS Code extension**.
- Re-add the `tap` lines and the tap-qualified names afterwards
  (`felixkratz/formulae/borders`, `hashicorp/tap/terraform`, `fluxcd/tap/flux`).

Validate: `brew bundle check --file=mac/Brewfile --verbose` — only "needs to be
installed" lines are acceptable.

### macOS defaults

Check drift before editing `mac/macos-defaults.sh`:

```bash
defaults read com.apple.dock
defaults read com.apple.finder
defaults read -g InitialKeyRepeat
```

### GNOME (Ubuntu)

Extensions and their settings are **declarative**, not restored from a tarball. After
tuning an extension in its preferences dialog, export it back:

```bash
dconf dump /org/gnome/shell/extensions/ > gnome/extensions.dconf
```

Then trim the stanzas for extensions that are not in the `EXTENSIONS` list in
`install/gnome-extensions.sh` — dconf keeps settings for long-uninstalled extensions
forever, so a raw dump carries years of dead config. To add or drop an extension, edit
that `EXTENSIONS` list; it is keyed by UUID and version-matched to the running shell at
install time.

```bash
./gnome-backup.sh   # timestamped tarball in backup/ — fallback record only
```

The curated `install/gnome-setup.sh` + `gnome/extensions.dconf` pair is the source of
truth; the tarball exists as a fallback record and is not what bootstrap reads.

### Commit

```bash
gitleaks detect --no-git                     # working tree
git switch -c backup-refresh-$(date +%Y-%m)
git add -A && git commit -m "Refresh workstation backup"
git push -u origin HEAD                      # then open a PR — never push to main
```

Keep the repo free of employer-specific content (hostnames, internal URLs, ticket keys,
project names). Sanitization is a repo invariant, not a one-off cleanup.

---

## Secret scanning

This repo tracks real dotfiles, so `.pre-commit-config.yaml` runs the `gitleaks` hook on
every commit (`gitleaks` is in both Brewfiles). Activate it once per clone:

```bash
pre-commit install
gitleaks detect --no-git   # working tree
gitleaks detect            # full history
```

---

## Handing a machine back

Work through **`HANDBACK.md`** — credentials to rotate, local-only state to export,
sessions to sign out of. Nothing there is reversible after a wipe.

---

## Key aliases

| Alias | Description | | Alias | Description |
|-------|-------------|-|-------|-------------|
| `ls`/`ll`/`lt` | eza (icons/detail/tree) | | `k` | kubectl |
| `cat` | bat | | `kco` | switch kubectl context |
| `lg`/`lzd` | lazygit / lazydocker | | `awsuser` | switch AWS profile |
| `vim` | nvim | | `ec2ls`/`ec2ssh` | list / SSH EC2 by ID |
| `t`/`tp`/`ta` | terraform / plan / apply | | `rm`/`unrm` | safe-trash / restore |

Full reference: `mac/README.md`.
