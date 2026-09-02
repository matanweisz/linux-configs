#!/usr/bin/env bash
#
# GNOME Shell extensions — declarative install + settings restore.
#
# This is the desktop half of Mac parity: TopHat replaces the `stats` menubar app,
# Tiling Shell's window border replaces JankyBorders, Blur My Shell replaces macOS
# vibrancy, Dash to Dock replaces the macOS Dock.
#
# Extensions come from extensions.gnome.org, version-matched to the RUNNING shell.
# Do NOT switch this to GitHub `releases/latest` zips: those carry one metadata.json
# whose shell-version list lags the current GNOME (Tiling Shell 17.3 stops at 49, so
# GNOME 50 refuses to load it). The site API returns the build matched to the shell.
#
# Settings live in gnome/extensions.dconf and are applied with `dconf load` — see the
# header of that file for why gsettings cannot be used for extension schemas.
#
# Wayland cannot load a freshly installed extension into the running shell, so every
# UUID here is registered in org.gnome.shell enabled-extensions and activates on the
# next login. All steps are user-level (no sudo).
#
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
REPO_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# The daily-driver extension set. Keep this list and gnome/extensions.dconf in sync:
# a UUID here with no stanza there just runs on its defaults, which is fine, but a
# stanza there for a UUID not here is dead config — strip it on the next re-export.
EXTENSIONS=(
  "just-perfection-desktop@just-perfection" # shell de-clutter + fast animations
  "blur-my-shell@aunetx"                    # panel/overview/dock blur
  "tophat@fflewddur.github.io"              # CPU/mem/net in panel  <- mac `stats` parity
  "dash-to-dock@micxgx.gmail.com"           # dock (ubuntu-dock stands down on its own)
  "appmenu-is-back@fthx"                    # app menu in the top panel
  "quick-settings-tweaks@qwreey"            # quick-settings customisation
  "lockkeys@vaina.lt"                       # caps-lock OSD
  "mediacontrols@cliffniff.github.com"      # now-playing in panel
  "simple-timer@majortomvr.github.com"      # panel timer
  "rounded-window-corners@fxgn"             # rounded corners (dconf path: ...-reborn)
  "tilingshell@ferrarodomenico.com"         # FancyZones-style tiling <- mac Aerospace parity
)
# Deliberately NOT installed: clipboard-indicator@tudmotu.com — Vicinae ships a
# Raycast-style clipboard manager (Super+Space). Running both means two capture
# daemons and two divergent histories.

# True if an extension is present on disk (reliable on Wayland, unlike
# `gnome-extensions list` which only reflects the running shell until relogin).
ext_installed() { [[ -f "$HOME/.local/share/gnome-shell/extensions/$1/metadata.json" ]]; }

# Register a UUID in GNOME's enabled-extensions so it auto-enables on next login.
# (`gnome-extensions enable` cannot enable an extension the running shell has not
# loaded yet — on Wayland that is anything installed this session.)
register_extension() {
  local uuid="$1"
  command -v gsettings &>/dev/null || return 0
  gnome-extensions enable "$uuid" 2>/dev/null || true # works once the shell knows it
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

# Current GNOME Shell major version ("50" for 50.1) — the extensions.gnome.org key.
shell_major() { gnome-shell --version 2>/dev/null | grep -oE '[0-9]+' | head -1 || true; }

# Download + install the build of $1 that matches the running shell.
# The API response embeds raw control characters in description fields, which makes
# `jq` bail with a parse error — grep the one field we need instead.
install_extension_from_ego() {
  local uuid="$1" sv="$2" path tmp
  if ext_installed "$uuid"; then
    log_success "  $uuid already installed"
    return 0
  fi
  path="$(curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${sv}" 2>/dev/null \
    | grep -oP '"download_url":\s*"\K[^"]+' || true)"
  if [[ -z "$path" ]]; then
    log_warn "  $uuid — no build for GNOME ${sv} on extensions.gnome.org, skipping"
    return 0
  fi
  tmp="$(mktemp -d)"
  if curl -fsSL "https://extensions.gnome.org${path}" -o "$tmp/ext.zip" \
    && gnome-extensions install --force "$tmp/ext.zip" 2>/dev/null; then
    log_success "  $uuid installed"
  else
    log_warn "  $uuid install failed"
  fi
  rm -rf "$tmp"
}

# ---- 1. Install + register every extension ----
install_extensions() {
  command -v gnome-extensions &>/dev/null || {
    log_warn "gnome-extensions missing — skipping extension install"
    return 0
  }
  local sv
  sv="$(shell_major)"
  [[ -n "$sv" ]] || {
    log_warn "Could not determine GNOME Shell version — skipping extension install"
    return 0
  }
  log_info "Installing ${#EXTENSIONS[@]} GNOME extensions for Shell ${sv}..."
  local uuid
  for uuid in "${EXTENSIONS[@]}"; do
    install_extension_from_ego "$uuid" "$sv"
    ext_installed "$uuid" && register_extension "$uuid"
  done
  log_success "Extensions installed and registered (active after logout/login)"
}

# ---- 2. Apply tuned settings ----
apply_extension_settings() {
  local keyfile="$REPO_DIR/gnome/extensions.dconf"
  [[ -f "$keyfile" ]] || {
    log_warn "missing $keyfile — extensions will run on defaults"
    return 0
  }
  command -v dconf &>/dev/null || {
    log_warn "dconf missing — cannot apply extension settings"
    return 0
  }
  log_info "Applying extension settings from gnome/extensions.dconf..."
  if dconf load /org/gnome/shell/extensions/ <"$keyfile"; then
    log_success "Extension settings applied"
  else
    log_warn "dconf load reported an error — check gnome/extensions.dconf syntax"
  fi
}

# ---- 3. Verify ----
verify_extensions() {
  log_info "Verifying GNOME extensions..."
  local uuid missing=() state
  for uuid in "${EXTENSIONS[@]}"; do
    if ! ext_installed "$uuid"; then
      missing+=("$uuid")
      continue
    fi
    # On disk is not enough — a metadata.json the running shell rejects (wrong
    # shell-version) still leaves the files there. Ask the shell for its state.
    state="$(gnome-extensions info "$uuid" 2>/dev/null | awk -F': ' '/State:/{print $2; exit}' || true)"
    case "$state" in
      ENABLED* | ACTIVE*) log_success "  $uuid $state" ;;
      OUT_OF_DATE*) log_warn "  $uuid OUT OF DATE — no build for this GNOME" ;;
      *) log_info "  $uuid ${state:-INSTALLED} — activates on next login" ;;
    esac
  done
  # dconf round-trip: prove the settings landed, not just that the load exited 0.
  local border
  border="$(dconf read /org/gnome/shell/extensions/tilingshell/window-border-color 2>/dev/null || true)"
  [[ -n "$border" ]] && log_success "  settings applied (tilingshell border ${border})" \
    || log_warn "  extension settings not readable from dconf"

  if ((${#missing[@]} == 0)); then
    log_success "VERIFY PASS: all ${#EXTENSIONS[@]} extensions present (log out/in to activate)"
  else
    log_warn "VERIFY: ${#missing[@]} not installed: ${missing[*]}"
  fi
}

install_extensions
apply_extension_settings
verify_extensions
