---
description: Step-by-step credential rotation runbook (read-only — outputs steps, doesn't execute)
argument-hint: "<aws|gcp|kube|atlas|env0|github>"
allowed-tools: Read, Grep, Glob
---

Print a precise rotation runbook for the requested credential type. **This command never executes anything** — it produces the checklist for the human to follow.

## Steps to print, by type

### `aws`
1. List active access keys: `aws iam list-access-keys --user-name <you>`
2. Create new key: `aws iam create-access-key --user-name <you>` → record output securely
3. Update local `~/.aws/credentials` (or `aws configure --profile <name>`)
4. Test: `aws sts get-caller-identity`
5. Update CI secrets (which CI? confirm with user)
6. Disable old key: `aws iam update-access-key --access-key-id <old> --status Inactive`
7. Wait 24h, then delete: `aws iam delete-access-key --access-key-id <old>`
8. Notify in `#ie-cloudinfra-il-public` if it was a shared role.

### `gcp`
1. `gcloud auth login` (or `gcloud auth application-default login` for ADC)
2. For service-account keys: avoid creating them — use Workload Identity instead
3. If you must rotate an SA key: `gcloud iam service-accounts keys create new.json --iam-account <sa>`, swap, then `gcloud iam service-accounts keys delete <old-id>`
4. Verify: `gcloud auth list` and `gcloud config list`

### `kube`
1. For human user: refresh OIDC via `gcloud container clusters get-credentials <cluster> --region <region>` (re-runs OIDC flow)
2. For service-account / robot: rotate the underlying token via the SA's mechanism (GitHub OIDC, Vault, etc.)
3. Test: `kubectl auth whoami` (or `kubectl get ns` as a sanity check)
4. **NEVER** copy bearer tokens from a kubeconfig and paste them anywhere — they're long-lived and high-blast-radius.

### `atlas` (MongoDB Atlas)
1. Login to Atlas UI → Project → Access Manager → Database Access
2. Find the user, click "Edit", change password (or rotate via API)
3. Update Vault / app-secrets manager (don't paste in PRs)
4. Roll the consuming pods so they pick up the new secret
5. Verify connectivity from the app side
6. Notify `#ie-mongodb-atlas-cluster-cloudinfra-il-core-alerts` if it's a shared cluster.

### `env0`
1. env0 personal API tokens: log in → User → API tokens → revoke + reissue
2. Org-level: ask Arkady (only org admins can rotate)
3. Update local `ENV0_API_KEY` env var (or 1Password entry)

### `github` (`git.zoominfo.com`)
1. Profile → Personal Access Tokens → revoke old
2. Generate new with **minimum scopes** (read-only for `gh` CLI; `repo` for PR creation)
3. `gh auth login --hostname git.zoominfo.com` to re-auth
4. Update CI secrets if applicable

## Output format

```markdown
# Rotate <type> credentials

## Why now
<empty — user fills in: scheduled rotation? incident response? offboarding?>

## Steps
- [ ] step 1
- [ ] step 2
- ...

## Verification
- [ ] <how to confirm new creds work>

## Cleanup
- [ ] <how/when to disable old creds>

## Notify
- <which Slack channel / Jira>
```

## Hard rules

- Print the runbook **only**. Never call `aws`, `gcloud`, `kubectl`, `gh`, or any mutating tool.
- Never echo or print credentials.
- Recommend secret managers (Vault / 1Password / AWS Secrets Manager) rather than env files.
