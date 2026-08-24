# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

Workstation bootstrap automation for a DevOps engineer, with **two parallel stacks**
designed for **parity** — the Ubuntu side mirrors the macOS workflow with Linux-native tools:
- **Ubuntu** (top-level): **Homebrew-on-Linux for CLI** + apt/deb/snap for GUI, GNOME (Wayland),
  zsh/Zinit, Ghostty, Vicinae launcher, Tiling Shell, Tokyo Night.
- **macOS** (`mac/` subdirectory): Homebrew-based, Raycast tiling, Tokyo Night.

Both stacks install tools, restore dotfiles, and configure the desktop. They share OS-agnostic
configs (`configs/btop/`) and the **same Neovim config** (`nvim/init.lua` ≡ `mac/nvim/init.lua`).

## Architecture

### Ubuntu side (top-level)
**Entry point:** `bootstrap.sh` — interactive numbered menu; option 1 = full run, which sources
the `install/*.sh` modules in dependency order: system-update → brew → zsh → docker/gcloud →
desktop-apps → restore-configs → claude → launcher → gnome-setup → git-identity.

**Package model (hybrid):** CLI tools come from **Homebrew** (`Brewfile`, identical names/versions
to the Mac); GUI apps from apt/deb/snap (casks are macOS-only); Docker Engine + gcloud SDK are native (apt).

**Install scripts** (`install/`):
- `brew.sh` — Homebrew on Linux + `brew bundle --file=Brewfile` + krew plugins
- `zsh.sh` — zsh (apt) + Zinit + chsh hint
- `devops-tools.sh` — **only** what brew can't do: Docker Engine + gcloud SDK (apt)
- `desktop-apps.sh` — Ghostty (PPA), VS Code, Chrome, Slack, WhatsApp, drawio, Standard Notes, Beekeeper, OpenLens
- `launcher.sh` — Vicinae binary + GNOME companion extension + Super+Space keybind
- `gnome-setup.sh` — gsettings tweaks (macos-defaults equivalents) + Tiling Shell + JetBrains Mono Nerd Font
- `claude.sh` — Claude Code native install + sanitized config into `~/.claude`
- `restore-configs.sh` — copies dotfiles (zsh/ghostty/nvim/starship/git/btop) with timestamped backups

Each `install/*.sh` is **independently runnable** (standalone log-helper fallback) and ends with a
PASS/FAIL **verify** section. Every step is idempotent (`command -v` / list checks).

**GNOME backup:** `gnome-backup.sh` creates timestamped tarballs in `backup/` (extensions + dconf dump).
The new flow prefers the curated `install/gnome-setup.sh` over restoring an old backup.

### macOS side (`mac/`)
**Entry point:** `mac/bootstrap.sh` — numbered menu 0–12, each option calls a function (no flag-based sourcing like the Ubuntu side). Option 12 = "Run ALL" (steps 1–10) in dependency order: homebrew → packages → configs → defaults → zinit → krew → claude → borders → safe-rm → gcloud. Option 11 (cleanup orphaned packages) is deliberately excluded from Run ALL — it is opt-in and destructive.

**Tool installation:** declarative via `mac/Brewfile` (`brew bundle`). No per-category install scripts — everything is one Brewfile.

**Config layout:** topic dirs (`mac/zsh/`, `mac/nvim/`, `mac/ghostty/`, `mac/aerospace/`, `mac/alttab/`, `mac/raycast/`, `mac/claude/`, `mac/configs/{borders,tmux,gh,atuin}/`). `restore_configs()` copies (not symlinks) to `~/.config/` and `~`. `mac/alttab/` and `mac/raycast/` are `defaults import` plists, not file copies — the import is skipped while the app is running.

**Claude Code config:** `mac/claude/` restores to `~/.claude/` — `settings.json` + `settings.personal.json` + `statusline.sh` by direct `cp`, then `agents commands hooks output-styles rules skills` via the `for sub in …` loop in `restore_configs()`. `plugins.md` and `RESTORE-NOTES.md` are docs and must NOT be copied into `~/.claude`. Secrets (`ANTHROPIC_AUTH_TOKEN`, `mcpServers`) are scrubbed in-repo — see `mac/claude/RESTORE-NOTES.md`.

**Cross-platform configs:** `mac/bootstrap.sh` reads `${SCRIPT_DIR}/../configs/btop/` from the top-level `configs/` dir — that's the single source of truth for the btop theme on both OSes.

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

- **nvim-treesitter (main branch)** requires `tree-sitter-cli` (not the `tree-sitter` library formula) to compile parsers. Without it, nvim spams ENOENT errors on every startup. It is listed in the Brewfile; ensure `brew bundle` has run before opening nvim.
- **`TrackpadThreeFingerDrag`** is intentionally absent from `macos-defaults.sh`. Setting it to `true` reassigns three-finger swipes from Mission Control/spaces navigation to window drag, breaking standard macOS gesture muscle memory.

## Adding New Tools

### Ubuntu
1. Pick the right place: **CLI tool → add to `Brewfile`**; native daemon → `install/devops-tools.sh`;
   GUI app → `install/desktop-apps.sh`; launcher/GNOME → `install/launcher.sh` / `install/gnome-setup.sh`.
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
