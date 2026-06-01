#!/usr/bin/env bash
#
# GNOME desktop tuning (the Linux equivalent of mac/macos-defaults.sh):
#   - gsettings tweaks: fast key repeat, tap-to-click, dark mode, dock, nautilus
#   - built-in half/maximize tiling keybindings (Super+arrows)
#   - Tiling Shell extension (FancyZones-style layouts + advanced shortcuts)
#   - JetBrains Mono Nerd Font (terminal/editor parity with the Mac)
# All steps are user-level (no sudo). Wayland: enabling a freshly installed
# extension may require a logout/login.
# Sourced by bootstrap.sh (inherits log_* helpers) or runnable standalone.
#

if ! declare -F log_info >/dev/null 2>&1; then
  set -euo pipefail
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
  log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
  log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
  log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
  log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
fi

TILING_UUID="tilingshell@ferrarodomenico.com"

# True if an extension is present on disk (reliable on Wayland, unlike
# `gnome-extensions list` which only reflects the running shell until relogin).
ext_installed() { [[ -f "$HOME/.local/share/gnome-shell/extensions/$1/metadata.json" ]]; }

# Register a UUID in GNOME's enabled-extensions so it auto-enables on next login.
register_extension() {
  local uuid="$1"
  command -v gsettings &>/dev/null || return 0
  gnome-extensions enable "$uuid" 2>/dev/null || true
  local cur new
  cur="$(gsettings get org.gnome.shell enabled-extensions 2>/dev/null || echo '@as []')"
  if command -v python3 &>/dev/null; then
    new="$(
      python3 - "$cur" "$uuid" <<'PY'
import sys, ast
cur, uuid = sys.argv[1].strip(), sys.argv[2]
try: lst = ast.literal_eval(cur) if cur and cur != '@as []' else []
except Exception: lst = []
if uuid not in lst: lst.append(uuid)
print("[" + ", ".join("'%s'" % x for x in lst) + "]")
PY
    )"
    gsettings set org.gnome.shell enabled-extensions "$new" 2>/dev/null || true
  fi
}

# Set a gsettings key only if its schema exists (avoids errors across versions).
gset() {
  local schema="$1" key="$2" value="$3"
  if gsettings list-schemas 2>/dev/null | grep -qx "$schema"; then
    gsettings set "$schema" "$key" "$value" 2>/dev/null \
      && return 0 || log_warn "  could not set $schema $key"
  fi
}

# ---- 1. System defaults (macos-defaults.sh equivalents) ----
apply_gsettings() {
  log_info "Applying GNOME desktop settings..."

  # Keyboard: fast key repeat, short delay (mac KeyRepeat=2 / InitialKeyRepeat=15)
  gset org.gnome.desktop.peripherals.keyboard repeat true
  gset org.gnome.desktop.peripherals.keyboard repeat-interval "uint32 20"
  gset org.gnome.desktop.peripherals.keyboard delay "uint32 200"

  # Trackpad: tap-to-click (mac trackpad Clicking=true)
  gset org.gnome.desktop.peripherals.touchpad tap-to-click true
  gset org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true

  # Interface: dark mode (Tokyo Night parity), battery %, weekday, no hot corner
  gset org.gnome.desktop.interface color-scheme "'prefer-dark'"
  gset org.gnome.desktop.interface gtk-theme "'Yaru-dark'"
  gset org.gnome.desktop.interface show-battery-percentage true
  gset org.gnome.desktop.interface clock-show-weekday true
  gset org.gnome.desktop.interface enable-hot-corners false

  # Window buttons: include minimize + maximize (mac-like)
  gset org.gnome.desktop.wm.preferences button-layout "'appmenu:minimize,maximize,close'"

  # Nautilus: list view + show hidden files (mac Finder AppleShowAllFiles)
  gset org.gnome.nautilus.preferences default-folder-viewer "'list-view'"
  gset org.gtk.Settings.FileChooser show-hidden true
  gset org.gtk.gtk4.Settings.FileChooser show-hidden true

  # Dock: autohide (mac Dock autohide=true)
  gset org.gnome.shell.extensions.dash-to-dock dock-fixed false
  gset org.gnome.shell.extensions.dash-to-dock autohide true
  gset org.gnome.shell.extensions.dash-to-dock intellihide true

  log_success "GNOME desktop settings applied"
}

# ---- 2. Built-in tiling keybindings (reliable halves + maximize) ----
apply_tiling_keys() {
  log_info "Setting half/maximize tiling shortcuts (Super+arrows)..."
  gset org.gnome.mutter edge-tiling true
  gset org.gnome.mutter.keybindings toggle-tiled-left "['<Super>Left']"
  gset org.gnome.mutter.keybindings toggle-tiled-right "['<Super>Right']"
  gset org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"
  gset org.gnome.desktop.wm.keybindings unmaximize "['<Super>Down']"
  log_success "Tiling shortcuts set (quarter-tiling + FancyZones via Tiling Shell prefs)"
}

# ---- 3. Tiling Shell extension (advanced layouts) ----
install_tiling_shell() {
  command -v gnome-extensions &>/dev/null || {
    log_warn "gnome-extensions missing — skipping Tiling Shell"
    return 0
  }
  if ext_installed "$TILING_UUID"; then
    log_success "Tiling Shell already installed"
  else
    log_info "Installing Tiling Shell..."
    local url tmp
    # Pick the current-GNOME asset (the bare uuid zip), not the legacy GNOME.42-44 one.
    url="$(curl -fsSL https://api.github.com/repos/domferr/tilingshell/releases/latest \
      | jq -r '.assets[]|select(.name|test("^tilingshell@ferrarodomenico.com\\.zip$")).browser_download_url' | head -1)"
    if [[ -z "$url" ]]; then
      log_warn "could not resolve Tiling Shell release"
      return 0
    fi
    tmp="$(mktemp -d)"
    curl -fsSL "$url" -o "$tmp/tilingshell.zip"
    gnome-extensions install --force "$tmp/tilingshell.zip" && log_success "Tiling Shell installed"
    rm -rf "$tmp"
  fi
  # Register so it auto-enables on next login (Wayland can't enable it live this session).
  register_extension "$TILING_UUID"
  log_success "Tiling Shell will be active after logout/login"
}

# ---- 4. JetBrains Mono Nerd Font ----
install_nerd_font() {
  local fontdir="$HOME/.local/share/fonts/JetBrainsMonoNerd"
  if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
    log_success "JetBrains Mono Nerd Font already installed"
    return 0
  fi
  log_info "Installing JetBrains Mono Nerd Font..."
  mkdir -p "$fontdir"
  local url tmp
  url="$(curl -fsSL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
    | jq -r '.assets[]|select(.name=="JetBrainsMono.tar.xz").browser_download_url' | head -1)"
  if [[ -z "$url" ]]; then
    log_warn "could not resolve Nerd Font release"
    return 0
  fi
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/JetBrainsMono.tar.xz"
  tar -xJf "$tmp/JetBrainsMono.tar.xz" -C "$fontdir"
  rm -rf "$tmp"
  fc-cache -f "$fontdir" >/dev/null 2>&1 || fc-cache -f >/dev/null 2>&1
  log_success "JetBrains Mono Nerd Font installed"
}

# ---- 5. Verify ----
verify_gnome() {
  log_info "Verifying GNOME setup..."
  echo "  key repeat-interval : $(gsettings get org.gnome.desktop.peripherals.keyboard repeat-interval 2>/dev/null)"
  echo "  tap-to-click        : $(gsettings get org.gnome.desktop.peripherals.touchpad tap-to-click 2>/dev/null)"
  echo "  color-scheme        : $(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)"
  if ext_installed "$TILING_UUID"; then
    log_success "  Tiling Shell installed (enables on next login)"
  else
    log_warn "  Tiling Shell not installed"
  fi
  fc-cache -f >/dev/null 2>&1 || true # ensure the cache reflects a just-installed font
  if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font" \
    || ls "$HOME"/.local/share/fonts/JetBrainsMonoNerd/*.ttf >/dev/null 2>&1; then
    log_success "  JetBrains Mono Nerd Font present"
  else
    log_warn "  JetBrains Mono Nerd Font missing"
  fi
  log_success "VERIFY done (logout/login if extensions are inactive)"
}

apply_gsettings
apply_tiling_keys
install_tiling_shell
install_nerd_font
verify_gnome
