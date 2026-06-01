#!/usr/bin/env bash
# Notification hook. Linux desktop notification via notify-send.
# Async: never blocks Claude.

set -u

INPUT=$(cat 2>/dev/null || true)
MSG=$(printf '%s' "$INPUT" | jq -r '.message // "Claude needs your attention"' 2>/dev/null)
TITLE=$(printf '%s' "$INPUT" | jq -r '.title // "Claude Code"' 2>/dev/null)

if command -v notify-send >/dev/null 2>&1; then
  notify-send -a "Claude Code" -u normal -- "${TITLE}" "${MSG}" >/dev/null 2>&1 || true
elif command -v osascript >/dev/null 2>&1; then
  # macOS fallback so the file stays portable across both machines
  MSG_ESC=${MSG//\"/\\\"}; TITLE_ESC=${TITLE//\"/\\\"}
  osascript -e "display notification \"${MSG_ESC}\" with title \"${TITLE_ESC}\" sound name \"Glass\"" >/dev/null 2>&1 || true
fi

exit 0
