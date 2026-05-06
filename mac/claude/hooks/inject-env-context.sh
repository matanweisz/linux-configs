#!/usr/bin/env bash
# SessionStart hook (matchers: startup, resume, compact).
# Anything we print to stdout gets appended to Claude's context as additional info.

set -u

INPUT=$(cat 2>/dev/null || true)
SOURCE=$(printf '%s' "$INPUT" | jq -r '.source // "startup"' 2>/dev/null || echo "startup")
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
[ -z "$CWD" ] && CWD="$PWD"

emit() { printf '%s\n' "$*"; }

emit "## Live environment context"
emit ""
emit "_Captured at session $SOURCE. Verify before acting._"
emit ""

# Git
if git -C "$CWD" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null)
  DIRTY=""
  if [ -n "$(git -C "$CWD" status --porcelain 2>/dev/null)" ]; then
    DIRTY=" (dirty)"
  fi
  emit "- **git**: branch=\`${BRANCH:-detached}\`${DIRTY}"
fi

# Kubernetes
if command -v kubectl >/dev/null 2>&1; then
  KCTX=$(timeout 2 kubectl config current-context 2>/dev/null || true)
  KNS=$(timeout 2 kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null || true)
  [ -n "$KCTX" ] && emit "- **kubectl**: context=\`${KCTX}\` namespace=\`${KNS:-default}\`"
fi

# AWS
if [ -n "${AWS_PROFILE:-}" ] || [ -f "$HOME/.aws/config" ]; then
  AWS_PROF="${AWS_PROFILE:-default}"
  if command -v aws >/dev/null 2>&1; then
    STS=$(timeout 3 aws sts get-caller-identity --query '[Account,Arn]' --output text 2>/dev/null || true)
    if [ -n "$STS" ]; then
      ACCT=$(printf '%s' "$STS" | awk '{print $1}')
      ARN=$(printf '%s' "$STS" | awk '{print $2}')
      emit "- **aws**: profile=\`${AWS_PROF}\` account=\`${ACCT}\` arn=\`${ARN}\`"
    else
      emit "- **aws**: profile=\`${AWS_PROF}\` (sts call failed or no creds)"
    fi
  fi
fi

# GCP
if command -v gcloud >/dev/null 2>&1; then
  GCP_PROJ=$(timeout 2 gcloud config get-value core/project 2>/dev/null | tr -d '[:space:]' || true)
  GCP_ACCT=$(timeout 2 gcloud config get-value core/account 2>/dev/null | tr -d '[:space:]' || true)
  if [ -n "$GCP_PROJ" ] || [ -n "$GCP_ACCT" ]; then
    emit "- **gcloud**: project=\`${GCP_PROJ:-unset}\` account=\`${GCP_ACCT:-unset}\`"
  fi
fi

# Terraform workspace (only if .tf files in cwd)
if ls "$CWD"/*.tf >/dev/null 2>&1 && command -v terraform >/dev/null 2>&1; then
  TF_WS=$(cd "$CWD" && timeout 2 terraform workspace show 2>/dev/null || true)
  [ -n "$TF_WS" ] && emit "- **terraform**: workspace=\`${TF_WS}\`"
fi

emit ""

# Re-inject critical rules after compaction so they survive
if [ "$SOURCE" = "compact" ]; then
  emit "## Critical rules (re-injected after compaction)"
  emit ""
  emit "- Never run \`terraform apply\` or \`terraform destroy\` without showing the plan first."
  emit "- Never run \`kubectl apply\` / \`kubectl delete\` against a prod context without explicit approval."
  emit "- Never push to \`main\` / \`master\` directly. Open a PR."
  emit "- Secret files (\`~/.aws/credentials\`, \`*.pem\`, \`*.key\`, \`.env\`) are blocked at the Read layer — do not try to bypass."
  emit "- Honor the GF naming convention: \`gf-<tier>-<func-app>-<cs|ns>-gcp\`."
  emit ""
fi

exit 0
