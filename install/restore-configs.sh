#!/usr/bin/env bash
#
# Configuration Restoration Script
# Restores dotfiles, shell configs, and GNOME settings
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ============================================
# SHELL CONFIGURATION
# ============================================
log_info "Restoring shell configuration..."

# Backup existing files
backup_if_exists() {
    local file="$1"
    if [ -f "$file" ] && [ ! -L "$file" ]; then
        mv "$file" "${file}.backup.$(date +%Y%m%d%H%M%S)"
        log_info "Backed up existing $file"
    fi
}

# Copy bash aliases
if [ -f "$SCRIPT_DIR/bash/.bash_aliases" ]; then
    backup_if_exists ~/.bash_aliases
    cp "$SCRIPT_DIR/bash/.bash_aliases" ~/.bash_aliases
    log_success "Restored .bash_aliases"
fi

# Create .bashrc if needed (with starship and aliases sourcing)
if ! grep -q "starship init bash" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'EOF'

# Editor
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"

# Source bash aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Starship prompt
eval "$(starship init bash)"

# PATH
export PATH="$HOME/.local/bin:$PATH"

# Cargo (Rust)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
EOF
    log_success "Updated .bashrc with starship and aliases"
fi

# ============================================
# STARSHIP PROMPT
# ============================================
log_info "Restoring Starship configuration..."
mkdir -p ~/.config
if [ -f "$SCRIPT_DIR/configs/starship.toml" ]; then
    backup_if_exists ~/.config/starship.toml
    cp "$SCRIPT_DIR/configs/starship.toml" ~/.config/starship.toml
    log_success "Restored starship.toml"
fi

# ============================================
# GIT CONFIGURATION
# ============================================
log_info "Restoring Git configuration..."
if [ -f "$SCRIPT_DIR/configs/.gitconfig" ]; then
    # Only copy aliases and settings, not user info
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global pull.rebase true
    log_success "Restored git aliases"
fi

# ============================================
# NEOVIM CONFIGURATION
# ============================================
log_info "Restoring Neovim configuration..."
mkdir -p ~/.config/nvim
if [ -f "$SCRIPT_DIR/nvim/init.lua" ]; then
    backup_if_exists ~/.config/nvim/init.lua
    cp "$SCRIPT_DIR/nvim/init.lua" ~/.config/nvim/init.lua
    log_success "Restored nvim/init.lua"
fi

# ============================================
# VIM CONFIGURATION
# ============================================
log_info "Restoring Vim configuration..."
if [ -f "$SCRIPT_DIR/vim/.vimrc" ]; then
    backup_if_exists ~/.vimrc
    cp "$SCRIPT_DIR/vim/.vimrc" ~/.vimrc

    # Install vim-plug if not present
    if [ ! -f ~/.vim/autoload/plug.vim ]; then
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        log_info "Installed vim-plug"
    fi
    log_success "Restored .vimrc"
fi

# ============================================
# ALACRITTY CONFIGURATION
# ============================================
log_info "Restoring Alacritty configuration..."
mkdir -p ~/.config/alacritty
if [ -d "$SCRIPT_DIR/alacritty" ]; then
    for file in "$SCRIPT_DIR/alacritty"/*.toml; do
        [ -f "$file" ] && cp "$file" ~/.config/alacritty/
    done
    log_success "Restored Alacritty config"
fi

# ============================================
# BTOP CONFIGURATION
# ============================================
log_info "Restoring btop configuration..."
mkdir -p ~/.config/btop/themes
if [ -f "$SCRIPT_DIR/configs/btop/btop.conf" ]; then
    cp "$SCRIPT_DIR/configs/btop/btop.conf" ~/.config/btop/btop.conf
    log_success "Restored btop.conf"
fi
if [ -d "$SCRIPT_DIR/configs/btop/themes" ]; then
    cp "$SCRIPT_DIR/configs/btop/themes"/* ~/.config/btop/themes/ 2>/dev/null || true
    log_success "Restored btop themes"
fi

# ============================================
# GNOME EXTENSIONS & SETTINGS
# ============================================
if [[ "${XDG_CURRENT_DESKTOP:-}" == *"GNOME"* ]]; then
    log_info "Restoring GNOME extensions and settings..."

    # Find the most recent GNOME backup
    GNOME_BACKUP=$(ls -t "$SCRIPT_DIR"/backup/gnome-backup-*.tar.gz 2>/dev/null | head -1)

    if [ -n "$GNOME_BACKUP" ] && [ -f "$GNOME_BACKUP" ]; then
        # Extract backup
        TEMP_DIR=$(mktemp -d)
        tar -xzf "$GNOME_BACKUP" -C "$TEMP_DIR"
        BACKUP_DIR=$(ls -d "$TEMP_DIR"/gnome-backup-* 2>/dev/null | head -1)

        if [ -d "$BACKUP_DIR" ]; then
            # Copy extensions
            if [ -d "$BACKUP_DIR/extensions" ]; then
                mkdir -p ~/.local/share/gnome-shell/extensions
                cp -r "$BACKUP_DIR/extensions"/* ~/.local/share/gnome-shell/extensions/
                chmod -R 755 ~/.local/share/gnome-shell/extensions/
                log_success "Restored GNOME extensions"
            fi

            # Restore GNOME settings
            if [ -f "$BACKUP_DIR/gnome-settings.conf" ]; then
                dconf load /org/gnome/ < "$BACKUP_DIR/gnome-settings.conf"
                log_success "Restored GNOME settings"
            fi

            # Restore extension settings
            if [ -f "$BACKUP_DIR/extensions-settings.conf" ]; then
                dconf load /org/gnome/shell/extensions/ < "$BACKUP_DIR/extensions-settings.conf"
                log_success "Restored extension settings"
            fi

            # Restore wallpaper/background image
            if [ -d "$BACKUP_DIR/wallpaper" ]; then
                WALLPAPER_BACKUP_DIR="$HOME/.local/share/backgrounds"
                mkdir -p "$WALLPAPER_BACKUP_DIR"

                # Copy wallpaper file
                WALLPAPER_FILE=$(ls "$BACKUP_DIR/wallpaper"/*.{jpg,jpeg,png,webp} 2>/dev/null | head -1)
                if [ -f "$WALLPAPER_FILE" ]; then
                    WALLPAPER_NAME=$(basename "$WALLPAPER_FILE")
                    cp "$WALLPAPER_FILE" "$WALLPAPER_BACKUP_DIR/$WALLPAPER_NAME"

                    # Set as wallpaper
                    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_BACKUP_DIR/$WALLPAPER_NAME"
                    gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_BACKUP_DIR/$WALLPAPER_NAME"
                    log_success "Restored wallpaper"
                fi
            fi
        fi

        rm -rf "$TEMP_DIR"
        log_info "NOTE: Log out and back in for GNOME extensions to take effect"
    else
        log_warn "No GNOME backup found. Run gnome-backup.sh on current machine first."
    fi
fi

# ============================================
# SSH DIRECTORY SETUP
# ============================================
log_info "Setting up SSH directory..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

if [ ! -f ~/.ssh/config ]; then
    cat > ~/.ssh/config << 'EOF'
# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_ed25519
    AddKeysToAgent yes
    IdentitiesOnly yes
EOF
    chmod 644 ~/.ssh/config
    log_info "Created SSH config template. Generate keys with: ssh-keygen -t ed25519 -f ~/.ssh/github_ed25519"
fi

# Create ssh_keys directory for EC2 keys
mkdir -p ~/ssh_keys
chmod 700 ~/ssh_keys

log_success "Configuration restoration complete"
