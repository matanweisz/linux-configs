#!/usr/bin/env bash
# PostToolUse hook for Edit|Write|MultiEdit. Auto-formats edited files.
# Async: never blocks Claude. No-op when formatter not installed.

set -u

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0

# Skip files outside the user's home or in vendor/node_modules/.terraform
case "$FILE" in
  */node_modules/*|*/.terraform/*|*/vendor/*|*/.git/*) exit 0 ;;
esac

ext="${FILE##*.}"
base="${FILE##*/}"

run() { command -v "$1" >/dev/null 2>&1 && "$@" >/dev/null 2>&1 || true; }

case "$ext" in
  tf|tfvars)         run terraform fmt -no-color "$FILE" ;;
  hcl)               run terraform fmt -no-color "$FILE" ;;
  yaml|yml)          run prettier --write --log-level silent "$FILE" ;;
  json)              run prettier --write --log-level silent "$FILE" ;;
  md|mdx)            run prettier --write --log-level silent --prose-wrap preserve "$FILE" ;;
  sh|bash|zsh)       run shfmt -w -i 2 -bn -ci "$FILE" ;;
  go)                run gofmt -w "$FILE" ;;
  py)                run ruff format "$FILE" || run black --quiet "$FILE" ;;
  ts|tsx|js|jsx|css) run prettier --write --log-level silent "$FILE" ;;
esac

# Special-cased filenames without standard extensions
case "$base" in
  Dockerfile|Dockerfile.*) ;;  # no formatter wired
  Makefile|makefile)        ;;  # leave alone (tabs matter)
esac

exit 0
