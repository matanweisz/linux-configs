---
description: Walk through creating a new env0 environment for a functional application (validate-then-create, GF naming auto-derived)
argument-hint: "<functional-app> <tier=dev|stg|prd> [profile=cs|ns]"
allowed-tools: Read, Bash, mcp__ie-automation__cloudinfra_*, mcp__ie-automation__list_workspace_templates, mcp__ie-automation__tasker_validate_env0_environment, mcp__ie-automation__tasker_create_env0_environment, mcp__ie-automation__tasker_check_workflow_status, mcp__ie-automation__workspace_search_by_name, mcp__ie-automation__terraform_list_modules
---

Create a new env0 environment via the `env0-tf-helper` subagent. **Always** validate first, **always** wait for human approval before applying.

## Parsing arguments

- `$1` = functional application name (required, e.g. `customer-facing-analytics`)
- `$2` = tier (required: `dev`, `stg`, or `prd`)
- `$3` = profile (optional, default `ns` for namespace; use `cs` for cloud-services)

If `$1` or `$2` missing, ask.

## Derived values (per GF convention)

- Workspace name: `gf-<tier>-<func-app>-<profile>-gcp`
- Repo name: `tfc-gf-<func-app>-<profile>-gcp`

## Steps

1. **Discover** via `env0-tf-helper`:
   - Confirm functional application exists in Hyperion
   - Look up the GCP application platform (pet name)
   - List existing workspaces to detect duplicates
   - Pick the right env0 template

2. **Validate** with `tasker_validate_env0_environment` — show the result.

3. **Pause** and ask: "Validation looks good. Create the environment? (yes/no)"

4. **Create** only on explicit `yes` — call `tasker_create_env0_environment`.

5. **Follow up** with `tasker_check_workflow_status` if the user wants progress checks.

## Output

A markdown summary at each step (Discovery / Plan / Validation / Awaiting approval / Creation / Status), so the user has a record they can paste into a PR description or Confluence.

## Hard rules

- Never skip validation.
- Never auto-approve creation. The subagent is also enforcing this; the command is a defense-in-depth.
- If the user gave wrong tier capitalization (e.g. "PRD"), normalize to lowercase but mention it.
