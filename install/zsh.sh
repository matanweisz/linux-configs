#!/usr/bin/env bash
#
# Zsh + Zinit setup. Config files (.zshrc/.zsh_aliases) are copied by
# install/restore-configs.sh — this script installs the shell + plugin manager
# and offers to set zsh as the default login shell.
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

# ---- Install zsh ----
if ! command -v zsh &>/dev/null; then
    log_info "Installing zsh..."
    sudo apt-get install -y zsh
    log_success "zsh installed ($(zsh --version))"
else
    log_success "zsh already installed ($(zsh --version))"
fi

# ---- Install Zinit ----
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ -d "$ZINIT_HOME" ]]; then
    log_success "Zinit already installed"
else
    log_info "Installing Zinit..."
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    log_success "Zinit installed"
fi

# ---- Set zsh as default login shell (interactive: prompts for password) ----
ZSH_PATH="$(command -v zsh)"
# Ensure zsh is a permitted login shell.
if ! grep -qx "$ZSH_PATH" /etc/shells 2>/dev/null; then
    log_info "Registering $ZSH_PATH in /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi
if [[ "${SHELL:-}" == "$ZSH_PATH" ]]; then
    log_success "Default shell is already zsh"
else
    log_warn "Default shell is ${SHELL:-unknown}. Run the following to switch (asks for your password):"
    echo "      chsh -s \"$ZSH_PATH\""
    log_warn "Then log out and back in for it to take effect."
fi

# ---- Verify ----
log_info "Verifying zsh setup..."
if [[ ! -f "$HOME/.zshrc" ]]; then
    # Without a ~/.zshrc, `zsh -i` drops into the blocking zsh-newuser-install wizard.
    log_info "VERIFY deferred: ~/.zshrc not present yet (install/restore-configs.sh puts it there)"
elif zsh -ic 'exit' 2>/dev/null; then
    log_success "VERIFY PASS: zsh starts with the new config"
    log_info "Startup time:"; (TIMEFMT='  %*E s'; time zsh -ic exit) 2>&1 || true
else
    log_warn "VERIFY: 'zsh -ic exit' returned non-zero — run 'zsh' once so zinit installs plugins, then recheck"
fi
