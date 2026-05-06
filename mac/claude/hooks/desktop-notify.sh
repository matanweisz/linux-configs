#!/usr/bin/env bash
# Notification hook. macOS desktop notification.
# Async: never blocks Claude.

set -u

INPUT=$(cat 2>/dev/null || true)
MSG=$(printf '%s' "$INPUT" | jq -r '.message // "Claude needs your attention"' 2>/dev/null)
TITLE=$(printf '%s' "$INPUT" | jq -r '.title // "Claude Code"' 2>/dev/null)

# Escape double quotes for AppleScript
MSG_ESC=${MSG//\"/\\\"}
TITLE_ESC=${TITLE//\"/\\\"}

if command -v osascript >/dev/null 2>&1; then
  osascript -e "display notification \"${MSG_ESC}\" with title \"${TITLE_ESC}\" sound name \"Glass\"" >/dev/null 2>&1 || true
fi

exit 0
