#!/usr/bin/env bash
#
# Desktop applications (GUI). Homebrew casks are macOS-only, so GUI apps come
# from apt/deb/snap here. Selection mirrors the user's daily set:
#   Ghostty, VS Code, Chrome, Slack, WhatsApp, drawio, Standard Notes,
#   Beekeeper Studio, OpenLens. (Spotify/Bitwarden intentionally skipped.)
#   Also intentionally skipped: Android Studio + Android tooling (no active
#   need on this stack), the codex CLI cask (not part of this workflow), and
#   the Stats menubar app (no GNOME analog configured — btop covers CLI
#   monitoring). Decisions, not oversights.
# Sourced by bootstrap.sh (inherits log_* helpers) or runnable standalone.
#

if ! declare -F log_info >/dev/null 2>&1; then
    set -euo pipefail
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
    log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
    log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
    log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
    log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
fi

apt_clean() { sudo rm -rf /var/cache/apt/*.bin 2>/dev/null || true; }

# ============================================
# apt essentials (clipboard, notifications, GNOME tooling)
# ============================================
log_info "Installing apt essentials (wl-clipboard, xclip, notify, GNOME tools)..."
sudo apt-get install -y wl-clipboard xclip libnotify-bin unzip \
    gnome-tweaks gnome-shell-extension-manager dconf-editor
log_success "apt essentials installed"

# ============================================
# GHOSTTY (maintained PPA — publishes for the current Ubuntu releases, 26.04
# included; if the PPA ever lags, `apt install ghostty` from the 26.04 archive works)
# ============================================
log_info "Installing Ghostty..."
if ! command -v ghostty &>/dev/null; then
    sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
    apt_clean; sudo apt-get update
    sudo apt-get install -y ghostty
fi
command -v ghostty &>/dev/null && log_success "Ghostty installed" || log_warn "Ghostty install failed"

# ============================================
# VISUAL STUDIO CODE (Microsoft repo)
# ============================================
log_info "Installing Visual Studio Code..."
if ! command -v code &>/dev/null; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
        | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f /tmp/packages.microsoft.gpg
    apt_clean; sudo apt-get update
    sudo apt-get install -y code
fi
log_success "Visual Studio Code installed"

# ============================================
# GOOGLE CHROME (.deb)
# ============================================
log_info "Installing Google Chrome..."
if ! command -v google-chrome &>/dev/null; then
    wget -q -O /tmp/chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    sudo apt-get install -y /tmp/chrome.deb
    rm -f /tmp/chrome.deb
fi
log_success "Google Chrome installed"

# ============================================
# SNAP apps: Slack, WhatsApp, drawio, Standard Notes, Beekeeper Studio
# ============================================
install_snap() { # name [extra-flags]
    local name="$1"; shift || true
    if snap list "$name" &>/dev/null 2>&1; then
        log_success "snap:$name already installed"
    else
        log_info "Installing snap:$name..."
        sudo snap install "$name" "$@" && log_success "snap:$name installed" || log_warn "snap:$name failed"
    fi
}
command -v snap &>/dev/null || { log_info "Installing snapd..."; sudo apt-get install -y snapd; }
install_snap slack
install_snap whatsapp-desktop-client
install_snap drawio
install_snap standard-notes
install_snap beekeeper-studio

# ============================================
# OpenLens (Kubernetes IDE) — GitHub release .deb
# Unmaintained (last release 2023); k9s (Brewfile) covers the same workflow.
# ============================================
log_info "Installing OpenLens..."
if ! command -v open-lens &>/dev/null && ! dpkg -l 2>/dev/null | grep -qi openlens; then
    url="$(curl -fsSL https://api.github.com/repos/MuhammedKalkan/OpenLens/releases/latest 2>/dev/null \
          | jq -r '.assets[]|select(.name|test("amd64\\.deb$")).browser_download_url' 2>/dev/null | head -1 || true)"
    if [[ -n "$url" && "$url" != "null" ]]; then
        wget -q -O /tmp/openlens.deb "$url"
        sudo apt-get install -y /tmp/openlens.deb && log_success "OpenLens installed" || log_warn "OpenLens install failed"
        rm -f /tmp/openlens.deb
    else
        log_warn "OpenLens install skipped (GitHub API unavailable)"
    fi
else
    log_success "OpenLens already installed"
fi

# ============================================
# Verify
# ============================================
log_info "Verifying desktop apps..."
for c in ghostty code google-chrome; do
    command -v "$c" &>/dev/null && log_success "  $c present" || log_warn "  $c missing"
done
for s in slack whatsapp-desktop-client drawio standard-notes beekeeper-studio; do
    snap list "$s" &>/dev/null 2>&1 && log_success "  snap:$s present" || log_warn "  snap:$s missing"
done
log_success "Desktop applications step complete"
