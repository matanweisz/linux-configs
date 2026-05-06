---
paths:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/*.hcl"
---

# Terraform rules

These apply when working with Terraform / OpenTofu in any directory.

## Workflow

- **Always** call `terraform_list_modules` (via the IE-Automation MCP) before adding a module — that's the source of truth for available internal modules.
- **Always** call `terraform_module_generation <name>` before generating HCL that uses an internal module — required variables and OPA constraints come from there.
- **Always** call `terraform_local_validate_and_plan_instructions <dir>` after generating or upgrading Terraform.
- For module upgrades, call `terraform_module_upgrade_instructions` — follow its steps.
- For plan reviews, prefer the `terraform-reviewer` subagent. For env0 environment creation, prefer `env0-tf-helper`.

## Mandatory tags on every taggable resource

`Team`, `CostCenter`, `Environment`. If you can't find them in `locals.tags`, add them. Don't assume; check.

## Stateful resources

These must have `lifecycle { prevent_destroy = true }`:
- `google_container_cluster`, `google_container_node_pool`
- `mongodbatlas_cluster`, `mongodbatlas_project`
- `aws_db_instance`, `aws_db_cluster`, `aws_rds_cluster`
- `google_sql_database_instance`
- `google_storage_bucket` (when it holds state or backups)
- `aws_s3_bucket` (when it holds state or backups)
- `google_kms_crypto_key`, `aws_kms_key`

## Naming (Google Foundations)

- Workspace: `gf-<tier>-<func-app>-<cs|ns>-gcp` where `<tier>` ∈ {`dev`, `stg`, `prd`} and profile is `cs` (cloud-services) or `ns` (namespace).
- Repo: `tfc-gf-<func-app>-<cs|ns>-gcp` for IaC (under `Terraform/` org).
- Resource names: lowercase, hyphenated. No camelCase, no underscores in resource names.

## Forbidden patterns

- `0.0.0.0/0` on firewall/security-group ingress, **except** explicit "internet-facing LB" with a comment justifying it.
- `roles/owner`, `roles/editor`, `*FullAccess` AWS managed policies.
- Hardcoded secrets — use `random_password`, `google_secret_manager_secret_version`, or `aws_secretsmanager_secret_version`. Never inline.
- Module sources tracking `master` / `main` — always pin `?ref=v1.2.3`.
- Inline `terraform.tfstate` files in the repo.

## Module pinning

Internal modules from `git.zoominfo.com/Terraform/*` must use `?ref=v<semver>` or `?ref=<sha>`. Not `master`.

## OPA

OPA policies live in `Terraform/opa-iac-policies`. If you add a new resource type that may trip a policy, run `terraform_opa_compliance` to confirm.

## What to do before suggesting `terraform apply`

1. Show the plan output explicitly.
2. List resources being **created** / **changed** / **destroyed** (counts, then specific addresses for destroys).
3. Wait for explicit human approval. Don't proceed on "proceed" alone if the plan shows destructions; require "yes apply".
