---
description: Run terraform plan and review for safety, IAM widening, untagged resources, missing prevent_destroy, and OPA hits
argument-hint: "[plan-file-or-directory]"
allowed-tools: Read, Grep, Glob, Bash(terraform plan:*), Bash(terraform show:*), Bash(terraform validate:*), Bash(terraform fmt -check:*), Bash(terraform workspace show:*), Bash(git diff:*), Bash(git status:*), Bash(jq:*), Bash(ls:*), Bash(pwd)
---

Review a Terraform plan via the `terraform-reviewer` subagent.

## Steps

1. **Locate target**:
   - If `$ARGUMENTS` is a file ending in `.tfplan` → read it via `terraform show -json <file>`.
   - If `$ARGUMENTS` is a directory → `cd` into it.
   - If `$ARGUMENTS` is empty → use `pwd`.
   - If neither has `*.tf` files, abort with "no Terraform in this location".

2. **Sanity check** before running plan:
   - Refuse if `terraform.tfstate` is present in the working tree (state files belong in remote backend).
   - Run `git status -s` and warn if there are uncommitted state files.
   - Run `terraform workspace show` and surface the workspace name (especially flag if it's `prd`).

3. **Generate the plan** (only if not given a pre-computed `.tfplan`):
   ```
   terraform validate
   terraform plan -no-color -out=/tmp/cc-tfplan-$$
   terraform show -json /tmp/cc-tfplan-$$ > /tmp/cc-tfplan-$$.json
   ```

4. **Hand off to subagent**:
   Spawn the `terraform-reviewer` subagent with the JSON plan and instructions to produce a checklist (blocking / required / advisory).

5. **Cleanup**:
   ```
   rm -f /tmp/cc-tfplan-$$ /tmp/cc-tfplan-$$.json
   ```

## Output

The subagent's checklist, plus a one-line top-level recommendation:
- ✅ Safe to apply
- ⚠️ Apply with care — see required items
- 🚫 Do NOT apply — see blocking items

Never run `terraform apply`. Only review.
