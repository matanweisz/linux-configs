#!/usr/bin/env bash
# PostToolUse hook for Bash. Appends an audit record per command.
# Async: never blocks Claude.

set -u

INPUT=$(cat)
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
MONTH=$(date -u +"%Y-%m")

LOG_DIR="$HOME/.claude/audit"
mkdir -p "$LOG_DIR" 2>/dev/null
LOG_FILE="$LOG_DIR/${MONTH}.jsonl"

# Pick fields and shape into a single JSON line.
printf '%s' "$INPUT" | jq -c --arg ts "$TS" '{
  ts: $ts,
  session_id: (.session_id // null),
  cwd: (.cwd // null),
  tool: (.tool_name // null),
  command: (.tool_input.command // null),
  description: (.tool_input.description // null),
  exit_code: (.tool_response.exit_code // null),
  ok: (.tool_response.success // null)
}' >> "$LOG_FILE" 2>/dev/null || true

exit 0
