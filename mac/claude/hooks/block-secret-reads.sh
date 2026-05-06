#!/usr/bin/env bash
# PreToolUse hook for Read. Blocks reads of secret/credential files.
# Exit 2 -> stderr is fed back to Claude as the block reason.

set -u

INPUT=$(cat)
PATH_=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$PATH_" ] && exit 0

block() {
  printf 'BLOCKED read of secret-like path: %s\n' "$PATH_" >&2
  printf 'Reason: %s\n' "$1" >&2
  exit 2
}

# Allow obvious example/template files
case "$PATH_" in
  *.example|*.example.*|*.sample|*.template|*.tmpl|*.tpl) exit 0 ;;
esac

# Direct credential files
case "$PATH_" in
  */.aws/credentials|*/.aws/config) block "AWS credentials" ;;
  */.gcp/credentials*|*/.config/gcloud/*credentials*|*/google_application_credentials.json|*/service-account*.json|*/sa-*.json) block "GCP credentials" ;;
  */.kube/config) block "kubeconfig may contain bearer tokens" ;;
  */.ssh/id_*|*/.ssh/*_rsa|*/.ssh/*_ed25519|*/.ssh/*_ecdsa) block "SSH private key" ;;
  *.pem|*.key|*.p12|*.pfx|*.crt) block "private key/cert file" ;;
  */.netrc|*/.npmrc|*/.pypirc|*/.dockercfg|*/.docker/config.json) block "auth tokens likely present" ;;
  */.env|*/.env.local|*/.env.production|*/.env.prod|*/.env.staging|*/.env.stg) block "env file with secrets" ;;
  */terraform.tfstate|*/terraform.tfstate.backup|*/.terraform/terraform.tfstate) block "Terraform state may contain secrets" ;;
  */vault-token|*/.vault-token) block "Vault token" ;;
  */secrets.yaml|*/secrets.yml|*/sealed-secrets/*.yaml) block "secrets manifest" ;;
esac

# .ssh anywhere in path
case "$PATH_" in
  */.ssh/id_rsa|*/.ssh/id_ed25519|*/.ssh/id_ecdsa) block "SSH private key" ;;
esac

exit 0
