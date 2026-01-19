#!/usr/bin/env bash
#
# DevOps Ubuntu Bootstrap Script
# Automates setup of a new Ubuntu workstation for DevOps workflow
#
# Usage: ./bootstrap.sh
#
# Inspired by omakub (https://github.com/basecamp/omakub)
# Customized for DevOps engineers

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory (where this repo is cloned)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Log functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Error handler
trap 'log_error "Script failed at line $LINENO. Run again to retry."' ERR

# Check Ubuntu version
check_ubuntu() {
    if [ ! -f /etc/os-release ]; then
        log_error "This script is designed for Ubuntu"
        exit 1
    fi

    source /etc/os-release
    if [[ "$ID" != "ubuntu" ]]; then
        log_error "This script requires Ubuntu (detected: $ID)"
        exit 1
    fi

    log_info "Detected: $PRETTY_NAME"
}

# Show banner
show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
    ____              ____                ____              __       __
   / __ \___ _   __  / __ \____  _____   / __ )____  ____  / /______/ /__________ ___
  / / / / _ \ | / / / / / / __ \/ ___/  / __  / __ \/ __ \/ __/ ___/ __/ ___/ __ `__ \
 / /_/ /  __/ |/ / / /_/ / /_/ (__  )  / /_/ / /_/ / /_/ / /_(__  ) /_/ /  / / / / / /
/_____/\___/|___/  \____/ .___/____/  /_____/\____/\____/\__/____/\__/_/  /_/ /_/ /_/
                       /_/
EOF
    echo -e "${NC}"
    echo "Ubuntu DevOps Workstation Bootstrap"
    echo "===================================="
    echo ""
}

# Main menu using gum (if available) or fallback to basic selection
show_menu() {
    echo ""
    log_info "What would you like to install?"
    echo ""
    echo "  1) Full installation (recommended for new machines)"
    echo "  2) Core CLI tools only"
    echo "  3) DevOps tools only (K8s, Terraform, AWS, GCloud)"
    echo "  4) Desktop apps only (VS Code, Chrome, etc.)"
    echo "  5) Restore configs only (dotfiles, GNOME settings)"
    echo "  6) Custom selection"
    echo ""
    read -p "Enter choice [1-6]: " choice

    case $choice in
        1) INSTALL_CORE=true; INSTALL_DEVOPS=true; INSTALL_DESKTOP=true; RESTORE_CONFIGS=true ;;
        2) INSTALL_CORE=true; INSTALL_DEVOPS=false; INSTALL_DESKTOP=false; RESTORE_CONFIGS=false ;;
        3) INSTALL_CORE=false; INSTALL_DEVOPS=true; INSTALL_DESKTOP=false; RESTORE_CONFIGS=false ;;
        4) INSTALL_CORE=false; INSTALL_DEVOPS=false; INSTALL_DESKTOP=true; RESTORE_CONFIGS=false ;;
        5) INSTALL_CORE=false; INSTALL_DEVOPS=false; INSTALL_DESKTOP=false; RESTORE_CONFIGS=true ;;
        6) custom_selection ;;
        *) log_error "Invalid choice"; exit 1 ;;
    esac
}

custom_selection() {
    echo ""
    read -p "Install core CLI tools? (y/n): " ans; [[ "$ans" =~ ^[Yy] ]] && INSTALL_CORE=true || INSTALL_CORE=false
    read -p "Install DevOps tools? (y/n): " ans; [[ "$ans" =~ ^[Yy] ]] && INSTALL_DEVOPS=true || INSTALL_DEVOPS=false
    read -p "Install desktop apps? (y/n): " ans; [[ "$ans" =~ ^[Yy] ]] && INSTALL_DESKTOP=true || INSTALL_DESKTOP=false
    read -p "Restore configs and GNOME settings? (y/n): " ans; [[ "$ans" =~ ^[Yy] ]] && RESTORE_CONFIGS=true || RESTORE_CONFIGS=false
}

# Run installation
run_install() {
    # Always update system first
    log_info "Updating system packages..."
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install -y curl git wget unzip software-properties-common apt-transport-https ca-certificates gnupg

    # Core CLI tools
    if [[ "$INSTALL_CORE" == "true" ]]; then
        log_info "Installing core CLI tools..."
        source "$SCRIPT_DIR/install/core-tools.sh"
    fi

    # DevOps tools
    if [[ "$INSTALL_DEVOPS" == "true" ]]; then
        log_info "Installing DevOps tools..."
        source "$SCRIPT_DIR/install/devops-tools.sh"
    fi

    # Desktop apps
    if [[ "$INSTALL_DESKTOP" == "true" ]]; then
        log_info "Installing desktop applications..."
        source "$SCRIPT_DIR/install/desktop-apps.sh"
    fi

    # Restore configs
    if [[ "$RESTORE_CONFIGS" == "true" ]]; then
        log_info "Restoring configurations..."
        source "$SCRIPT_DIR/install/restore-configs.sh"
    fi
}

# Git configuration prompt
setup_git() {
    echo ""
    log_info "Git Configuration"

    current_name=$(git config --global user.name 2>/dev/null || echo "")
    current_email=$(git config --global user.email 2>/dev/null || echo "")

    if [[ -z "$current_name" ]]; then
        read -p "Enter your Git name: " git_name
        git config --global user.name "$git_name"
    else
        log_info "Git name already set: $current_name"
    fi

    if [[ -z "$current_email" ]]; then
        read -p "Enter your Git email: " git_email
        git config --global user.email "$git_email"
    else
        log_info "Git email already set: $current_email"
    fi
}

# Final message
show_complete() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Installation Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Log out and back in (for Docker group membership)"
    echo "  2. Run 'ssh-keygen' and add key to GitHub if needed"
    echo "  3. Configure AWS CLI: aws configure"
    echo "  4. Configure GCloud: gcloud init"
    echo ""
    log_info "Reboot recommended for all changes to take effect"
}

# Main execution
main() {
    show_banner
    check_ubuntu
    show_menu
    run_install
    setup_git
    show_complete
}

main "$@"
