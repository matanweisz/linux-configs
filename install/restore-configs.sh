#!/usr/bin/env bash
#
# Configuration restore: copy dotfiles into place with timestamped backups.
# Copies (not symlinks), matching the macOS side's single-file-config philosophy.
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
REPO_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

backup_if_exists() {
    local p="$1"
    if [[ -e "$p" && ! -L "$p" ]]; then
        mv "$p" "${p}.backup.$(date +%Y%m%d%H%M%S)"
        log_info "Backed up existing $p"
    fi
}
copy_cfg() { # src dest
    local src="$1" dest="$2"
    [[ -f "$src" ]] || { log_warn "missing source: $src"; return 0; }
    mkdir -p "$(dirname "$dest")"
    backup_if_exists "$dest"
    cp "$src" "$dest"
    log_success "Restored $(basename "$dest")"
}

# ---- Zsh (primary shell) ----
copy_cfg "$REPO_DIR/zsh/.zshrc"        "$HOME/.zshrc"
copy_cfg "$REPO_DIR/zsh/.zsh_aliases"  "$HOME/.zsh_aliases"

# ---- Bash fallback (until chsh + relogin; also for scripts) ----
if [[ -f "$REPO_DIR/bash/.bash_aliases" ]]; then
    copy_cfg "$REPO_DIR/bash/.bash_aliases" "$HOME/.bash_aliases"
fi
if ! grep -q "starship init bash" "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<'EOF'

# --- linux-configs (bash fallback) ---
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
[ -f ~/.bash_aliases ] && . ~/.bash_aliases
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
EOF
    log_success "Wired starship + aliases into ~/.bashrc (bash fallback)"
fi

# ---- Terminal / editor / prompt ----
copy_cfg "$REPO_DIR/ghostty/config"     "$HOME/.config/ghostty/config"
copy_cfg "$REPO_DIR/nvim/init.lua"      "$HOME/.config/nvim/init.lua"
copy_cfg "$REPO_DIR/configs/starship.toml" "$HOME/.config/starship.toml"

# ---- Git ----
copy_cfg "$REPO_DIR/configs/.gitconfig"        "$HOME/.gitconfig"
copy_cfg "$REPO_DIR/configs/.gitignore_global" "$HOME/.gitignore_global"

# ---- gh / atuin / tmux ----
copy_cfg "$REPO_DIR/configs/gh/config.yml"     "$HOME/.config/gh/config.yml"
copy_cfg "$REPO_DIR/configs/atuin/config.toml" "$HOME/.config/atuin/config.toml"
copy_cfg "$REPO_DIR/configs/tmux/tmux.conf"    "$HOME/.config/tmux/tmux.conf"

# ---- btop ----
if [[ -f "$REPO_DIR/configs/btop/btop.conf" ]]; then
    mkdir -p "$HOME/.config/btop/themes"
    cp "$REPO_DIR/configs/btop/btop.conf" "$HOME/.config/btop/btop.conf"
    [[ -d "$REPO_DIR/configs/btop/themes" ]] && cp "$REPO_DIR"/configs/btop/themes/* "$HOME/.config/btop/themes/" 2>/dev/null || true
    log_success "Restored btop config"
fi

# ---- SSH scaffolding (no keys) ----
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
if [[ ! -f "$HOME/.ssh/config" ]]; then
    cat > "$HOME/.ssh/config" <<'EOF'
# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_ed25519
    AddKeysToAgent yes
    IdentitiesOnly yes
EOF
    chmod 600 "$HOME/.ssh/config"
    log_info "Created SSH config template. Generate a key: ssh-keygen -t ed25519 -f ~/.ssh/github_ed25519"
fi
mkdir -p "$HOME/ssh_keys" && chmod 700 "$HOME/ssh_keys"

# ---- safe-rm trash dir ----
mkdir -p "$HOME/.local/share/trash"

# ============================================
# Verify
# ============================================
log_info "Verifying restored configs..."
[[ -f "$HOME/.config/gh/config.yml" ]] && log_success "  gh config present" || log_warn "  gh config missing"
[[ -f "$HOME/.config/atuin/config.toml" ]] && log_success "  atuin config present" || log_warn "  atuin config missing"
[[ -f "$HOME/.config/tmux/tmux.conf" ]] && log_success "  tmux config present" || log_warn "  tmux config missing"

log_success "Configuration restore complete"
