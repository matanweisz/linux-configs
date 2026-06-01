#!/usr/bin/env bash
#
# Vicinae — native, Raycast-compatible launcher (Raycast replacement)
#   - installs the vicinae binary to ~/.local/bin (latest GitHub release)
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

# ---- 1. Install vicinae binary ----
install_vicinae_binary() {
  if command -v vicinae &>/dev/null; then
    log_success "vicinae already installed ($(vicinae --version 2>/dev/null | head -1))"
    return 0
  fi
  log_info "Installing vicinae (latest GitHub release)..."
  mkdir -p "$HOME/.local/bin"
  local url tmp
  url="$(curl -fsSL https://api.github.com/repos/vicinaehq/vicinae/releases/latest \
    | jq -r '.assets[]|select(.name|test("linux-x86_64.*tar\\.gz$")).browser_download_url' | head -1)"
  if [[ -z "$url" ]]; then
    log_error "could not resolve vicinae release asset"
    return 1
  fi
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/vicinae.tar.gz"
  tar -xzf "$tmp/vicinae.tar.gz" -C "$tmp"
  if [[ -d "$tmp/bin" ]]; then
    # prefix-style tarball (bin/ lib/ share/) -> install into ~/.local
    cp -a "$tmp/bin/." "$HOME/.local/bin/"
    [[ -d "$tmp/lib" ]] && {
      mkdir -p "$HOME/.local/lib"
      cp -a "$tmp/lib/." "$HOME/.local/lib/"
    }
    [[ -d "$tmp/share" ]] && {
      mkdir -p "$HOME/.local/share"
      cp -a "$tmp/share/." "$HOME/.local/share/"
    }
  else
    local bin
    bin="$(find "$tmp" -type f -name vicinae | head -1)"
    [[ -n "$bin" ]] && cp "$bin" "$HOME/.local/bin/vicinae"
  fi
  chmod +x "$HOME/.local/bin/vicinae" 2>/dev/null || true
  rm -rf "$tmp"
  command -v vicinae &>/dev/null && log_success "vicinae installed" || {
    log_error "vicinae install failed"
    return 1
  }
}

# ---- 2. systemd --user service ----
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
  if ext_installed "$VICINAE_UUID"; then
    log_success "Vicinae GNOME extension already installed"
  else
    log_info "Installing Vicinae GNOME companion extension..."
    local url tmp
    url="$(curl -fsSL https://api.github.com/repos/vicinaehq/gnome-extension/releases/latest \
      | jq -r '.assets[]|select(.name|test("shell-extension.*\\.zip$")).browser_download_url' | head -1)"
    if [[ -z "$url" ]]; then
      log_warn "could not resolve extension release"
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
setup_vicinae_service
install_vicinae_extension
bind_vicinae_shortcut
verify_launcher
