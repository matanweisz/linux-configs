#!/usr/bin/env bash
#
# Desktop Applications Installation
# GUI apps for productivity and development
#

# ============================================
# GOOGLE CHROME
# ============================================
log_info "Installing Google Chrome..."
if ! command -v google-chrome &>/dev/null; then
    wget -q -O /tmp/chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    sudo apt install -y /tmp/chrome.deb
    rm /tmp/chrome.deb
fi
log_success "Google Chrome installed"

# ============================================
# SPOTIFY
# ============================================
log_info "Installing Spotify..."
if ! snap list spotify &>/dev/null 2>&1; then
    sudo snap install spotify
fi
log_success "Spotify installed"

# ============================================
# WHATSAPP (via snap)
# ============================================
log_info "Installing WhatsApp..."
if ! snap list whatsapp-desktop-client &>/dev/null 2>&1; then
    sudo snap install whatsapp-desktop-client
fi
log_success "WhatsApp installed"

# ============================================
# DRAW.IO (via snap)
# ============================================
log_info "Installing Draw.io..."
if ! snap list drawio &>/dev/null 2>&1; then
    sudo snap install drawio
fi
log_success "Draw.io installed"

# ============================================
# Bitwarden (via snap)
# ============================================
log_info "Installing Bitwarden..."
if ! snap list bitwarden &>/dev/null 2>&1; then
    sudo snap install bitwarden
fi
log_success "Bitwarden installed"

# ============================================
# ALACRITTY TERMINAL
# ============================================
log_info "Installing Alacritty terminal..."
if ! command -v alacritty &>/dev/null; then
    sudo add-apt-repository -y ppa:aslatter/ppa
    sudo rm -rf /var/cache/apt/*.bin 2>/dev/null || true
    sudo apt update
    sudo apt install -y alacritty
fi
log_success "Alacritty installed"

# ============================================
# ULAUNCHER (Application Launcher)
# ============================================
log_info "Installing Ulauncher..."
if ! command -v ulauncher &>/dev/null; then
    sudo add-apt-repository -y ppa:agornostal/ulauncher
    sudo rm -rf /var/cache/apt/*.bin 2>/dev/null || true
    sudo apt update
    sudo apt install -y ulauncher
fi
log_success "Ulauncher installed"

# ============================================
# FONTS (Nerd Fonts for terminal)
# ============================================
log_info "Installing Nerd Fonts..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    curl -sLo /tmp/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    unzip -q /tmp/JetBrainsMono.zip -d "$FONT_DIR"
    rm /tmp/JetBrainsMono.zip
    fc-cache -fv
fi
log_success "Nerd Fonts installed"

# ============================================
# GNOME TWEAKS (for GNOME desktop)
# ============================================
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
    log_info "Installing GNOME tools..."
    sudo apt install -y gnome-tweaks gnome-shell-extension-manager dconf-editor
    log_success "GNOME tools installed"
fi

log_success "Desktop applications installation complete"
