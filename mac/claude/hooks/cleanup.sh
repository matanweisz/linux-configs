#!/usr/bin/env bash
# SessionEnd hook. Cleans up per-session caches.

set -u

INPUT=$(cat 2>/dev/null || true)
SID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)

if [ -n "$SID" ]; then
  rm -f "/tmp/cc-statusline-${SID}" 2>/dev/null || true
fi

exit 0
