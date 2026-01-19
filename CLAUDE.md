# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

Ubuntu workstation bootstrap automation for DevOps engineers. Installs tools, restores dotfiles, and configures GNOME desktop including the Tiling Shell extension for window management.

## Architecture

**Entry point:** `bootstrap.sh` - Interactive menu that sources modular install scripts.

**Install scripts** (`install/`):
- `core-tools.sh` - CLI tools (eza, bat, fzf, lazygit, starship, gh)
- `devops-tools.sh` - Docker, kubectl, helm, OpenLens, Terraform, Terragrunt, AWS CLI, GCloud SDK, ArgoCD, Trivy
- `desktop-apps.sh` - VS Code, Chrome, Spotify, WhatsApp, Alacritty, Ulauncher
- `restore-configs.sh` - Copies dotfiles to `~/.config/` and restores GNOME settings from backup

**Config files:** Stored in `configs/`, `bash/`, `alacritty/`, `nvim/`, `vim/` - restored via symlink/copy by `restore-configs.sh`.

**GNOME backup:** `gnome-backup.sh` creates timestamped archives in `backup/` containing extensions and dconf settings.

## Key Commands

```bash
# Test bootstrap on fresh Ubuntu
./bootstrap.sh

# Syntax check all scripts
for f in *.sh install/*.sh; do bash -n "$f" && echo "$f: OK"; done

# Create new GNOME backup before migration
./gnome-backup.sh
```

## Script Conventions

- All scripts use `set -euo pipefail` (fail on error)
- Log functions: `log_info`, `log_success`, `log_warn`, `log_error` (defined in bootstrap.sh, available to sourced scripts)
- Before every `apt update`, clear cache to prevent corruption: `sudo rm -rf /var/cache/apt/*.bin 2>/dev/null || true`
- Check if tool exists before installing: `if ! command -v <tool> &>/dev/null; then`
- Use `/tmp/` for downloaded installers, clean up after

## Adding New Tools

1. Determine category: core CLI → `core-tools.sh`, DevOps → `devops-tools.sh`, GUI → `desktop-apps.sh`
2. Follow existing pattern: check if installed, download/install, log success
3. If tool has config file, add it to appropriate config directory and update `restore-configs.sh`
