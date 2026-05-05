#!/bin/bash
# =============================================================================
# Claude Code DevOps statusline
# Two lines: top = identity/context, bottom = progress/cost
# =============================================================================

input=$(cat)
MODEL=$(echo "$input"  | jq -r '.model.display_name')
DIR=$(echo "$input"    | jq -r '.workspace.current_dir')
COST=$(echo "$input"   | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input"    | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DUR=$(echo "$input"    | jq -r '.cost.total_duration_ms // 0')
SID=$(echo "$input"    | jq -r '.session_id')
EFFORT=$(echo "$input" | jq -r '.effort.level // "—"')

CACHE="/tmp/cc-statusline-$SID"
if [ ! -f "$CACHE" ] || [ $(($(date +%s) - $(stat -f %m "$CACHE" 2>/dev/null || echo 0))) -gt 5 ]; then
    BR=$(git -C "$DIR" branch --show-current 2>/dev/null)
    KCTX=$(kubectl config current-context 2>/dev/null)
    AWS=${AWS_PROFILE:-default}
    printf '%s|%s|%s' "$BR" "$KCTX" "$AWS" > "$CACHE"
fi
IFS='|' read -r BR KCTX AWS < "$CACHE"

CYAN='\033[36m'; GRN='\033[32m'; YEL='\033[33m'; RED='\033[31m'; DIM='\033[2m'; RST='\033[0m'
[ "$PCT" -ge 90 ] && BC="$RED" || { [ "$PCT" -ge 70 ] && BC="$YEL" || BC="$GRN"; }
F=$((PCT/10)); E=$((10-F))
printf -v FB "%${F}s"; printf -v EB "%${E}s"
BAR="${FB// /█}${EB// /░}"
MIN=$((DUR/60000)); SEC=$(((DUR%60000)/1000))

echo -e "${CYAN}[$MODEL]${RST} ${DIM}${EFFORT}${RST} 📁 ${DIR##*/} 🌿 ${BR:-—} ⎈ ${KCTX:-—} ☁️ ${AWS}"
printf '%b' "${BC}${BAR}${RST} ${PCT}% | ${YEL}\$$(printf '%.2f' "$COST")${RST} | ⏱ ${MIN}m${SEC}s\n"
