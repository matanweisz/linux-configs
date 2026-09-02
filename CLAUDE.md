# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

Workstation bootstrap automation for a DevOps engineer, with **two parallel stacks**
designed for **parity** — the Ubuntu side mirrors the macOS workflow with Linux-native tools:
- **Ubuntu** (top-level): **Homebrew-on-Linux for CLI** + apt/deb/snap for GUI, GNOME (Wayland),
  zsh/Zinit, Ghostty, Vicinae launcher, Tiling Shell, Tokyo Night.
- **macOS** (`mac/` subdirectory): Homebrew-based, Raycast tiling, Tokyo Night.

Both stacks install tools, restore dotfiles, and configure the desktop. They share OS-agnostic
configs (`configs/btop/`, `configs/starship.toml`), the **same Neovim config**
(`nvim/init.lua` and `mac/nvim/init.lua` differ only in a header comment), and **one skills
directory** — `mac/claude/skills/` is the single source for both OSes.

**Repo invariant — no employer-specific content.** Every tracked config, doc, and script must
stay generic: no company hostnames, internal URLs, org/repo names, ticket keys, project or
service names, or personal-employer context. The repo was fully sanitized; keep it that way.
Before any commit: run `gitleaks detect --no-git` (the pre-commit hook does this too) and
grep the diff for company-specific strings.

## Architecture

### Ubuntu side (top-level)
**Entry point:** `bootstrap.sh` — interactive numbered menu; option 1 = full run, which sources
the `install/*.sh` modules in dependency order: system-update → brew → zsh → docker/gcloud →
desktop-apps → restore-configs → claude → launcher → **gnome-extensions → gnome-setup** →
system-tuning → git-identity.

**Two ordering constraints in that sequence are load-bearing:**
- `gnome-extensions` before `gnome-setup` — dash-to-dock's schema must be on disk before
  `gnome-setup` writes dock keys through `gsettings`.
- `gnome-setup` after `launcher` — `launcher.sh:bind_vicinae_shortcut` clears
  `switch-input-source` to free Super+Space for Vicinae; `gnome-setup.sh:apply_input_sources`
  then re-binds layout switching to Super+Shift+Space. Reversed, the launcher wipes it.

**Package model (hybrid):** CLI tools come from **Homebrew** (`Brewfile`, identical names/versions
to the Mac); GUI apps from apt/deb/snap (casks are macOS-only); Docker Engine + gcloud SDK are native (apt).

**Install scripts** (`install/`):
- `brew.sh` — Homebrew on Linux + `brew trust --tap` for **every** third-party tap (fluxcd, hashicorp)
  + `brew bundle --file=Brewfile` + krew plugins
- `zsh.sh` — zsh (apt) + Zinit + chsh hint
- `devops-tools.sh` — **only** what brew can't do: Docker Engine + gcloud SDK (apt)
- `desktop-apps.sh` — Ghostty (PPA), VS Code, Chrome, Slack, WhatsApp, drawio, Standard Notes, Beekeeper
- `launcher.sh` — Vicinae binary + GNOME companion extension + Super+Space keybind
- `gnome-setup.sh` — gsettings tweaks (macos-defaults equivalents) + desktop polish (dock
  favourites, monospace font, workspaces, US/Hebrew layouts) + JetBrains Mono Nerd Font.
  Touches **core GNOME schemas only** — extensions live in the next module.
- `gnome-extensions.sh` — the 11-UUID daily-driver extension set, installed from
  extensions.gnome.org version-matched to the running shell, then
  `dconf load /org/gnome/shell/extensions/ < gnome/extensions.dconf`. Adding or removing an
  extension = editing the `EXTENSIONS` array plus the matching stanza in that keyfile.
- `system-tuning.sh` — `/etc/sysctl.d/99-workstation.conf` (swappiness 10), Intel VA-API
  packages for hardware video decode, `fstrim.timer` assertion
- `claude.sh` — Claude Code native install + sanitized config into the **single** Ubuntu
  profile `~/.claude` (used by the plain `claude` command). Copies
  `claude/{CLAUDE.md,statusline.sh,settings.json}` and `agents commands hooks output-styles
  rules`, plus **`mac/claude/skills/`** — skills are shared, not duplicated under `claude/`.
  Then `restore_plugins()` installs the marketplaces and plugins declared in
  `claude/settings.json` — plugin code is not tracked, so copying settings alone leaves
  every plugin declared but uninstalled.
- `restore-configs.sh` — copies dotfiles (zsh/ghostty/nvim/starship/git/btop) with timestamped backups

Each `install/*.sh` is **independently runnable** (standalone log-helper fallback) and ends with a
PASS/FAIL **verify** section. Every step is idempotent (`command -v` / list checks).

**GNOME backup:** `gnome-backup.sh` creates timestamped tarballs in `backup/` (extensions + dconf dump).
The new flow prefers the curated `install/gnome-setup.sh` over restoring an old backup.

### macOS side (`mac/`)
**Entry point:** `mac/bootstrap.sh` — numbered menu 0–12, each option calls a function (no flag-based sourcing like the Ubuntu side). Option 12 = "Run ALL" (steps 1–10) in dependency order: homebrew → packages → configs → defaults → zinit → krew → claude → borders → safe-rm → gcloud. Option 11 (cleanup orphaned packages) is deliberately excluded from Run ALL — it is opt-in and destructive.

**Tool installation:** declarative via `mac/Brewfile` (`brew bundle`). No per-category install scripts — everything is one Brewfile. `install_packages()` first uninstalls `docker-desktop` if present (Rancher's cask `conflicts_with` it), then runs `brew trust --tap` for `felixkratz/formulae` and `fluxcd/tap` — recent brew refuses to load third-party tap formulae until the tap is trusted (`|| true` keeps older brew working).

**Config layout:** topic dirs (`mac/zsh/`, `mac/nvim/`, `mac/ghostty/`, `mac/aerospace/`, `mac/alttab/`, `mac/raycast/`, `mac/claude/`, `mac/configs/{borders,tmux,gh,atuin}/`). `restore_configs()` copies (not symlinks) to `~/.config/` and `~`. `mac/alttab/` and `mac/raycast/` are `defaults import` plists, not file copies — the import is skipped while the app is running.

**Claude Code config (macOS only — Ubuntu is single-profile):** `restore_configs()` loops over **two** profile dirs — `~/.claude` (default) and `~/.claude-personal` (selected by the `claude-personal` alias via `CLAUDE_CONFIG_DIR`) — copying `CLAUDE.md`, `statusline.sh`, and `agents commands hooks output-styles rules skills` into each. The three settings files are copied afterwards, one per target: `settings.json` → `~/.claude/settings.json`, `settings.personal.json` → `~/.claude/settings.personal.json`, `settings.claude-personal.json` → `~/.claude-personal/settings.json`. `plugins.md` and `RESTORE-NOTES.md` are docs and must NOT be copied into either profile. Secrets are scrubbed in-repo — no auth tokens are tracked and every `mcpServers` block is emptied. See `mac/claude/RESTORE-NOTES.md`.

**Cross-platform configs:** `mac/bootstrap.sh` reads `${SCRIPT_DIR}/../configs/btop/` from the top-level `configs/` dir — that's the single source of truth for the btop theme on both OSes.

## Updating the backup (repo ← live machine)

Restores **copy** files, so live edits never flow back on their own. The full refresh
workflow — live-path → repo-path table for both OSes, Claude Code profile map, Raycast /
AltTab plist re-export one-liners, Brewfile-dump caveats, `defaults read` drift checks —
lives in **`README.md` → "Updating the backup"**. Follow it; don't reinvent it here.

Non-negotiables when refreshing: empty every `mcpServers` block, `gitleaks detect --no-git`
before committing, and commit on a branch + PR (never straight to `main`).

## Where the docs live

- `README.md` — entry point: quick-starts for both OSes, repo layout, backup-refresh workflow
- `mac/README.md` — macOS detail: tool tables, plugin lists, keybindings, aliases, safe-`rm`
- `HANDBACK.md` — machine hand-back: rotate, export, sign out, restore-on-next-machine
- `mac/claude/RESTORE-NOTES.md` — Claude Code profile/file map + what is scrubbed
- `mac/claude/plugins.md` — marketplaces + `enabledPlugins` lists (plugin code is not tracked)
- `mac/raycast/README.md`, `mac/alttab/README.md` — plist export/import + what the plist can't carry

## Key Commands

```bash
# Ubuntu bootstrap (top-level)
./bootstrap.sh

# Ubuntu: GNOME backup before migration
./gnome-backup.sh

# macOS bootstrap
cd mac && ./bootstrap.sh

# macOS: validate Brewfile resolves cleanly (no typos / renames)
cd mac && brew bundle check --file=Brewfile --verbose

# Syntax check all shell scripts (both OSes)
for f in bootstrap.sh gnome-backup.sh install/*.sh \
         mac/bootstrap.sh mac/macos-defaults.sh \
         mac/claude/statusline.sh mac/configs/borders/bordersrc; do
    bash -n "$f" && echo "OK: $f"
done

# Syntax check zsh files (both OSes)
for f in zsh/.zshrc zsh/.zsh_aliases mac/zsh/.zshrc mac/zsh/.zsh_aliases; do
    zsh -n "$f" && echo "OK: $f"
done

# Validate the Ubuntu Brewfile resolves cleanly
brew bundle check --file=Brewfile --verbose

# Parse-check the nvim init.lua without executing plugins
nvim --headless --clean \
  -c 'lua local f, e = loadfile("nvim/init.lua"); print(f and "OK" or e)' \
  -c 'qa!'
```

## Script Conventions

- All shell scripts use `set -euo pipefail`
- Log helpers `log_info`, `log_success`, `log_warn`, `log_error` are defined in each top-level entry script and inherited by sourced files
- **Ubuntu only:** before every `apt update`, clear cache to prevent corruption: `sudo rm -rf /var/cache/apt/*.bin 2>/dev/null || true`
- Idempotency: every install step checks `if ! command -v <tool> &>/dev/null; then` before installing
- Downloads go to `/tmp/`, cleaned up after install
- **Secret scanning:** `.pre-commit-config.yaml` runs the `gitleaks` hook. `gitleaks` is in both Brewfiles; activate with `pre-commit install`. This repo tracks real dotfiles, so scan before committing anything new: `gitleaks detect --no-git` (working tree) and `gitleaks detect` (history).
- `HANDBACK.md` is the machine hand-back checklist (credential rotation, what to export). Keep it current when new untracked state appears.

## Gotchas

- **`producer | grep -q PATTERN` is broken under `set -euo pipefail`.** `grep -q` exits at the
  first match, the producer dies with SIGPIPE, and the pipeline reports 141 — so the test reads
  FALSE exactly when the thing IS present. This silently made `install_nerd_font` re-download a
  ~35 MB archive on every run and made `gset()` skippable. Use the `pipe_matches` helper in
  `install/gnome-setup.sh` (`<producer> | pipe_matches -xF "$needle"`) or capture a `grep -c`
  count with `|| true`. Never introduce a new `| grep -q` in these scripts.
- **Extension settings need `dconf`, not `gsettings`.** A user-installed extension's schema
  lives in `~/.local/share/gnome-shell/extensions/<uuid>/schemas/` and is invisible to
  `gsettings` without `GSETTINGS_SCHEMA_DIR`. `gset()` guards on `gsettings list-schemas` and
  would silently skip every extension key. That is why `gnome/extensions.dconf` exists.
- **`org.gnome.desktop.interface overlay-scrolling false` is load-bearing, not cosmetic.**
  Overlay scrolling is what turns on GTK's kinetic/momentum scroll accumulation; with it
  enabled, two-finger touchpad scrolling builds speed until it is unusable on this hardware.
  It reads like a scrollbar-appearance preference and has been "tidied away" once already.
  Leave it off.
- **GNOME has no touchpad scroll-speed setting — do not go looking for one.** Every `scroll`
  key in every installed schema is a direction or enable toggle; `touchpad speed` is POINTER
  acceleration and does not touch scrolling. libinput ships no scroll-factor quirk either
  (`AttrTrackpointMultiplier` is trackpoint-only). The only system-wide lever is
  `AttrSizeHint` in `configs/libinput/local-overrides.quirks`: libinput derives resolution
  from the declared pad size, so declaring the pad smaller than it is slows scrolling
  proportionally. Symptom that points here: scroll is too fast on the touchpad but correct
  on an external mouse (a wheel sends discrete notches, a touchpad sends distance).
- **Claude settings carry no `permissions` block, deliberately.** It was removed on request:
  `deny` rules still apply under `--dangerously-skip-permissions`, so the block blocked the
  very workflow it was meant to sit out of. The `hooks` are kept and are the remaining guard.
  Do not reintroduce a `permissions` key when refreshing these files from a live machine.
- **Restoring Claude settings does not restore plugins.** Plugin code lives under
  `~/.claude*/plugins/` and is not tracked. `install/claude.sh:restore_plugins()` reads
  `extraKnownMarketplaces` + `enabledPlugins` from each profile's settings and drives the
  `claude plugin` CLI. Adding a plugin = enabling it in the settings file, nothing else.
- **Ubuntu is single-profile; macOS is not.** Ubuntu has exactly one Claude config,
  `~/.claude`, backed by one file, `claude/settings.json`. There is no `claude-personal`
  profile and no alias — do not "restore parity" by re-adding one. The mac side keeps two
  profiles and three settings files on purpose; that asymmetry is intentional.
- **dconf section names are paths, not UUIDs.** `rounded-window-corners@fxgn` writes to
  `rounded-window-corners-reborn`. Check the real path before adding a stanza.
- **Every third-party Homebrew tap needs `brew trust --tap`.** One untrusted tap aborts the
  entire `brew bundle` run ("Refusing to load formula ... from untrusted tap"), which is how
  terraform silently went missing on a fresh machine. `install/brew.sh` trusts `fluxcd/tap`
  and `hashicorp/tap`; add a line for any new tap in either Brewfile.
- **`ubuntu-dock@ubuntu.com` self-disables when `dash-to-dock@micxgx.gmail.com` loads** (see its
  `extension.js` `_conditionallyEnableDock`), and both share the
  `org.gnome.shell.extensions.dash-to-dock` schema. Installing dash-to-dock needs no manual
  disable, and dock settings apply to whichever one is active.
- **nvim-treesitter (main branch)** requires `tree-sitter-cli` (not the `tree-sitter` library formula) to compile parsers. Without it, nvim spams ENOENT errors on every startup. It is listed in the Brewfile; ensure `brew bundle` has run before opening nvim.
- **`TrackpadThreeFingerDrag`** is intentionally absent from `macos-defaults.sh`. Setting it to `true` reassigns three-finger swipes from Mission Control/spaces navigation to window drag, breaking standard macOS gesture muscle memory.

## Adding New Tools

### Ubuntu
1. Pick the right place: **CLI tool → add to `Brewfile`**; native daemon → `install/devops-tools.sh`;
   GUI app → `install/desktop-apps.sh`; launcher → `install/launcher.sh`; GNOME *setting* →
   `install/gnome-setup.sh`; GNOME *extension* → the `EXTENSIONS` array in
   `install/gnome-extensions.sh` **and** a stanza in `gnome/extensions.dconf`.
2. Follow the existing pattern: command-exists/list check → install → `log_success`, and extend the module's `verify` section.
3. If the tool ships a config, drop it in the matching topic dir (`configs/`, `bash/`, etc.) and extend `install/restore-configs.sh`

### macOS
1. Add the formula/cask to `mac/Brewfile`
2. **Third-party taps:** if the formula lives in a non-core tap, **qualify it with the tap prefix** even after declaring `tap "..."`. `brew bundle` does NOT auto-resolve unqualified names against third-party taps — it only looks in homebrew-core first and fails with a "did you mean" suggestion. Pattern:
   ```ruby
   tap "felixkratz/formulae"
   brew "felixkratz/formulae/borders"   # NOT just brew "borders"
   ```
   Same applies to `hashicorp/tap/terraform` and `fluxcd/tap/flux`. Tap names must be lowercase (Homebrew normalizes them on disk).
3. If the tool ships a config, drop it in a topic dir under `mac/` and extend `restore_configs()` in `mac/bootstrap.sh`. If it needs a one-time setup step (service start, plugin install), add a new menu function and slot it into the "Run ALL" sequence.
4. Validate: `cd mac && brew bundle check --file=Brewfile --verbose` should report only "needs to be installed" lines — no "Warning", "Error", or "did you mean" output.
