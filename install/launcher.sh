#!/usr/bin/env bash
#
# Vicinae — native, Raycast-compatible launcher (Raycast replacement)
#   - installs vicinae into ~/.local via upstream's installer (self-contained AppImage)
#   - installs + enables the GNOME companion extension (vicinae@dagimg-dot)
#   - runs vicinae as a systemd --user service
#   - binds Super+Space to `vicinae toggle` (Raycast was Option+Space)
# All steps are user-level (no sudo). Wayland: enabling the GNOME extension
# may require a logout/login.
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

VICINAE_UUID="vicinae@dagimg-dot"
VICINAE_PREFIX="$HOME/.local"
# Installer layout: $PREFIX/lib/vicinae is the extracted AppImage root.
VICINAE_INPUT_SERVER="$VICINAE_PREFIX/lib/vicinae/usr/libexec/vicinae/vicinae-input-server"
export PATH="$HOME/.local/bin:$PATH"

# True if an extension is present on disk (reliable on Wayland, unlike
# `gnome-extensions list` which only reflects the running shell until relogin).
ext_installed() { [[ -f "$HOME/.local/share/gnome-shell/extensions/$1/metadata.json" ]]; }

# Register a UUID in GNOME's enabled-extensions so it auto-enables on next login.
# (`gnome-extensions enable` can't enable an extension the running shell hasn't
# loaded yet — on Wayland that's anything just installed this session.)
register_extension() {
  local uuid="$1"
  command -v gsettings &>/dev/null || return 0
  gnome-extensions enable "$uuid" 2>/dev/null || true # works once shell knows it
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

# ---- 1. Install vicinae ----
# Upstream's installer extracts the self-contained AppImage, which bundles the Qt 6
# runtime and the libexec/ daemons (vicinae-server, -input-server, -file-indexer,
# -browser-link, -data-control-server). The plain tarball ships neither, so on a
# stock GNOME desktop (no Qt6) the server died on libQt6Core.so.6.
# PREFIX keeps everything user-level — the installer only escalates when it can't
# write to $PREFIX/bin, hence the mkdir first.
install_vicinae_binary() {
  if command -v vicinae &>/dev/null; then
    log_success "vicinae already installed ($(vicinae --version 2>/dev/null | head -1))"
    return 0
  fi
  command -v jq &>/dev/null || {
    log_warn "vicinae install skipped (installer needs jq — run install/brew.sh first)"
    return 0
  }
  log_info "Installing vicinae (upstream installer, PREFIX=$VICINAE_PREFIX)..."
  mkdir -p "$VICINAE_PREFIX/bin"
  if PREFIX="$VICINAE_PREFIX" bash <(curl -fsSL https://vicinae.com/install); then
    log_success "vicinae installed"
  else
    log_warn "vicinae install failed"
    return 0
  fi
}

# ---- 1b. Grant the input server the capability it needs to paste ----
# Snippet expansion and "paste into the active app" need the input server to open
# the uinput/evdev nodes. Without the capability it silently does nothing. This was
# previously two log_warn lines asking the user to run the command by hand, which in
# practice meant it never happened on any machine.
grant_input_server_cap() {
  [[ -f "$VICINAE_INPUT_SERVER" ]] || {
    log_warn "input server not found at $VICINAE_INPUT_SERVER — skipping capability grant"
    return 0
  }
  if [[ "$(getcap "$VICINAE_INPUT_SERVER" 2>/dev/null | grep -c cap_dac_override || true)" -gt 0 ]]; then
    log_success "vicinae-input-server already has cap_dac_override"
    return 0
  fi
  command -v setcap &>/dev/null || {
    log_warn "setcap missing (apt install libcap2-bin) — snippet paste will not work"
    return 0
  }
  # Only attempt the privileged call when a cached credential exists or we are on an
  # interactive terminal that can prompt; otherwise fall back to telling the user.
  if sudo -n true 2>/dev/null || [[ -t 0 ]]; then
    if sudo setcap cap_dac_override=ep "$VICINAE_INPUT_SERVER"; then
      log_success "Granted cap_dac_override to vicinae-input-server (snippet paste enabled)"
      systemctl --user restart vicinae.service 2>/dev/null || true
      return 0
    fi
  fi
  log_warn "Could not grant the capability automatically. Run once by hand:"
  log_warn "  sudo setcap cap_dac_override=ep $VICINAE_INPUT_SERVER"
}

# ---- 2. systemd --user service ----
# The installer drops its own unit in $PREFIX/lib/systemd/user, which is NOT on
# systemd's user unit search path for a ~/.local prefix — so we keep writing ours
# to ~/.config/systemd/user (highest precedence anyway).
setup_vicinae_service() {
  local unit="$HOME/.config/systemd/user/vicinae.service"
  if [[ ! -f "$unit" ]]; then
    mkdir -p "$(dirname "$unit")"
    cat >"$unit" <<'EOF'
[Unit]
Description=Vicinae launcher server
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=%h/.local/bin/vicinae server
Restart=on-failure
RestartSec=2

[Install]
WantedBy=graphical-session.target
EOF
    log_success "Created vicinae systemd user service"
  fi
  systemctl --user daemon-reload 2>/dev/null || true
  if systemctl --user enable --now vicinae.service 2>/dev/null; then
    log_success "vicinae server enabled + started (systemd --user)"
  else
    log_warn "Could not start vicinae via systemd now — it will start on next login. Or run: vicinae server &"
  fi
}

# ---- 3. GNOME companion extension ----
install_vicinae_extension() {
  if ! command -v gnome-extensions &>/dev/null; then
    log_warn "gnome-extensions not found — skipping Vicinae GNOME extension"
    return 0
  fi
  if [[ "$(getcap "$VICINAE_INPUT_SERVER" 2>/dev/null | grep -c cap_dac_override || true)" -gt 0 ]]; then
    log_success "  input server has cap_dac_override (snippet paste works)"
  else
    log_warn "  input server lacks cap_dac_override — snippet paste will not work"
  fi
  if ext_installed "$VICINAE_UUID"; then
    log_success "Vicinae GNOME extension already installed"
  else
    log_info "Installing Vicinae GNOME companion extension..."
    local url tmp
    url="$(curl -fsSL https://api.github.com/repos/vicinaehq/gnome-extension/releases/latest 2>/dev/null \
      | jq -r '.assets[]|select(.name|test("shell-extension.*\\.zip$")).browser_download_url' 2>/dev/null | head -1 || true)"
    if [[ -z "$url" || "$url" == "null" ]]; then
      log_warn "Vicinae GNOME extension install skipped (GitHub API unavailable)"
      return 0
    fi
    tmp="$(mktemp -d)"
    curl -fsSL "$url" -o "$tmp/vicinae-ext.zip"
    gnome-extensions install --force "$tmp/vicinae-ext.zip" && log_success "Vicinae extension installed"
    rm -rf "$tmp"
  fi
  # Register so it auto-enables on next login (Wayland can't enable it live this session).
  register_extension "$VICINAE_UUID"
  log_success "Vicinae extension will be active after logout/login"
}

# ---- 4. Global shortcut: Super+Space -> vicinae toggle ----
bind_vicinae_shortcut() {
  command -v gsettings &>/dev/null || {
    log_warn "gsettings missing — skipping shortcut"
    return 0
  }
  local base="org.gnome.settings-daemon.plugins.media-keys"
  local path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/vicinae/"
  local schema="${base}.custom-keybinding:${path}"

  # Free Super+Space (GNOME default = switch-input-source) so it can launch Vicinae.
  gsettings set org.gnome.desktop.wm.keybindings switch-input-source "[]" 2>/dev/null || true
  gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "[]" 2>/dev/null || true

  local list
  list="$(gsettings get "$base" custom-keybindings 2>/dev/null || echo "@as []")"
  if [[ "$list" != *"$path"* ]]; then
    if [[ "$list" == "@as []" || "$list" == "[]" ]]; then
      gsettings set "$base" custom-keybindings "['$path']"
    else
      gsettings set "$base" custom-keybindings "${list%]*}, '$path']"
    fi
  fi
  gsettings set "$schema" name "Vicinae"
  gsettings set "$schema" command "$HOME/.local/bin/vicinae toggle"
  gsettings set "$schema" binding "<Super>space"
  log_success "Bound Super+Space -> vicinae toggle"
}

# ---- 5. Verify ----
verify_launcher() {
  log_info "Verifying Vicinae..."
  local ok=1
  command -v vicinae &>/dev/null && log_success "  vicinae binary on PATH" || {
    log_warn "  vicinae binary missing"
    ok=0
  }
  # The binary alone is not proof of a working launcher — it used to pass while the
  # server was crashing on a missing Qt runtime. Check the daemon actually runs.
  if systemctl --user is-active --quiet vicinae.service 2>/dev/null; then
    log_success "  vicinae.service active"
  else
    log_warn "  vicinae.service not active — first boot may not have started it; check:"
    log_warn "    systemctl --user status vicinae.service"
  fi
  if ext_installed "$VICINAE_UUID"; then
    log_success "  GNOME extension installed (enables on next login)"
  else
    log_warn "  GNOME extension not installed"
    ok=0
  fi
  ((ok == 1)) && log_success "VERIFY PASS: Vicinae ready (press Super+Space; logout/login if extension inactive)" \
    || log_warn "VERIFY: finish remaining Vicinae steps (see warnings above)"
}

install_vicinae_binary
grant_input_server_cap
setup_vicinae_service
install_vicinae_extension
bind_vicinae_shortcut
verify_launcher
