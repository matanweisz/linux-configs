---
description: Generate a Terraform plan in the target dir and review it with the terraform-reviewer subagent.
argument-hint: "[dir] (defaults to .)"
allowed-tools: Bash(terraform plan:*), Bash(terraform show:*), Bash(terraform validate:*), Read, Grep, Glob, Task
---

Target directory: `${1:-.}`

1. `cd` into the target dir and run `terraform validate`, then
   `terraform plan -no-color -out=tfplan` (read-only; do not apply).
2. Produce a JSON plan: `terraform show -json tfplan`.
3. Invoke the **terraform-reviewer** subagent on the plan and summarize its checklist.
4. Do **not** apply. End by stating the add/change/destroy counts and asking for explicit
   approval if the user wants to proceed.
