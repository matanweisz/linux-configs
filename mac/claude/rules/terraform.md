---
paths:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/*.hcl"
---

# Terraform working rules

Applies to: Terraform / OpenTofu in any directory.

## Workflow

- **Plan before apply, always.** Show the plan, list add/change/destroy counts, and wait for
  explicit approval (a clear "yes/apply", not just "ok"/"proceed") before `terraform apply`.
  If the plan destroys anything, list the specific resource addresses first.
- **Never** `terraform destroy` without an explicit, scoped request and a shown plan.
- Run `terraform validate` + `terraform fmt` before commit. `terraform fmt <dir>` reformats
  every file in the directory — fmt only the files you actually edited.
- For plan reviews, prefer the `terraform-reviewer` subagent.
- Keep state out of git; never read or print `*.tfstate`.

## Stateful resources

These must have `lifecycle { prevent_destroy = true }`:
- `google_container_cluster`, `google_container_node_pool`
- `google_sql_database_instance`
- `aws_db_instance`, `aws_db_cluster`, `aws_rds_cluster`
- `mongodbatlas_cluster`, `mongodbatlas_project`
- `google_storage_bucket` / `aws_s3_bucket` (when it holds state or backups)
- `google_kms_crypto_key`, `aws_kms_key`
- Persistent disks and volumes

Flag any change that removes `prevent_destroy` or forces replacement of one of these.

## Forbidden patterns

- `0.0.0.0/0` on firewall / security-group ingress, **except** an explicit internet-facing
  load balancer with a comment justifying it.
- `roles/owner`, `roles/editor`, or `*FullAccess` AWS managed policies.
- Hardcoded secrets — use `random_password`, `google_secret_manager_secret_version`, or
  `aws_secretsmanager_secret_version`. Never inline.
- Module sources tracking `master` / `main` — always pin `?ref=v1.2.3` or `?ref=<sha>`.
- Committed `terraform.tfstate` files.

## Tags / labels

Tag every taggable resource consistently: owner/team, environment, and cost-center where the
provider supports it. If they aren't in `locals.tags`, add them — check, don't assume.

## Naming

- Resource names: lowercase, hyphenated. No camelCase.
- Keep workspace, repo, and resource names consistent with the convention already used in the
  repo you're editing.

## Policy checks

If the repo gates IaC with a policy engine (OPA/Sentinel/Checkov), run it after adding a new
resource type. Never bypass a finding — fix it or escalate.
