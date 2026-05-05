# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

Workstation bootstrap automation for a DevOps engineer, with **two parallel stacks**:
- **Ubuntu** (top-level): apt-based, GNOME desktop, Tiling Shell extension
- **macOS** (`mac/` subdirectory): Homebrew-based, Raycast tiling, Tokyo Night theming

Both stacks install tools, restore dotfiles, and configure the desktop. They share a small set of OS-agnostic configs (e.g. `configs/btop/`).

## Architecture

### Ubuntu side (top-level)
**Entry point:** `bootstrap.sh` — interactive menu (1=full, 2=core, 3=devops, 4=desktop, 5=configs, 6=custom). Exports `INSTALL_*`/`RESTORE_*` flags, then sources `install/*.sh` based on those flags.

**Install scripts** (`install/`):
- `core-tools.sh` — eza, bat, fzf, lazygit, starship, gh
- `devops-tools.sh` — Docker, kubectl, helm, OpenLens, Terraform, Terragrunt, AWS CLI, GCloud SDK, ArgoCD, Trivy
- `desktop-apps.sh` — VS Code, Chrome, Spotify, WhatsApp, Alacritty, Ulauncher
- `restore-configs.sh` — copies dotfiles to `~/.config/` and restores GNOME settings from `backup/`

**GNOME backup:** `gnome-backup.sh` creates timestamped tarballs in `backup/` (extensions + dconf dump). Run before migrating to a new machine.

### macOS side (`mac/`)
**Entry point:** `mac/bootstrap.sh` — numbered menu 0–11, each option calls a function (no flag-based sourcing like the Ubuntu side). Option 11 = "Run ALL" in dependency order: homebrew → packages → configs → defaults → zinit → krew → claude → borders → safe-rm.

**Tool installation:** declarative via `mac/Brewfile` (`brew bundle`). No per-category install scripts — everything is one Brewfile.

**Config layout:** topic dirs (`mac/zsh/`, `mac/nvim/`, `mac/aerospace/`, `mac/ghostty/`, `mac/claude/`, `mac/configs/`). `restore_configs()` copies (not symlinks) to `~/.config/` and `~`.

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

# Syntax check zsh files
for f in mac/zsh/.zshrc mac/zsh/.zsh_aliases; do
    zsh -n "$f" && echo "OK: $f"
done

# Parse-check the nvim init.lua without executing plugins
nvim --headless --clean \
  -c 'lua local f, e = loadfile("mac/nvim/init.lua"); print(f and "OK" or e)' \
  -c 'qa!'
```

## Script Conventions

- All shell scripts use `set -euo pipefail`
- Log helpers `log_info`, `log_success`, `log_warn`, `log_error` are defined in each top-level entry script and inherited by sourced files
- **Ubuntu only:** before every `apt update`, clear cache to prevent corruption: `sudo rm -rf /var/cache/apt/*.bin 2>/dev/null || true`
- Idempotency: every install step checks `if ! command -v <tool> &>/dev/null; then` before installing
- Downloads go to `/tmp/`, cleaned up after install

## Gotchas

- **nvim-treesitter (main branch)** requires `tree-sitter-cli` (not the `tree-sitter` library formula) to compile parsers. Without it, nvim spams ENOENT errors on every startup. It is listed in the Brewfile; ensure `brew bundle` has run before opening nvim.
- **`TrackpadThreeFingerDrag`** is intentionally absent from `macos-defaults.sh`. Setting it to `true` reassigns three-finger swipes from Mission Control/spaces navigation to window drag, breaking standard macOS gesture muscle memory.

## Adding New Tools

### Ubuntu
1. Pick category: core CLI → `install/core-tools.sh`, DevOps → `install/devops-tools.sh`, GUI → `install/desktop-apps.sh`
2. Follow the existing pattern: command-exists check → install → `log_success`
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
