#!bin/bash

# Create a timestamped backup directory
BACKUP_DIR=./gnome-backup-$(date +%Y-%m-%d)
mkdir -p "$BACKUP_DIR"
cd "$BACKUP_DIR"

# Copy all installed extensions
cp -r ~/.local/share/gnome-shell/extensions ./

# Create a list of installed extensions
gnome-extensions list >installed-extensions.txt

# Export all extension configurations
dconf dump /org/gnome/shell/extensions/ >extensions-settings.conf

# Full GNOME settings backup
dconf dump /org/gnome/ >gnome-settings.conf

# Optional: Backup specific settings
dconf dump /org/gnome/desktop/wm/preferences/ >window-manager-settings.conf
dconf dump /org/gnome/desktop/interface/ >interface-settings.conf

# If you have custom themes/icons in your home directory
if [ -d ~/.themes ]; then
    tar -czf custom-themes.tar.gz ~/.themes
fi

if [ -d ~/.icons ]; then
    tar -czf custom-icons.tar.gz ~/.icons
fi

# Create a single compressed archive
cd ..
tar -czf gnome-backup-$(date +%Y-%m-%d).tar.gz gnome-backup-*

echo "✅ Complete backup saved!"
