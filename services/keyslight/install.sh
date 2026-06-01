#!/usr/bin/env bash
#
# Install the keyboard-backlight automation (ASUS Aura / rogauracore).
# Consolidates boot + resume into clean systemd units and retires the old,
# broken/duplicate mechanisms. Idempotent. Run once with sudo:
#
#     sudo bash services/keyslight/install.sh
#
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "This installer needs root. Run: sudo bash $0" >&2
  exit 1
fi

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
ok() { echo -e "${GREEN}[OK]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# 1. Canonical script in a root-owned location (not user-writable $HOME).
info "Installing /usr/local/sbin/keyslight.sh"
install -o root -g root -m 0755 "$SRC_DIR/keyslight.sh" /usr/local/sbin/keyslight.sh
ok "script installed"

# 2. systemd units (boot + resume), both pointing at the canonical script.
info "Installing systemd units"
install -o root -g root -m 0644 "$SRC_DIR/keyslight.service" /etc/systemd/system/keyslight.service
install -o root -g root -m 0644 "$SRC_DIR/keyslight-resume.service" /etc/systemd/system/keyslight-resume.service
ok "units installed"

# 3. Retire the old, broken/duplicate mechanisms (reversible).
info "Retiring old mechanisms"
# 3a. keylight.service — broken (wrong path, typo'd Environment lines).
if systemctl list-unit-files 2>/dev/null | grep -q '^keylight\.service'; then
  systemctl disable --now keylight.service 2>/dev/null || true
fi
rm -f /etc/systemd/system/keylight.service
# 3b. Legacy SysV /etc/init.d/asus_keyboard_backlight.sh duplicate — mask it so it
#     never double-drives the keyboard at boot. Reverse with: systemctl unmask + update-rc.d defaults.
if [[ -e /etc/init.d/asus_keyboard_backlight.sh ]]; then
  systemctl mask asus_keyboard_backlight.service 2>/dev/null || true
  update-rc.d -f asus_keyboard_backlight.sh remove 2>/dev/null || true
  ok "legacy asus_keyboard_backlight masked"
fi

# 4. Reload + enable (and start now, so the lights come on immediately).
info "Enabling services"
systemctl daemon-reload
systemctl enable --now keyslight.service
systemctl reenable keyslight-resume.service 2>/dev/null || systemctl enable keyslight-resume.service
ok "services enabled"

# 5. Verify.
echo
info "Verification:"
systemctl is-enabled keyslight.service && ok "keyslight.service enabled (runs at boot)"
systemctl is-enabled keyslight-resume.service && ok "keyslight-resume.service enabled (runs after sleep)"
echo "--- keyslight.service ---"
systemctl --no-pager --full status keyslight.service | sed -n '1,8p' || true
echo
ok "Done. Lights should be on now; they'll come on automatically at every boot and after resume."
