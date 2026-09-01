#!/usr/bin/env bash
#
# GNOME desktop tuning (the Linux equivalent of mac/macos-defaults.sh):
#   - gsettings tweaks: fast key repeat, tap-to-click, dark mode, dock, nautilus
#   - built-in half/maximize tiling keybindings (Super+arrows)
#   - desktop polish: dock favourites, monospace font, workspaces, input sources
#   - JetBrains Mono Nerd Font (terminal/editor parity with the Mac)
#
# Shell EXTENSIONS (Tiling Shell, Blur My Shell, TopHat, ...) are installed by
# install/gnome-extensions.sh — this module only touches core GNOME schemas.
#
# ORDERING: must run AFTER install/launcher.sh. bind_vicinae_shortcut() there
# clears switch-input-source to free Super+Space for Vicinae; apply_input_sources()
# below then re-binds layout switching to Super+Shift+Space. Reverse the order and
# the launcher wipes the binding.
#
# All steps are user-level (no sudo).
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

# `producer | grep -q PATTERN` is a trap under `set -o pipefail`: grep -q exits at
# the first match, the producer dies with SIGPIPE, and the pipeline reports 141 —
# so the test reads FALSE precisely when the thing IS present. That is why every
# bootstrap run re-downloaded the Nerd Font archive. grep -c drains its input.
# Usage: <producer> | pipe_matches <grep-flags> <pattern>
pipe_matches() {
  local flags="$1" pattern="$2" n
  n="$(grep -c "$flags" -- "$pattern" || true)"
  [[ "${n:-0}" -gt 0 ]]
}

# Set a gsettings key only if its schema exists (avoids errors across versions).
gset() {
  local schema="$1" key="$2" value="$3"
  if gsettings list-schemas 2>/dev/null | pipe_matches -xF "$schema"; then
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

# ---- 3. Desktop polish (scrolling, dock favourites, fonts, workspaces) ----
# The old machine's favourite-apps list is deliberately NOT copied from
# backup/gnome-backup-2026-01-20.tar.gz: it names employer-internal apps, and this
# repo must stay generic. This is the equivalent generic set.
apply_desktop_polish() {
  log_info "Applying desktop polish (dock favourites, fonts, workspaces)..."

  # Dock favourites, in order. Guarded: an app that is not installed is skipped
  # rather than left as a dead icon in the dock.
  local wanted=(
    "com.mitchellh.ghostty.desktop"
    "google-chrome.desktop"
    "code.desktop"
    "slack_slack.desktop"
    "whatsapp-desktop-client_whatsapp-desktop-client.desktop"
    "standard-notes_standard-notes.desktop"
    "org.gnome.Nautilus.desktop"
    "org.gnome.Settings.desktop"
  )
  local found=() d dir
  for d in "${wanted[@]}"; do
    for dir in "$HOME/.local/share/applications" /usr/share/applications \
      /var/lib/snapd/desktop/applications /var/lib/flatpak/exports/share/applications; do
      if [[ -f "$dir/$d" ]]; then
        found+=("'$d'")
        break
      fi
    done
  done
  if ((${#found[@]} > 0)); then
    local joined
    joined="$(
      IFS=,
      echo "${found[*]}"
    )"
    gset org.gnome.shell favorite-apps "[${joined//,/, }]"
    log_success "  dock favourites set (${#found[@]} of ${#wanted[@]} apps present)"
  fi

  # Overlay scrolling OFF. This is NOT cosmetic and is not about scrollbar looks:
  # overlay scrolling is what enables GTK's kinetic/momentum scroll accumulation, and
  # with it on, two-finger touchpad scrolling builds speed until it is unusable on this
  # hardware. `false` gives fixed-step scrolling. Verified by A/B on the live machine —
  # do not "tidy" this away again.
  gset org.gnome.desktop.interface overlay-scrolling false

  # Monospace font: match Ghostty/Neovim instead of the Ubuntu default. The font
  # itself is installed by install_nerd_font() below; gsettings tolerates setting a
  # font name before the file exists, and it resolves after fc-cache.
  gset org.gnome.desktop.interface monospace-font-name "'JetBrainsMono Nerd Font 11'"

  # Workspaces: dynamic, primary monitor only — matches the previous machine.
  gset org.gnome.mutter dynamic-workspaces true
  gset org.gnome.mutter workspaces-only-on-primary true

  log_success "Desktop polish applied"
}

# ---- 3b. Keyboard layouts (US + Hebrew) ----
# MUST run after install/launcher.sh — see the ORDERING note in this file's header.
# bind_vicinae_shortcut() clears switch-input-source to free Super+Space; the layout
# toggle moves to Super+Shift+Space (what the previous machine used).
apply_input_sources() {
  log_info "Setting keyboard layouts (US + Hebrew, toggle on Super+Shift+Space)..."
  gset org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'il')]"
  gset org.gnome.desktop.wm.keybindings switch-input-source "['<Super><Shift>space']"
  gset org.gnome.desktop.wm.keybindings switch-input-source-backward "@as []"
  log_success "Keyboard layouts set"
}

# ---- 4. JetBrains Mono Nerd Font ----
install_nerd_font() {
  local fontdir="$HOME/.local/share/fonts/JetBrainsMonoNerd"
  if fc-list 2>/dev/null | pipe_matches -i "JetBrainsMono Nerd Font"; then
    log_success "JetBrains Mono Nerd Font already installed"
    return 0
  fi
  log_info "Installing JetBrains Mono Nerd Font..."
  mkdir -p "$fontdir"
  local url tmp
  url="$(curl -fsSL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest 2>/dev/null \
    | jq -r '.assets[]|select(.name=="JetBrainsMono.tar.xz").browser_download_url' 2>/dev/null | head -1 || true)"
  if [[ -z "$url" || "$url" == "null" ]]; then
    log_warn "JetBrains Mono Nerd Font install skipped (GitHub API unavailable)"
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
  echo "  monospace font      : $(gsettings get org.gnome.desktop.interface monospace-font-name 2>/dev/null)"
  echo "  input sources       : $(gsettings get org.gnome.desktop.input-sources sources 2>/dev/null)"
  fc-cache -f >/dev/null 2>&1 || true # ensure the cache reflects a just-installed font
  if fc-list 2>/dev/null | pipe_matches -i "JetBrainsMono Nerd Font" \
    || ls "$HOME"/.local/share/fonts/JetBrainsMonoNerd/*.ttf >/dev/null 2>&1; then
    log_success "  JetBrains Mono Nerd Font present"
  else
    log_warn "  JetBrains Mono Nerd Font missing"
  fi
  log_success "VERIFY done (extensions are verified by install/gnome-extensions.sh)"
}

apply_gsettings
apply_tiling_keys
apply_desktop_polish
apply_input_sources
install_nerd_font
verify_gnome
