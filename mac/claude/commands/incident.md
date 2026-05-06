---
description: Initial incident triage — pulls Datadog signals, recent deploys, existing IEDO tickets, drafts Slack thread + Jira body for human review. Never posts.
argument-hint: "<one-line-summary>"
model: opus
allowed-tools: Read, Bash, Grep, Glob, mcp__codex__*, mcp__plugin_atlassian_atlassian__search, mcp__plugin_atlassian_atlassian__searchJiraIssuesUsingJql, mcp__plugin_atlassian_atlassian__getJiraIssue, mcp__plugin_atlassian_atlassian__searchConfluenceUsingCql, mcp__plugin_slack_slack__slack_search_public_and_private, mcp__plugin_slack_slack__slack_search_channels, mcp__plugin_slack_slack__slack_read_channel, mcp__plugin_slack_slack__slack_read_thread, mcp__ie-automation__cloudinfra_search_entity_by_name, mcp__ie-automation__cloudinfra_get_entity_by_id_and_type
---

Run initial incident triage via the `incident-responder` subagent.

## Steps

1. Pass `$ARGUMENTS` as the incident summary to the `incident-responder` subagent.
2. Surface the subagent's structured output:
   - Timeline
   - Blast radius
   - Top hypothesis
   - Suggested mitigation (numbered, in order of likelihood)
   - **Slack draft** (clearly marked: "DRAFT — review before posting")
   - **Jira draft** (clearly marked: "DRAFT — review before creating")
3. Ask the user explicitly: "Want me to post the Slack draft / create the Jira ticket? (I'll need your OK to mutate.)"

## Hard rules

- Never auto-post Slack or auto-create Jira. The subagent is constrained to drafts only.
- If user says "post it", spawn a one-shot mutation in this main thread (which is paranoid-permission gated and will prompt) — not via the subagent.
- Default the Slack channel suggestion to `#ie-cloudinfra-il-public` (team channel) unless the incident is customer-facing, in which case suggest `#ie-cloudinfra`.
- Times in **UTC** in drafts.
