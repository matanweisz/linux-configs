#!/usr/bin/env bash
#
# Core CLI Tools Installation
# Essential terminal tools for development workflow
#

log_info "Installing core CLI tools from apt..."

# Essential CLI tools from apt
sudo apt install -y \
    bat \
    btop \
    curl \
    eza \
    fd-find \
    fzf \
    git \
    git-extras \
    gitleaks \
    htop \
    jq \
    neovim \
    ripgrep \
    tree \
    unzip \
    wget \
    xclip

# Create bat symlink (Ubuntu packages it as batcat)
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    mkdir -p ~/.local/bin
    ln -sf "$(which batcat)" ~/.local/bin/bat
fi

# Create fd symlink (Ubuntu packages it as fdfind)
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    mkdir -p ~/.local/bin
    ln -sf "$(which fdfind)" ~/.local/bin/fd
fi

log_success "Apt packages installed"

# Starship prompt
log_info "Installing Starship prompt..."
if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi
log_success "Starship installed"

# Lazygit (latest from GitHub)
log_info "Installing Lazygit..."
if ! command -v lazygit &>/dev/null; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -sLo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    rm /tmp/lazygit.tar.gz /tmp/lazygit
fi
log_success "Lazygit installed"

# Lazydocker
log_info "Installing Lazydocker..."
if ! command -v lazydocker &>/dev/null; then
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
fi
log_success "Lazydocker installed"

# yq (YAML processor) via snap
log_info "Installing yq..."
if ! command -v yq &>/dev/null; then
    sudo snap install yq
fi
log_success "yq installed"

# GitHub CLI
log_info "Installing GitHub CLI..."
if ! command -v gh &>/dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo rm -rf /var/cache/apt/*.bin 2>/dev/null || true
    sudo apt update
    sudo apt install -y gh
fi
log_success "GitHub CLI installed"

# Claude Code
log_info "Installing Claude Code..."
if ! command -v claude &>/dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
fi
log_success "Claude Code installed"

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >>~/.bashrc
fi

log_success "Core CLI tools installation complete"
