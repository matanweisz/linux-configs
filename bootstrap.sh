#!/usr/bin/env bash
#
# Ubuntu DevOps Bootstrap — Mac-parity workflow on Ubuntu/GNOME (Wayland).
#
# Stack: Homebrew (CLI) + apt/deb/snap (GUI) + zsh/Zinit + Ghostty + Neovim +
#        Starship + Vicinae launcher + Tiling Shell + sanitized Claude Code.
#
# Usage: ./bootstrap.sh        (interactive menu; full run does steps in order)
#
set -Eeuo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
export -f log_info log_success log_warn log_error 2>/dev/null || true

trap 'log_error "Failed at line $LINENO. Fix the cause and re-run (steps are idempotent)."' ERR

check_ubuntu() {
    [[ -f /etc/os-release ]] || { log_error "Not Ubuntu (no /etc/os-release)"; exit 1; }
    # shellcheck disable=SC1091
    source /etc/os-release
    [[ "$ID" == "ubuntu" ]] || { log_error "Requires Ubuntu (detected: $ID)"; exit 1; }
    log_info "Detected: $PRETTY_NAME (GNOME ${XDG_CURRENT_DESKTOP:-?}, session ${XDG_SESSION_TYPE:-?})"
}

banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
   Ubuntu DevOps Bootstrap — Mac-parity edition
   ============================================
EOF
    echo -e "${NC}"
}

system_update() {
    log_info "Cleaning apt cache + updating system..."
    sudo rm -rf /var/cache/apt/archives/lock /var/lib/dpkg/lock* /var/cache/apt/*.bin 2>/dev/null || true
    sudo dpkg --configure -a 2>/dev/null || true
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo apt-get install -y curl git wget unzip software-properties-common \
        apt-transport-https ca-certificates gnupg jq
    log_success "System updated"
}

setup_git() {
    log_info "Git identity"
    local name email
    name="$(git config --global user.name 2>/dev/null || true)"
    email="$(git config --global user.email 2>/dev/null || true)"
    if [[ -z "$name" ]]; then read -rp "  Git name: " name; [[ -n "$name" ]] && git config --global user.name "$name"; else log_info "  name already set: $name"; fi
    if [[ -z "$email" ]]; then read -rp "  Git email: " email; [[ -n "$email" ]] && git config --global user.email "$email"; else log_info "  email already set: $email"; fi
    log_success "Git identity configured"
}

# --- module wrappers (each sources an install/ script) ---
run_brew()    { log_info  "== Homebrew + CLI tools =="; source "$SCRIPT_DIR/install/brew.sh"; }
run_zsh()     { log_info  "== Zsh + Zinit =="; source "$SCRIPT_DIR/install/zsh.sh"; }
run_devops()  { log_info  "== Docker + gcloud (native) =="; source "$SCRIPT_DIR/install/devops-tools.sh"; }
run_desktop() { log_info  "== Desktop apps + Ghostty =="; source "$SCRIPT_DIR/install/desktop-apps.sh"; }
run_restore() { log_info  "== Restore configs =="; source "$SCRIPT_DIR/install/restore-configs.sh"; }
run_claude()  { log_info  "== Claude Code =="; source "$SCRIPT_DIR/install/claude.sh"; }
run_launcher(){ log_info  "== Vicinae launcher =="; source "$SCRIPT_DIR/install/launcher.sh"; }
run_gnome()   { log_info  "== GNOME tweaks + Tiling Shell + fonts =="; source "$SCRIPT_DIR/install/gnome-setup.sh"; }

run_all() {
    system_update
    run_brew
    run_zsh
    run_devops
    run_desktop
    run_restore
    run_claude
    run_launcher
    run_gnome
    setup_git
    final_notes
}

final_notes() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Bootstrap complete${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Manual / interactive steps remaining:"
    echo "  1. Make zsh your shell:   chsh -s \"\$(command -v zsh)\"   (then log out/in)"
    echo "  2. Log out/in once so: Homebrew PATH, docker group, and the"
    echo "     Vicinae + Tiling Shell GNOME extensions all activate (Wayland)."
    echo "  3. Authenticate:  gh auth login   |   aws configure   |   gcloud init"
    echo "  4. SSH key:       ssh-keygen -t ed25519 -f ~/.ssh/github_ed25519"
    echo "  5. Open Ghostty; run 'nvim' once to let lazy.nvim install plugins."
    echo "  6. Launcher: press Super+Space for Vicinae. Tiling: Super+arrows."
    echo "  7. Claude Code: 'claude' (standard Anthropic login — no internal router)."
}

menu() {
    echo ""
    echo "  1)  Full setup (everything, in order)"
    echo "  2)  Homebrew + CLI tools (Brewfile + krew)"
    echo "  3)  Zsh + Zinit"
    echo "  4)  Docker + gcloud (native DevOps)"
    echo "  5)  Desktop apps + Ghostty"
    echo "  6)  Restore configs (dotfiles)"
    echo "  7)  Claude Code (sanitized)"
    echo "  8)  Vicinae launcher"
    echo "  9)  GNOME tweaks + Tiling Shell + fonts"
    echo "  10) Git identity"
    echo "  0)  Exit"
    echo ""
    read -rp "Choose [0-10]: " choice
    case "$choice" in
        1)  run_all ;;
        2)  system_update; run_brew ;;
        3)  system_update; run_zsh ;;
        4)  system_update; run_devops ;;
        5)  system_update; run_desktop ;;
        6)  run_restore ;;
        7)  run_claude ;;
        8)  run_launcher ;;
        9)  run_gnome ;;
        10) setup_git ;;
        0)  exit 0 ;;
        *)  log_error "Invalid option"; exit 1 ;;
    esac
}

banner
check_ubuntu
menu
