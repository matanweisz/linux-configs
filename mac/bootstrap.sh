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
echo "  1)  Install Homebrew"
echo "  2)  Install packages (brew bundle)"
echo "  3)  Restore configs"
echo "  4)  Apply macOS defaults"
echo "  5)  Setup zsh plugins (Zinit)"
echo "  6)  Install krew + kubectl plugins"
echo "  7)  Install Claude Code (native)"
echo "  8)  Setup JankyBorders service"
echo "  9)  Setup safe-rm trash dir"
echo "  10) Install gcloud SDK (official installer)"
echo "  11) Cleanup orphaned packages (brew bundle cleanup)"
echo "  12) Run ALL (steps 1–10; cleanup is opt-in)"
echo "  0)  Exit"
echo ""
read -rp "Choose [0-12]: " choice

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

    # Resolve known conflicts before brew bundle: Rancher Desktop's cask declares
    # `conflicts_with cask: docker-desktop`, so a leftover docker-desktop install
    # blocks the Rancher install.
    if brew list --cask docker-desktop &>/dev/null; then
        log_warn "docker-desktop is installed and conflicts with rancher — uninstalling..."
        brew uninstall --cask docker-desktop
    fi

    brew bundle --file="${SCRIPT_DIR}/Brewfile"
    log_success "Packages installed"
}

restore_configs() {
    log_info "Restoring configs..."

    mkdir -p ~/.config/{ghostty,nvim,borders}
    mkdir -p ~/.claude

    cp "${SCRIPT_DIR}/configs/starship.toml"   ~/.config/starship.toml
    cp "${SCRIPT_DIR}/configs/.gitconfig"      ~/.gitconfig
    cp "${SCRIPT_DIR}/configs/.gitignore_global" ~/.gitignore_global
    cp "${SCRIPT_DIR}/zsh/.zshrc"              ~/.zshrc
    cp "${SCRIPT_DIR}/zsh/.zsh_aliases"        ~/.zsh_aliases
    cp "${SCRIPT_DIR}/ghostty/config"          ~/.config/ghostty/config
    cp "${SCRIPT_DIR}/nvim/init.lua"           ~/.config/nvim/init.lua
    cp "${SCRIPT_DIR}/configs/borders/bordersrc" ~/.config/borders/bordersrc
    chmod +x ~/.config/borders/bordersrc

    cp "${SCRIPT_DIR}/claude/settings.json"    ~/.claude/settings.json
    cp "${SCRIPT_DIR}/claude/statusline.sh"    ~/.claude/statusline.sh
    chmod +x ~/.claude/statusline.sh

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

setup_krew() {
    if ! command -v kubectl &>/dev/null; then
        log_warn "kubectl not installed — run brew bundle first"
        return 1
    fi
    if [[ -d "${KREW_ROOT:-$HOME/.krew}" ]] && command -v "${KREW_ROOT:-$HOME/.krew}/bin/kubectl-krew" &>/dev/null; then
        log_success "krew already installed"
    else
        log_info "Installing krew (official method)..."
        (
            set -x
            cd "$(mktemp -d)"
            OS="$(uname | tr '[:upper:]' '[:lower:]')"
            ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
            KREW="krew-${OS}_${ARCH}"
            curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
            tar zxvf "${KREW}.tar.gz"
            ./"${KREW}" install krew
        )
        log_success "krew installed (PATH already wired in .zshrc)"
    fi

    log_info "Installing must-have kubectl plugins..."
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
    kubectl krew update
    kubectl krew install \
        tree neat view-secret resource-capacity \
        images who-can node-shell deprecations \
        explore rolesum 2>/dev/null || true
    log_success "krew plugins installed"
}

install_claude_code() {
    if command -v claude &>/dev/null; then
        log_success "Claude Code already installed"
    else
        log_info "Installing Claude Code via official native installer..."
        curl -fsSL https://claude.ai/install.sh | bash
        log_success "Claude Code installed"
    fi
    mkdir -p ~/.claude
    cp "${SCRIPT_DIR}/claude/settings.json" ~/.claude/settings.json
    cp "${SCRIPT_DIR}/claude/statusline.sh" ~/.claude/statusline.sh
    chmod +x ~/.claude/statusline.sh
    log_success "Claude Code statusline + settings configured"
}

setup_borders() {
    if ! command -v borders &>/dev/null; then
        log_warn "JankyBorders not installed — run brew bundle first"
        return 1
    fi
    mkdir -p ~/.config/borders
    cp "${SCRIPT_DIR}/configs/borders/bordersrc" ~/.config/borders/bordersrc
    chmod +x ~/.config/borders/bordersrc
    brew services restart borders >/dev/null 2>&1 || brew services start borders
    log_success "JankyBorders configured + service started"
}

setup_safe_rm() {
    mkdir -p "$HOME/.local/share/trash"
    log_success "Safe-rm trash directory ready at ~/.local/share/trash"
    log_info "Use 'rm' to trash, 'unrm' to restore, 'trash-clean' to purge >7 days, '\\rm' to bypass"
}

install_gcloud() {
    local GCLOUD_HOME="$HOME/google-cloud-sdk"
    if [[ -x "$GCLOUD_HOME/bin/gcloud" ]]; then
        log_success "gcloud SDK already installed at $GCLOUD_HOME"
        return 0
    fi

    log_info "Installing gcloud SDK via official installer..."
    local ARCH TARBALL TMP
    case "$(uname -m)" in
        arm64)  ARCH="arm" ;;
        x86_64) ARCH="x86_64" ;;
        *) log_warn "Unsupported arch $(uname -m) — skipping gcloud"; return 1 ;;
    esac
    TARBALL="google-cloud-cli-darwin-${ARCH}.tar.gz"
    TMP="$(mktemp -d)"
    (
        cd "$TMP"
        curl -fsSLO "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${TARBALL}"
        tar -xzf "$TARBALL" -C "$HOME"
    )
    rm -rf "$TMP"
    "$GCLOUD_HOME/install.sh" --quiet --usage-reporting=false --command-completion=false --path-update=false
    log_success "gcloud SDK installed at $GCLOUD_HOME (PATH wired in .zshrc expected)"
}

cleanup_packages() {
    log_info "Checking for installed packages no longer in the Brewfile..."
    local plan
    plan="$(brew bundle cleanup --file="${SCRIPT_DIR}/Brewfile" 2>&1 || true)"

    if echo "$plan" | grep -qE "^Would (uninstall|untap)"; then
        echo "$plan"
        echo ""
        read -rp "Uninstall the orphaned packages and untap unused taps? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            brew bundle cleanup --file="${SCRIPT_DIR}/Brewfile" --force
            log_info "Removing orphaned dependencies..."
            brew autoremove
            log_success "Cleanup complete"
        else
            log_warn "Cleanup cancelled — nothing removed"
        fi
    else
        log_success "No orphaned packages — system matches Brewfile"
    fi
}

case "$choice" in
    1)  install_homebrew ;;
    2)  install_packages ;;
    3)  restore_configs ;;
    4)  apply_defaults ;;
    5)  setup_zinit ;;
    6)  setup_krew ;;
    7)  install_claude_code ;;
    8)  setup_borders ;;
    9)  setup_safe_rm ;;
    10) install_gcloud ;;
    11) cleanup_packages ;;
    12)
        install_homebrew
        install_packages
        restore_configs
        apply_defaults
        setup_zinit
        setup_krew
        install_claude_code
        setup_borders
        setup_safe_rm
        install_gcloud
        echo ""
        log_success "Bootstrap complete! Restart your terminal."
        echo ""
        echo "  Next steps:"
        echo "  - ssh-keygen -t ed25519 -C \"your@email.com\""
        echo "  - Run nvim to install plugins automatically (lazy.nvim)"
        echo "  - Open Raycast: open -a Raycast (configure window-tiling shortcuts)"
        echo "  - Open AltTab: open -a AltTab. In Preferences enable"
        echo "    'Show windows from all spaces' and 'Start at login'."
        echo "  - Open Rancher Desktop: open -a 'Rancher Desktop' (first-run sets kubectl context)"
        echo "  - Verify Claude Code: claude --version"
        echo "  - To remove tools no longer in the Brewfile, run option 11 (cleanup)"
        ;;
    0) exit 0 ;;
    *) echo "Invalid option" ; exit 1 ;;
esac
