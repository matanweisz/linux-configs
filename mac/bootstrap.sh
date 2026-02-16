#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Mac DevOps Bootstrap
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }

if [[ "$(uname)" != "Darwin" ]]; then
    echo "This script is for macOS only." >&2
    exit 1
fi

echo ""
echo "  Mac DevOps Bootstrap"
echo "  ===================="
echo ""
echo "  1) Install Homebrew"
echo "  2) Install packages (brew bundle)"
echo "  3) Restore configs"
echo "  4) Apply macOS defaults"
echo "  5) Setup tmux plugins (TPM)"
echo "  6) Setup zsh plugins (Zinit)"
echo "  7) Run ALL"
echo "  0) Exit"
echo ""
read -rp "Choose [0-7]: " choice

install_homebrew() {
    if command -v brew &>/dev/null; then
        log_success "Homebrew already installed"
    else
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
        log_success "Homebrew installed"
    fi
}

install_packages() {
    log_info "Installing packages from Brewfile..."
    brew bundle --file="${SCRIPT_DIR}/Brewfile" --no-lock
    log_success "Packages installed"
}

restore_configs() {
    log_info "Restoring configs..."

    mkdir -p ~/.config/{ghostty,nvim,tmux,aerospace}

    cp "${SCRIPT_DIR}/configs/starship.toml" ~/.config/starship.toml
    cp "${SCRIPT_DIR}/configs/.gitconfig" ~/.gitconfig
    cp "${SCRIPT_DIR}/configs/.gitignore_global" ~/.gitignore_global
    cp "${SCRIPT_DIR}/zsh/.zshrc" ~/.zshrc
    cp "${SCRIPT_DIR}/zsh/.zsh_aliases" ~/.zsh_aliases
    cp "${SCRIPT_DIR}/ghostty/config" ~/.config/ghostty/config
    cp "${SCRIPT_DIR}/nvim/init.lua" ~/.config/nvim/init.lua
    cp "${SCRIPT_DIR}/tmux/tmux.conf" ~/.config/tmux/tmux.conf
    cp "${SCRIPT_DIR}/aerospace/aerospace.toml" ~/.config/aerospace/aerospace.toml

    # btop config from linux-configs if available
    if [[ -f "${SCRIPT_DIR}/../configs/btop/btop.conf" ]]; then
        mkdir -p ~/.config/btop/themes
        cp "${SCRIPT_DIR}/../configs/btop/btop.conf" ~/.config/btop/btop.conf
        cp "${SCRIPT_DIR}/../configs/btop/themes/catppuccin.theme" ~/.config/btop/themes/
        log_success "btop config restored"
    fi

    # SSH template
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    if [[ ! -f ~/.ssh/config ]]; then
        cat > ~/.ssh/config << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
    UseKeychain yes

Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
EOF
        chmod 600 ~/.ssh/config
        log_success "SSH config created"
    fi

    log_success "All configs restored"
}

apply_defaults() {
    log_info "Applying macOS defaults..."
    bash "${SCRIPT_DIR}/macos-defaults.sh"
    log_success "Defaults applied"
}

setup_tpm() {
    if [[ -d ~/.tmux/plugins/tpm ]]; then
        log_success "TPM already installed"
    else
        log_info "Installing TPM..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        log_success "TPM installed — open tmux and press prefix+I to install plugins"
    fi
}

setup_zinit() {
    local ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
    if [[ -d "$ZINIT_HOME" ]]; then
        log_success "Zinit already installed"
    else
        log_info "Installing Zinit..."
        mkdir -p "$(dirname "$ZINIT_HOME")"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
        log_success "Zinit installed"
    fi
}

case "$choice" in
    1) install_homebrew ;;
    2) install_packages ;;
    3) restore_configs ;;
    4) apply_defaults ;;
    5) setup_tpm ;;
    6) setup_zinit ;;
    7)
        install_homebrew
        install_packages
        restore_configs
        apply_defaults
        setup_tpm
        setup_zinit
        echo ""
        log_success "Bootstrap complete! Restart your terminal."
        echo ""
        echo "  Next steps:"
        echo "  - ssh-keygen -t ed25519 -C \"your@email.com\""
        echo "  - Open tmux, press Ctrl+a then I to install plugins"
        echo "  - Run nvim to install plugins automatically"
        echo "  - Open AeroSpace: open -a AeroSpace"
        ;;
    0) exit 0 ;;
    *) echo "Invalid option" ; exit 1 ;;
esac
