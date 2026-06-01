#!/usr/bin/env bash
#
# Homebrew on Linux + CLI tooling (brew bundle) + krew plugins
# Sourced by bootstrap.sh (inherits log_* helpers) or runnable standalone.
#

# Standalone fallback: define log helpers + locate repo if not sourced.
if ! declare -F log_info >/dev/null 2>&1; then
    set -euo pipefail
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
    log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
    log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
    log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
    log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
fi
REPO_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"

# ---- Load brew into this shell (idempotent) ----
load_brew() {
    if [[ -x "$BREW_BIN" ]]; then
        eval "$("$BREW_BIN" shellenv)"
        return 0
    fi
    command -v brew &>/dev/null
}

# ---- Install Homebrew ----
if load_brew; then
    log_success "Homebrew already installed ($(brew --version | head -1))"
else
    log_info "Installing Homebrew prerequisites (build-essential curl file git)..."
    sudo apt-get install -y build-essential procps curl file git
    log_info "Installing Homebrew (non-interactive)..."
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    load_brew || { log_error "Homebrew install failed"; return 1 2>/dev/null || exit 1; }
    log_success "Homebrew installed"
fi

# Make sure shell sessions pick brew up (zshrc/bashrc already eval shellenv; this is a fallback).
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "linuxbrew/.linuxbrew/bin/brew shellenv" "$HOME/.bashrc"; then
    {
        echo ''
        echo '# Homebrew on Linux'
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
    } >> "$HOME/.bashrc"
    log_info "Added brew shellenv to ~/.bashrc"
fi

# ---- Install CLI tools from Brewfile ----
log_info "Installing CLI tools from Brewfile (this can take a while)..."
brew bundle --file="${REPO_DIR}/Brewfile"
log_success "Brewfile packages installed"

# ---- krew + must-have kubectl plugins ----
setup_krew() {
    if ! command -v kubectl &>/dev/null; then
        log_warn "kubectl not found — skipping krew (re-run after brew bundle)"
        return 0
    fi
    if [[ -x "${KREW_ROOT:-$HOME/.krew}/bin/kubectl-krew" ]]; then
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
        log_success "krew installed (PATH wired in .zshrc)"
    fi
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
    log_info "Installing must-have kubectl plugins..."
    kubectl krew update >/dev/null 2>&1 || true
    kubectl krew install \
        tree neat view-secret resource-capacity \
        images who-can node-shell deprecations \
        explore rolesum 2>/dev/null || true
    log_success "krew plugins installed"
}
setup_krew

# ---- Verify ----
verify_brew() {
    log_info "Verifying CLI tools..."
    local missing=() t
    local tools=(eza bat fd rg fzf zoxide atuin direnv btop jq yq starship \
                 git delta lazygit gh gitleaks aws terraform terragrunt ansible \
                 kubectl kubectx helm k9s argocd stern lazydocker dive trivy \
                 go node nvim stow tlrc mkcert gum just dust duf procs btm xh \
                 fx glow yamllint git-absorb tree-sitter kubescape kubecolor \
                 helm-docs kustomize kind helmfile flux)
    for t in "${tools[@]}"; do
        command -v "$t" &>/dev/null || missing+=("$t")
    done
    if (( ${#missing[@]} == 0 )); then
        log_success "VERIFY PASS: all ${#tools[@]} CLI tools resolve on PATH"
    else
        log_warn "VERIFY: missing ${#missing[@]} tool(s): ${missing[*]}"
        log_warn "  (open a new shell so brew shellenv is loaded, then re-check)"
    fi
}
verify_brew
