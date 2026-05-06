#!/usr/bin/env bash
# Three-line Claude Code status line for DevOps / CloudInfra IL.
# Designed for Ghostty + Nerd Font + Nord-ish palette.
# Caches expensive subshells (git/kubectl/gcloud/aws/tf) per session for 5s.
#
# Layout (font-agnostic — no Nerd Font glyphs required):
#   L1 (identity):    MODEL effort * │ DIR │ wt:NAME │ BRANCH +S ~M ^A vB │ @AGENT
#   L2 (environment): k8s:CTX/NS │ gcp:PROJ │ aws:PROFILE@ACCT │ tf:WS    (only if any)
#   L3 (session):     [████░░] 42% │ $0.42 │ 12m34s │ +156/-23 │ vim │ vX.Y.Z
#
# Mock test:
#   echo '{"model":{"display_name":"Opus","id":"claude-opus-4-7"},"workspace":{"current_dir":"'$PWD'"},"context_window":{"used_percentage":42},"cost":{"total_cost_usd":0.42,"total_duration_ms":754321,"total_lines_added":156,"total_lines_removed":23},"session_id":"test","effort":{"level":"high"},"thinking":{"enabled":true},"version":"2.1.90","exceeds_200k_tokens":false}' | ~/.claude/statusline.sh

set -u

INPUT=$(cat)

# ---------- one-pass jq parse ----------
mapfile -t _F < <(printf '%s' "$INPUT" | jq -r '
  .model.display_name // "?",
  (.effort.level // ""),
  (.thinking.enabled // false | tostring),
  (.workspace.current_dir // .cwd // "?"),
  (.context_window.used_percentage // 0 | floor | tostring),
  (.cost.total_cost_usd // 0 | tostring),
  (.cost.total_duration_ms // 0 | tostring),
  (.cost.total_lines_added // 0 | tostring),
  (.cost.total_lines_removed // 0 | tostring),
  (.session_id // "no-session"),
  (.version // ""),
  (.output_style.name // ""),
  (.exceeds_200k_tokens // false | tostring),
  (.agent.name // ""),
  (.worktree.name // ""),
  (.worktree.branch // ""),
  (.vim.mode // ""),
  (.workspace.git_worktree // ""),
  (.rate_limits.five_hour.used_percentage // "" | tostring),
  (.rate_limits.seven_day.used_percentage // "" | tostring)
')

while [ "${#_F[@]}" -lt 20 ]; do _F+=(""); done

MODEL="${_F[0]}"
EFFORT="${_F[1]}"
THINKING="${_F[2]}"
DIR="${_F[3]}"
PCT="${_F[4]}"
COST="${_F[5]}"
DUR_MS="${_F[6]}"
LINES_ADD="${_F[7]}"
LINES_REM="${_F[8]}"
SID="${_F[9]}"
VERSION="${_F[10]}"
OUT_STYLE="${_F[11]}"
EXC_200K="${_F[12]}"
AGENT_NAME="${_F[13]}"
WTNAME="${_F[14]}"
WTBRANCH="${_F[15]}"
VIM_MODE="${_F[16]}"
GIT_WT="${_F[17]}"
RATE5="${_F[18]}"
RATE7="${_F[19]}"

DIR_BASENAME="${DIR##*/}"

# Defensive coercion
PCT=${PCT%%.*}
PCT=${PCT:-0}
DUR_MS=${DUR_MS%%.*}
DUR_MS=${DUR_MS:-0}
LINES_ADD=${LINES_ADD%%.*}
LINES_ADD=${LINES_ADD:-0}
LINES_REM=${LINES_REM%%.*}
LINES_REM=${LINES_REM:-0}
case "$PCT" in *[!0-9]*) PCT=0 ;; esac
case "$DUR_MS" in *[!0-9]*) DUR_MS=0 ;; esac
case "$LINES_ADD" in *[!0-9]*) LINES_ADD=0 ;; esac
case "$LINES_REM" in *[!0-9]*) LINES_REM=0 ;; esac

# ---------- color palette (Nord-ish, truecolor) ----------
RST=$'\e[0m'
DIM=$'\e[2m'
BOLD=$'\e[1m'

FG_BLUE=$'\e[38;2;129;161;193m'   # nord9
FG_CYAN=$'\e[38;2;136;192;208m'   # nord8
FG_TEAL=$'\e[38;2;143;188;187m'   # nord7
FG_GREEN=$'\e[38;2;163;190;140m'  # nord14
FG_YELLOW=$'\e[38;2;235;203;139m' # nord13
FG_ORANGE=$'\e[38;2;208;135;112m' # nord12
FG_RED=$'\e[38;2;191;97;106m'     # nord11
FG_PURPLE=$'\e[38;2;180;142;173m' # nord15
FG_GREY=$'\e[38;2;76;86;106m'     # nord3

case "${TERM:-}" in
linux | dumb) SEP="|" ;;
*) SEP="│" ;;
esac

# Single source of truth for inter-segment separators.
# Brighter grey (nord4 dim) so it's visible against most terminal themes.
FG_SEP=$'\e[38;2;120;130;150m'
SEPSTR=" ${FG_SEP}${SEP}${RST} "

# ---------- caching ----------
CACHE_FILE="/tmp/cc-statusline-${SID}"
CACHE_TTL=5

cache_age() {
    local mtime
    mtime=$(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
    echo $(($(date +%s) - mtime))
}

cache_is_stale() {
    [ ! -f "$CACHE_FILE" ] || [ "$(cache_age)" -gt "$CACHE_TTL" ]
}

refresh_cache() {
    local branch dirty staged modified ahead behind upstream
    local kctx kns gcp_proj aws_acct aws_role tf_ws

    if git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
        branch=$(git -C "$DIR" branch --show-current 2>/dev/null)
        [ -z "$branch" ] && branch=$(git -C "$DIR" rev-parse --short HEAD 2>/dev/null)
        if [ -n "$(git -C "$DIR" status --porcelain 2>/dev/null | head -1)" ]; then dirty=1; else dirty=0; fi
        staged=$(git -C "$DIR" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        modified=$(git -C "$DIR" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        upstream=$(git -C "$DIR" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
        if [ -n "$upstream" ]; then
            ahead=$(git -C "$DIR" rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)
            behind=$(git -C "$DIR" rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)
        else
            ahead=0
            behind=0
        fi
    fi

    if command -v kubectl >/dev/null 2>&1; then
        kctx=$(timeout 1 kubectl config current-context 2>/dev/null || true)
        [ -n "$kctx" ] && kns=$(timeout 1 kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null || true)
        [ -z "${kns:-}" ] && kns=""
    fi

    if command -v gcloud >/dev/null 2>&1; then
        gcp_proj=$(timeout 1 gcloud config get-value core/project 2>/dev/null | tr -d '[:space:]' || true)
    fi

    if [ -n "${AWS_PROFILE:-}" ] && command -v aws >/dev/null 2>&1; then
        local sts
        sts=$(timeout 2 aws sts get-caller-identity --query '[Account,Arn]' --output text 2>/dev/null || true)
        if [ -n "$sts" ]; then
            aws_acct=$(printf '%s' "$sts" | awk '{print $1}')
            aws_role=$(printf '%s' "$sts" | awk '{print $2}' | awk -F'[:/]' '{print $(NF-1)}')
        fi
    fi

    if ls "$DIR"/*.tf >/dev/null 2>&1 && command -v terraform >/dev/null 2>&1; then
        tf_ws=$(cd "$DIR" && timeout 1 terraform workspace show 2>/dev/null || true)
    fi

    printf '%s\n' "${branch:-}|${dirty:-0}|${staged:-0}|${modified:-0}|${ahead:-0}|${behind:-0}|${kctx:-}|${kns:-}|${gcp_proj:-}|${aws_acct:-}|${aws_role:-}|${tf_ws:-}" >"$CACHE_FILE"
}

cache_is_stale && refresh_cache 2>/dev/null
IFS='|' read -r G_BRANCH G_DIRTY G_STAGED G_MODIFIED G_AHEAD G_BEHIND KCTX KNS GCP_PROJ AWS_ACCT AWS_ROLE TF_WS <"$CACHE_FILE" 2>/dev/null
G_BRANCH="${G_BRANCH:-}"
G_DIRTY="${G_DIRTY:-0}"
G_STAGED="${G_STAGED:-0}"
G_MODIFIED="${G_MODIFIED:-0}"
G_AHEAD="${G_AHEAD:-0}"
G_BEHIND="${G_BEHIND:-0}"

# ---------- helpers ----------
# Append a segment to a line variable. First call writes bare; later calls prepend SEPSTR.
# Usage: add LINE_VAR "rendered text"
add() {
    local _name=$1 _text=$2
    local _cur=${!_name}
    if [ -z "$_cur" ]; then
        eval "$_name=\$_text"
    else
        eval "$_name=\$_cur\$SEPSTR\$_text"
    fi
}

# ---------- LINE 1: identity (model, dir, worktree, git, agent) ----------
L1=""

# Model + effort + thinking dot
MODEL_SEG="${BOLD}${FG_CYAN}${MODEL}${RST}"
[ -n "$EFFORT" ] && MODEL_SEG+=" ${DIM}${EFFORT}${RST}"
[ "$THINKING" = "true" ] && MODEL_SEG+=" ${FG_PURPLE}*${RST}"
add L1 "$MODEL_SEG"

# Dir
add L1 "${FG_BLUE}${DIR_BASENAME}${RST}"

# Worktree
if [ -n "$WTNAME" ] || [ -n "$GIT_WT" ]; then
    add L1 "${FG_TEAL}wt:${WTNAME:-$GIT_WT}${RST}"
fi

# Git
if [ -n "$G_BRANCH" ]; then
    GIT_COLOR="$FG_GREEN"
    [ "$G_DIRTY" = "1" ] && GIT_COLOR="$FG_YELLOW"
    GIT_SEG="${GIT_COLOR}${G_BRANCH}${RST}"
    [ "$G_STAGED" -gt 0 ] && GIT_SEG+=" ${FG_GREEN}+${G_STAGED}${RST}"
    [ "$G_MODIFIED" -gt 0 ] && GIT_SEG+=" ${FG_YELLOW}~${G_MODIFIED}${RST}"
    [ "$G_AHEAD" -gt 0 ] && GIT_SEG+=" ${FG_CYAN}^${G_AHEAD}${RST}"
    [ "$G_BEHIND" -gt 0 ] && GIT_SEG+=" ${FG_ORANGE}v${G_BEHIND}${RST}"
    add L1 "$GIT_SEG"
fi

# Agent
[ -n "$AGENT_NAME" ] && add L1 "${FG_PURPLE}@${AGENT_NAME}${RST}"

# ---------- LINE 2: environment (k8s + cloud + tf) ----------
L2=""

if [ -n "$KCTX" ]; then
    KCTX_SHORT="$KCTX"
    [ ${#KCTX_SHORT} -gt 32 ] && KCTX_SHORT="${KCTX_SHORT:0:29}…"
    KCTX_COLOR="$FG_GREEN"
    case "$KCTX" in
    *prd* | *prod* | *production*) KCTX_COLOR="$FG_RED" ;;
    *stg* | *staging* | *soak*) KCTX_COLOR="$FG_YELLOW" ;;
    esac
    K8S_SEG="${KCTX_COLOR}k8s:${KCTX_SHORT}${RST}"
    [ -n "$KNS" ] && K8S_SEG+="${FG_GREY}/${RST}${FG_TEAL}${KNS}${RST}"
    add L2 "$K8S_SEG"
fi

if [ -n "$GCP_PROJ" ]; then
    GCP_COLOR="$FG_BLUE"
    case "$GCP_PROJ" in
    *prd* | *prod*) GCP_COLOR="$FG_RED" ;;
    *stg* | *staging*) GCP_COLOR="$FG_YELLOW" ;;
    *dev*) GCP_COLOR="$FG_GREEN" ;;
    esac
    add L2 "${GCP_COLOR}gcp:${GCP_PROJ}${RST}"
fi

if [ -n "$AWS_ACCT" ]; then
    AWS_LABEL="${AWS_PROFILE:-default}"
    AWS_COLOR="$FG_ORANGE"
    case "$AWS_LABEL" in *prd* | *prod*) AWS_COLOR="$FG_RED" ;; esac
    add L2 "${AWS_COLOR}aws:${AWS_LABEL}${RST}${FG_GREY}@${RST}${DIM}${AWS_ACCT}${RST}"
fi

if [ -n "$TF_WS" ]; then
    TF_COLOR="$FG_PURPLE"
    case "$TF_WS" in *prd* | *prod*) TF_COLOR="$FG_RED" ;; esac
    add L2 "${TF_COLOR}tf:${TF_WS}${RST}"
fi

# ---------- LINE 3: session (context bar, cost, duration, lines, vim, version) ----------
L3=""

# Context bar (12 wide)
BAR_W=12
FILLED=$((PCT * BAR_W / 100))
[ "$FILLED" -gt "$BAR_W" ] && FILLED=$BAR_W
EMPTY=$((BAR_W - FILLED))

if [ "$PCT" -ge 90 ]; then
    BAR_COLOR="$FG_RED"
elif [ "$PCT" -ge 70 ]; then
    BAR_COLOR="$FG_YELLOW"
else
    BAR_COLOR="$FG_GREEN"
fi

printf -v FILL "%${FILLED}s"
printf -v PAD "%${EMPTY}s"
BAR_SEG="${BAR_COLOR}${FILL// /█}${RST}${FG_GREY}${PAD// /░}${RST} ${BOLD}${PCT}%${RST}"
[ "$EXC_200K" = "true" ] && BAR_SEG+=" ${FG_RED}!200K+${RST}"
add L3 "$BAR_SEG"

# Cost
COST_FMT=$(printf '$%.2f' "$COST" 2>/dev/null || echo '$0.00')
add L3 "${FG_YELLOW}${COST_FMT}${RST}"

# Duration
MINS=$((DUR_MS / 60000))
SECS=$(((DUR_MS % 60000) / 1000))
HRS=$((MINS / 60))
MINS=$((MINS % 60))
if [ "$HRS" -gt 0 ]; then
    DUR_FMT=$(printf '%dh%02dm%02ds' "$HRS" "$MINS" "$SECS")
else
    DUR_FMT=$(printf '%dm%02ds' "$MINS" "$SECS")
fi
add L3 "${FG_CYAN} ${DUR_FMT}${RST}"

# Lines
if [ "$LINES_ADD" -gt 0 ] || [ "$LINES_REM" -gt 0 ]; then
    add L3 "${FG_GREEN}+${LINES_ADD}${RST}${FG_GREY}/${RST}${FG_RED}-${LINES_REM}${RST}"
fi

# Rate limits
if [ -n "$RATE5" ] || [ -n "$RATE7" ]; then
    RATE_PART=""
    if [ -n "$RATE5" ]; then
        R5=$(printf '%.0f' "$RATE5" 2>/dev/null || echo 0)
        RC="$FG_GREEN"
        [ "$R5" -ge 80 ] && RC="$FG_RED" || { [ "$R5" -ge 60 ] && RC="$FG_YELLOW"; }
        RATE_PART+="${RC}5h:${R5}%${RST}"
    fi
    if [ -n "$RATE7" ]; then
        R7=$(printf '%.0f' "$RATE7" 2>/dev/null || echo 0)
        RC="$FG_GREEN"
        [ "$R7" -ge 80 ] && RC="$FG_RED" || { [ "$R7" -ge 60 ] && RC="$FG_YELLOW"; }
        [ -n "$RATE_PART" ] && RATE_PART+="${FG_GREY}·${RST}"
        RATE_PART+="${RC}7d:${R7}%${RST}"
    fi
    add L3 "$RATE_PART"
fi

# Output style (only if non-default/non-empty)
if [ -n "$OUT_STYLE" ] && [ "$OUT_STYLE" != "default" ]; then
    add L3 "${DIM}[${OUT_STYLE}]${RST}"
fi

# Vim mode
[ -n "$VIM_MODE" ] && add L3 "${DIM}${VIM_MODE}${RST}"

# Version
[ -n "$VERSION" ] && add L3 "${DIM}v${VERSION}${RST}"

# ---------- emit ----------
printf '%b\n' "$L1"
[ -n "$L2" ] && printf '%b\n' "$L2"
printf '%b\n' "$L3"

exit 0
