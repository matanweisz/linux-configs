---
description: Generate a short daily standup from recent git activity and open PRs.
allowed-tools: Bash(git log:*), Bash(git branch:*), Bash(git status:*), Bash(gh pr list:*), Bash(gh pr status:*), Bash(gh issue list:*)
---

Build a concise standup (no preamble):

1. **Yesterday/recent:** my commits in the last ~24h across local repos
   (`git log --author="$(git config user.email)" --since="36 hours ago" --oneline`),
   plus merged PRs (`gh pr list --author @me --state merged --limit 10`).
2. **In progress:** current branch + dirty state, and open PRs (`gh pr status`).
3. **Today/next:** infer from open PRs/branches and any TODO/FIXME in the working tree.
4. **Blockers:** anything failing (PR checks, dirty rebases).

Output three short bullet groups: **Done / Doing / Next** (+ Blockers if any). Times in UTC.
