#!/usr/bin/env bash
# PreToolUse hook for Bash. Blocks destructive commands.
# Exit 2 -> stderr is fed back to Claude as the block reason.
# Bypass: prefix command with "# CONFIRMED: " to acknowledge.

set -u

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$CMD" ] && exit 0

# Bypass token: user explicitly acknowledged
if printf '%s' "$CMD" | grep -qE '^[[:space:]]*#[[:space:]]*CONFIRMED:'; then
  exit 0
fi

block() {
  printf 'BLOCKED: %s\n' "$1" >&2
  printf 'Command: %s\n' "$CMD" >&2
  printf 'If you are sure, prefix the command with "# CONFIRMED: " to acknowledge.\n' >&2
  exit 2
}

# Filesystem catastrophe
printf '%s' "$CMD" | grep -qE '\brm[[:space:]]+(-[a-zA-Z]*[rRfF][a-zA-Z]*[[:space:]]+|-r[[:space:]]+-f[[:space:]]+|-f[[:space:]]+-r[[:space:]]+)/[[:space:]]*($|[^a-zA-Z0-9._-])' \
  && block "rm -rf on / detected"
printf '%s' "$CMD" | grep -qE '\brm[[:space:]]+(-[a-zA-Z]*[rRfF][a-zA-Z]*[[:space:]]+|--recursive[[:space:]]+--force[[:space:]]+|--force[[:space:]]+--recursive[[:space:]]+)(\$HOME|~/?|/Users/[^[:space:]/]+/?)([[:space:]]|$)' \
  && block "rm -rf on \$HOME detected"
printf '%s' "$CMD" | grep -qE ':\(\)[[:space:]]*\{[[:space:]]*:\|:&[[:space:]]*\};[[:space:]]*:' \
  && block "fork bomb detected"
printf '%s' "$CMD" | grep -qE '\bdd[[:space:]]+if=.*of=/dev/(sd[a-z]|nvme|disk)' \
  && block "dd to raw disk device detected"
printf '%s' "$CMD" | grep -qE '\bmkfs(\.[a-z0-9]+)?[[:space:]]+/dev/' \
  && block "mkfs on disk device detected"
printf '%s' "$CMD" | grep -qE '\b(shutdown|reboot|halt|poweroff|init[[:space:]]+0)\b' \
  && block "system power command detected"

# Force-push to mainline branches
printf '%s' "$CMD" | grep -qE '\bgit[[:space:]]+push[[:space:]]+(.*[[:space:]])?(-f|--force|--force-with-lease)([[:space:]]|=)([[:space:]]*[^[:space:]]+[[:space:]]+)?(origin[[:space:]]+)?(main|master|prod|prd)\b' \
  && block "force-push to mainline branch detected"
printf '%s' "$CMD" | grep -qE '\bgit[[:space:]]+push[[:space:]]+.*\bmain\b.*(-f|--force)' \
  && block "force-push to main detected"

# Production-context kubectl mutations
printf '%s' "$CMD" | grep -qE '\bkubectl[[:space:]]+(delete|apply|exec|patch|edit|replace|drain|cordon|scale|rollout)\b.*--context[= ][^[:space:]]*(prod|prd|production)' \
  && block "kubectl mutation against a prod context"
# Detect prod context via current-context in same line: e.g. `kubectl delete ns foo` after `kubectl config use-context prod-...`
# We can't see prior commands; rely on --context flag check above + ask-tier permissions.

# helm against prod (when --kube-context names prod)
printf '%s' "$CMD" | grep -qE '\bhelm[[:space:]]+(install|upgrade|uninstall|delete|rollback)\b.*--kube-context[= ][^[:space:]]*(prod|prd|production)' \
  && block "helm mutation against a prod kube-context"

# Terraform destroy (regardless of dir)
printf '%s' "$CMD" | grep -qE '\bterraform[[:space:]]+destroy\b' \
  && block "terraform destroy detected"
printf '%s' "$CMD" | grep -qE '\btofu[[:space:]]+destroy\b' \
  && block "tofu destroy detected"

# Cloud delete/terminate verbs (catch-all on top of ask-tier)
printf '%s' "$CMD" | grep -qE '\baws[[:space:]]+[a-z0-9-]+[[:space:]]+(terminate-instances|delete-db-instance|delete-db-cluster|delete-bucket|delete-load-balancer)\b' \
  && block "destructive AWS verb detected"
printf '%s' "$CMD" | grep -qE '\bgcloud[[:space:]]+([a-z0-9-]+[[:space:]]+){1,3}delete\b' \
  && block "gcloud delete detected"

# sudo (defense in depth even though permissions also deny it)
printf '%s' "$CMD" | grep -qE '(^|[^a-zA-Z0-9_-])sudo[[:space:]]' \
  && block "sudo is not allowed"

# chmod 777 on sensitive paths
printf '%s' "$CMD" | grep -qE '\bchmod[[:space:]]+(-R[[:space:]]+)?777[[:space:]]+(/|/etc|/usr|/var|\$HOME|~/?|/Users/)' \
  && block "chmod 777 on sensitive path detected"

# Curl|bash and wget|sh
printf '%s' "$CMD" | grep -qE '\b(curl|wget)[[:space:]]+[^|]+\|[[:space:]]*(bash|sh|zsh)\b' \
  && block "piping remote content to a shell detected"

exit 0
