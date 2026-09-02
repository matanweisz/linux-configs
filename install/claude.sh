#!/usr/bin/env bash
#
# Claude Code: native install + sanitized config (settings, statusline, hooks,
# agents, commands, rules, output-styles, skills) + plugins.
#
# ONE profile on Ubuntu: ~/.claude, used by the plain `claude` command.
# The macOS stack still runs a second `~/.claude-personal` profile (see
# mac/bootstrap.sh and mac/claude/RESTORE-NOTES.md); Ubuntu deliberately does
# not — there is a single config here, and claude/settings.json is it.
#
# User-level (no sudo).
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
PROFILE="$HOME/.claude"

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
log_info "Installing Claude config to $PROFILE ..."
mkdir -p "$PROFILE"

cp "$SRC/statusline.sh" "$PROFILE/statusline.sh"
chmod +x "$PROFILE/statusline.sh"

[[ -f "$SRC/CLAUDE.md" ]] && cp "$SRC/CLAUDE.md" "$PROFILE/CLAUDE.md"

for sub in agents commands hooks output-styles rules; do
    if [[ -d "$SRC/$sub" ]]; then
        mkdir -p "$PROFILE/$sub"
        cp -R "$SRC/$sub/." "$PROFILE/$sub/"
    fi
done
# Skills are shared with the macOS stack (only copy that exists in the repo).
if [[ -d "$REPO_DIR/mac/claude/skills" ]]; then
    mkdir -p "$PROFILE/skills"
    cp -R "$REPO_DIR/mac/claude/skills/." "$PROFILE/skills/"
fi
chmod +x "$PROFILE"/hooks/*.sh 2>/dev/null || true

backup_if_exists "$PROFILE/settings.json"
cp "$SRC/settings.json" "$PROFILE/settings.json"

log_success "Claude config installed (sanitized — standard Anthropic login)"

# ---- Restore plugins + their marketplaces ----
# Plugin CODE is not tracked in this repo (it lives under ~/.claude/plugins/ and is
# managed by Claude Code), so restoring settings alone leaves every plugin declared
# but not installed — which is how ponytail/humanizer and the skills they provide
# went missing on this machine. settings.json IS the manifest: it carries
# `extraKnownMarketplaces` (name -> github repo) and `enabledPlugins`
# (<plugin>@<marketplace> -> bool). Drive the CLI from it so there is exactly one
# source of truth; mac/claude/plugins.md stays a human-readable mirror.
#
# Every step is idempotent: marketplaces and plugins already present are skipped.
# Requires network + a logged-in claude; failures downgrade to warnings so a
# bootstrap run never dies here.
restore_plugins() {
    local settings="$PROFILE/settings.json"
    [[ -f "$settings" ]] || { log_warn "no settings.json — skipping plugins"; return 0; }
    command -v jq &>/dev/null || { log_warn "jq missing — skipping plugin restore"; return 0; }
    command -v claude &>/dev/null || { log_warn "claude not on PATH — skipping plugin restore"; return 0; }

    log_info "Restoring Claude Code plugins (marketplaces + enabled plugins)..."

    # --- marketplaces first; a plugin cannot install without its marketplace ---
    local known name repo
    known="$(claude plugin marketplace list 2>/dev/null || true)"
    while IFS=$'\t' read -r name repo; do
        [[ -n "$name" ]] || continue
        # grep -c, never grep -q: -q exits early and SIGPIPEs the producer, which
        # under `set -o pipefail` inverts the test (see CLAUDE.md gotchas).
        if [[ "$(printf '%s' "$known" | grep -cF -- "$name" || true)" -gt 0 ]]; then
            log_success "  marketplace already known: $name"
        else
            log_info "  adding marketplace $name ($repo)"
            claude plugin marketplace add "$repo" >/dev/null 2>&1 \
                && log_success "  marketplace added: $name" \
                || log_warn "  could not add marketplace: $name"
        fi
    done < <(jq -r '(.extraKnownMarketplaces // {}) | to_entries[]
                    | select(.value.source.source == "github")
                    | "\(.key)\t\(.value.source.repo)"' "$settings" 2>/dev/null)

    # Anything not a github source needs a human — say so rather than fail quietly.
    local other
    other="$(jq -r '(.extraKnownMarketplaces // {}) | to_entries[]
                    | select(.value.source.source != "github") | .key' "$settings" 2>/dev/null || true)"
    [[ -n "$other" ]] && log_warn "  non-github marketplaces need manual add: $other"

    # --- then the plugins ---
    local installed plugin added=0 skipped=0 failed=0
    installed="$(claude plugin list 2>/dev/null || true)"
    while read -r plugin; do
        [[ -n "$plugin" ]] || continue
        if [[ "$(printf '%s' "$installed" | grep -cF -- "$plugin" || true)" -gt 0 ]]; then
            skipped=$((skipped + 1))
            continue
        fi
        if claude plugin install "$plugin" -y --scope user >/dev/null 2>&1; then
            log_success "  installed $plugin"
            added=$((added + 1))
        else
            log_warn "  FAILED $plugin"
            failed=$((failed + 1))
        fi
    done < <(jq -r '(.enabledPlugins // {}) | to_entries[]
                    | select(.value == true) | .key' "$settings" 2>/dev/null)

    log_success "Plugins: $added installed, $skipped already present, $failed failed (restart claude to load)"
}
restore_plugins

# ---- Verify ----
log_info "Verifying Claude Code setup..."
ok=1
command -v claude &>/dev/null && log_success "  claude on PATH" || { log_warn "  claude not on PATH"; ok=0; }
if command -v jq &>/dev/null && jq -e . "$PROFILE/settings.json" >/dev/null 2>&1; then
    log_success "  valid JSON: $PROFILE/settings.json"
else
    log_warn "  failed JSON validation: $PROFILE/settings.json"; ok=0
fi
if bash "$PROFILE/statusline.sh" </dev/null >/dev/null 2>&1; then
    log_success "  statusline.sh runs"
else
    log_warn "  statusline.sh exited non-zero (often fine without a live session payload)"
fi
for sub in agents commands hooks output-styles rules skills; do
    [[ -d "$PROFILE/$sub" ]] || { log_warn "  missing: $PROFILE/$sub"; ok=0; }
done
for h in "$PROFILE"/hooks/*.sh; do [[ -x "$h" ]] || { log_warn "  not executable: $h"; ok=0; }; done

# A second profile here is leftover state, not configuration — Ubuntu is single-profile.
if [[ -d "$HOME/.claude-personal" ]]; then
    log_warn "  ~/.claude-personal exists but is no longer used on Ubuntu — safe to delete"
fi

want="$(jq -r '(.enabledPlugins // {}) | to_entries | map(select(.value == true)) | length' \
    "$PROFILE/settings.json" 2>/dev/null || echo 0)"
have="$(claude plugin list 2>/dev/null | grep -c '@' || true)"
if [[ "${have:-0}" -ge "${want:-0}" && "${want:-0}" -gt 0 ]]; then
    log_success "  plugins: $have/$want installed"
else
    log_warn "  plugins: $have/$want installed"; ok=0
fi

(( ok == 1 )) && log_success "VERIFY PASS: Claude Code configured" || log_warn "VERIFY: see warnings above"
