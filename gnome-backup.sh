#!/bin/bash
#
# GNOME Settings Backup Script
# Creates a compressed backup of GNOME extensions and settings
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_NAME="gnome-backup-$(date +%Y-%m-%d)"
TEMP_DIR=$(mktemp -d)
BACKUP_DIR="$TEMP_DIR/$BACKUP_NAME"

mkdir -p "$BACKUP_DIR"
cd "$BACKUP_DIR"

echo "Backing up GNOME extensions and settings..."

# Copy all installed extensions
if [ -d ~/.local/share/gnome-shell/extensions ]; then
    cp -r ~/.local/share/gnome-shell/extensions ./
fi

# Create a list of installed extensions
gnome-extensions list > installed-extensions.txt 2>/dev/null || true

# Export all extension configurations
dconf dump /org/gnome/shell/extensions/ > extensions-settings.conf

# Full GNOME settings backup
dconf dump /org/gnome/ > gnome-settings.conf

# Backup specific settings
dconf dump /org/gnome/desktop/wm/preferences/ > window-manager-settings.conf
dconf dump /org/gnome/desktop/interface/ > interface-settings.conf

# Backup custom themes/icons if they exist
[ -d ~/.themes ] && tar -czf custom-themes.tar.gz -C ~ .themes
[ -d ~/.icons ] && tar -czf custom-icons.tar.gz -C ~ .icons

# Create compressed archive in backup/ directory
mkdir -p "$SCRIPT_DIR/backup"
cd "$TEMP_DIR"
tar -czf "$SCRIPT_DIR/backup/$BACKUP_NAME.tar.gz" "$BACKUP_NAME"

# Cleanup temporary directory
rm -rf "$TEMP_DIR"

echo "Backup saved to: backup/$BACKUP_NAME.tar.gz"
