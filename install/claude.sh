#!/usr/bin/env bash
#
# Claude Code: native install + sanitized config (settings, statusline, hooks,
# agents, commands, rules, output-styles). User-level (no sudo).
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
SRC="$REPO_DIR/claude"

backup_if_exists() {
    local p="$1"
    if [[ -e "$p" && ! -L "$p" ]]; then
        mv "$p" "${p}.backup.$(date +%Y%m%d%H%M%S)"
        log_info "Backed up existing $p"
    fi
}

# ---- Install Claude Code (native installer, user-level) ----
if command -v claude &>/dev/null; then
    log_success "Claude Code already installed ($(claude --version 2>/dev/null || echo present))"
else
    log_info "Installing Claude Code via official native installer..."
    curl -fsSL https://claude.ai/install.sh | bash
    export PATH="$HOME/.local/bin:$PATH"
    command -v claude &>/dev/null && log_success "Claude Code installed" \
        || log_warn "claude not on PATH yet — open a new shell (it installs to ~/.local/bin)"
fi

# ---- Restore sanitized config ----
log_info "Installing Claude config to ~/.claude ..."
mkdir -p "$HOME/.claude"

backup_if_exists "$HOME/.claude/settings.json"
cp "$SRC/settings.json" "$HOME/.claude/settings.json"

cp "$SRC/statusline.sh" "$HOME/.claude/statusline.sh"
chmod +x "$HOME/.claude/statusline.sh"

[[ -f "$SRC/CLAUDE.md" ]] && cp "$SRC/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

for sub in agents commands hooks output-styles rules; do
    if [[ -d "$SRC/$sub" ]]; then
        mkdir -p "$HOME/.claude/$sub"
        cp -R "$SRC/$sub/." "$HOME/.claude/$sub/"
    fi
done
chmod +x "$HOME"/.claude/hooks/*.sh 2>/dev/null || true
log_success "Claude config installed (sanitized — standard Anthropic login)"

# ---- Verify ----
log_info "Verifying Claude Code setup..."
ok=1
command -v claude &>/dev/null && log_success "  claude on PATH" || { log_warn "  claude not on PATH"; ok=0; }
if command -v jq &>/dev/null && jq -e . "$HOME/.claude/settings.json" >/dev/null 2>&1; then
    log_success "  settings.json is valid JSON"
else
    log_warn "  settings.json failed JSON validation"; ok=0
fi
if bash "$HOME/.claude/statusline.sh" </dev/null >/dev/null 2>&1; then
    log_success "  statusline.sh runs"
else
    log_warn "  statusline.sh exited non-zero (often fine without a live session payload)"
fi
for h in "$HOME"/.claude/hooks/*.sh; do [[ -x "$h" ]] || { log_warn "  not executable: $h"; ok=0; }; done
(( ok == 1 )) && log_success "VERIFY PASS: Claude Code configured" || log_warn "VERIFY: see warnings above"
