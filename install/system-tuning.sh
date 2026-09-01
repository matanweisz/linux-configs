#!/usr/bin/env bash
#
# Workstation kernel + hardware tuning. Small, high-leverage, reversible:
#   - vm.swappiness 60 -> 10   (Ubuntu's server-oriented default is wrong for a
#                               30 GB / NVMe laptop; 60 swaps out idle desktop
#                               pages that are about to be touched again)
#   - Intel VA-API driver      (hardware video decode in Chrome/Firefox — saves
#                               battery and CPU on every video call and stream)
#   - fstrim.timer assertion   (already on by default; assert, do not re-enable)
#
# Nothing here is GNOME- or Ubuntu-version specific. Every step is idempotent and
# each writes a drop-in file rather than editing a distro-managed one, so
# `rm /etc/sysctl.d/99-workstation.conf` fully reverts the sysctl half.
#
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

SYSCTL_DROPIN="/etc/sysctl.d/99-workstation.conf"

# ---- 1. Kernel VM tuning ----
apply_sysctl() {
    if [[ -f "$SYSCTL_DROPIN" ]]; then
        log_success "sysctl drop-in already present ($SYSCTL_DROPIN)"
    else
        log_info "Writing $SYSCTL_DROPIN (swappiness + dirty writeback)..."
        sudo tee "$SYSCTL_DROPIN" >/dev/null <<'EOF'
# Managed by linux-configs/install/system-tuning.sh — delete this file to revert.

# Ubuntu ships 60, tuned for servers where swapping cold pages is cheap. On a
# desktop with plenty of RAM it evicts pages that are about to be touched again,
# which is felt as a stutter when returning to an idle browser tab or IDE.
vm.swappiness = 10

# Prefer reclaiming page cache over inodes/dentries — keeps a warm FS cache for
# large git trees and node_modules.
vm.vfs_cache_pressure = 50
EOF
        log_success "sysctl drop-in written"
    fi
    sudo sysctl --system >/dev/null 2>&1 || sudo sysctl -p "$SYSCTL_DROPIN" >/dev/null 2>&1 || true
    log_success "sysctl applied (swappiness now $(cat /proc/sys/vm/swappiness))"
}

# ---- 2. Hardware video acceleration (VA-API) ----
# Chrome logs "vaInitialize failed: unknown libva error" when no VA driver is
# installed for the integrated GPU. On hybrid Intel + NVIDIA laptops the iGPU is
# what actually does video decode, so the Intel driver is the one that matters.
install_vaapi() {
    # grep -c, not grep -q: -q exits on the first match and SIGPIPEs lspci, which
    # under pipefail inverts the test. The Intel iGPU matches early, so -q would fail.
    if [[ "$(lspci 2>/dev/null | grep -ci 'VGA.*Intel' || true)" -eq 0 ]]; then
        log_info "No Intel integrated GPU detected — skipping VA-API driver"
        return 0
    fi
    local pkgs=(vainfo)
    # iHD (intel-media-va-driver) covers Broadwell and newer; i965 is the legacy
    # fallback. libva-driver-all pulls whichever matches the hardware.
    pkgs+=(intel-media-va-driver-non-free va-driver-all)
    local need=()
    local p
    for p in "${pkgs[@]}"; do
        dpkg -s "$p" &>/dev/null || need+=("$p")
    done
    if ((${#need[@]} == 0)); then
        log_success "VA-API packages already installed"
    else
        log_info "Installing VA-API packages: ${need[*]}"
        sudo rm -rf /var/cache/apt/*.bin 2>/dev/null || true
        sudo apt-get install -y "${need[@]}" || log_warn "VA-API package install failed"
    fi
}

# ---- 3. Trim ----
assert_fstrim() {
    if systemctl is-enabled fstrim.timer &>/dev/null; then
        log_success "fstrim.timer enabled (weekly SSD trim)"
    else
        log_info "Enabling fstrim.timer..."
        sudo systemctl enable --now fstrim.timer && log_success "fstrim.timer enabled" \
            || log_warn "could not enable fstrim.timer"
    fi
}

# ---- 4. Verify ----
verify_tuning() {
    log_info "Verifying system tuning..."
    local sw
    sw="$(cat /proc/sys/vm/swappiness 2>/dev/null || echo '?')"
    [[ "$sw" == "10" ]] && log_success "  vm.swappiness = 10" \
        || log_warn "  vm.swappiness = $sw (expected 10)"

    systemctl is-enabled fstrim.timer &>/dev/null \
        && log_success "  fstrim.timer enabled" || log_warn "  fstrim.timer not enabled"

    # Report what VA-API actually reports, rather than assuming the package fixed it.
    if command -v vainfo &>/dev/null; then
        local profiles
        profiles="$(vainfo 2>/dev/null | grep -c 'VAProfile' || true)"
        if [[ "${profiles:-0}" -gt 0 ]]; then
            log_success "  VA-API working ($profiles profiles via $(vainfo 2>&1 | grep -oP 'Driver version: \K.*' | head -1))"
        else
            log_warn "  vainfo reports no profiles — hardware video decode still unavailable."
            log_warn "    On hybrid GPUs try: LIBVA_DRIVER_NAME=iHD vainfo"
        fi
    else
        log_warn "  vainfo not installed — cannot verify VA-API"
    fi
    log_success "VERIFY done (sysctl applies immediately; VA-API needs an app restart)"
}

apply_sysctl
install_vaapi
assert_fstrim
verify_tuning
