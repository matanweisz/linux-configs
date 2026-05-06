---
description: Generate Israel-TZ standup (Yesterday / Today / Blockers) from Jira IEDO + Slack threads + git activity
model: sonnet
allowed-tools: Bash(git log:*), Bash(date:*), mcp__plugin_atlassian_atlassian__searchJiraIssuesUsingJql, mcp__plugin_atlassian_atlassian__getJiraIssue, mcp__plugin_atlassian_atlassian__atlassianUserInfo, mcp__plugin_slack_slack__slack_search_public_and_private, mcp__plugin_slack_slack__slack_read_user_profile
---

Generate a concise standup update for Matan in Israel timezone.

## Inputs to gather (in parallel)

### Jira IEDO
- `assignee = currentUser() AND updated >= -1d ORDER BY updated DESC` — what moved yesterday
- `assignee = currentUser() AND statusCategory = "In Progress" ORDER BY priority DESC` — today
- `assignee = currentUser() AND status = "Blocked" OR labels = blocker` — blockers
- For each ticket, capture: key, summary, status, last comment author+timestamp

### Slack (last 24h, weekdays — last 72h on Monday)
- `from:<@U0ACK0LS5SL> after:<yesterday>` — what Matan posted
- `to:<@U0ACK0LS5SL> after:<yesterday>` — mentions / DMs (potential blockers)
- `from:<@U0ACK0LS5SL> in:#ie-cloudinfra` — customer-facing replies (always worth highlighting)

### Git (only if cwd is a repo)
- `git log --author=matan --since='1 day ago' --pretty=format:'%h %s'` — local commits

## Output format (paste-ready)

```markdown
## Standup — <today YYYY-MM-DD, Asia/Jerusalem>

### Yesterday
- IEDO-XXXXX (status): <summary> — <one-liner about what was done>
- Reviewed PR #N on `<repo>`
- Posted in #ie-cloudinfra: <one-liner>

### Today
- IEDO-XXXXX (in progress): <summary> — <next concrete step>
- Apigee AI Gateway proxies: <next milestone> (with @Dekel)
- GKE 1.35 fleet upgrade tracker: <next batch / next blocker>

### Blockers
- <none | ticket + waiting on whom>
```

## Tone

- One bullet per item, concrete and action-oriented.
- No filler ("worked on stuff").
- If nothing to report in a section, write `- (none)`.
- Use ticket keys (IEDO-XXXXX), not URLs.
- Respect Asia/Jerusalem timezone for "yesterday" boundaries (subtract 24h from `now()` in IL TZ).

## On Mondays

Treat "yesterday" as Friday + weekend Slack/git activity.
