#!/bin/bash

# Extract backup if needed
tar -xzf gnome-backup-*.tar.gz
cd gnome-backup-*/

# Copy extension files back
cp -r extensions ~/.local/share/gnome-shell/

# Set proper permissions
chmod -R 755 ~/.local/share/gnome-shell/extensions/

# Restore extension settings
dconf load /org/gnome/shell/extensions/ <extensions-settings.conf

# Restore GNOME settings
dconf load /org/gnome/ <gnome-settings.conf

# Extract custom themes
if [ -f custom-themes.tar.gz ]; then
    tar -xzf custom-themes.tar.gz -C ~/
fi

# Extract custom icons
if [ -f custom-icons.tar.gz ]; then
    tar -xzf custom-icons.tar.gz -C ~/
fi

# Restore specific settings
dconf load /org/gnome/desktop/wm/preferences/ <window-manager-settings.conf
dconf load /org/gnome/desktop/interface/ <interface-settings.conf
