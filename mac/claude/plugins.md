# Claude Code plugin manifest

Restore reference only — not executable. Plugin *code* is not tracked in this repo
(it lives under `~/.claude*/plugins/`, managed by Claude Code). On a new machine,
add the marketplaces below, then enable the plugins per profile. `enabledPlugins`
keys in `settings.json` use the form `<plugin>@<marketplace>`.

## Marketplaces

`extraKnownMarketplaces` keys seen across both profiles:

| Marketplace | Source | Used by |
|---|---|---|
| `claude-plugins-official` | github `anthropics/claude-plugins-official` | work + personal |
| `ponytail` | third-party | personal |
| `kubernetes-skill` | third-party | personal |
| `ui-ux-pro-max-skill` | third-party | personal |
| `humanizer` | third-party | personal |

Only `claude-plugins-official` has its `source` block captured (in
`mac/claude/settings.json`). The four personal marketplaces are third-party;
re-add them with `/plugin marketplace add <repo-or-url>` — the exact sources are
not recorded here on purpose.

## Work profile — `~/.claude` (7)

From `claude-plugins-official`:

- `context7`
- `security-guidance`
- `claude-md-management`
- `slack`
- `atlassian`
- `frontend-design`
- `vercel`

Tracked in `mac/claude/settings.json` → `enabledPlugins`.

## Personal profile — `~/.claude-personal` (25)

From `claude-plugins-official`:

- `context7`
- `security-guidance`
- `claude-md-management`
- `slack`
- `atlassian`
- `frontend-design`
- `code-review`
- `feature-dev`
- `commit-commands`
- `desktop-commander`
- `pr-review-toolkit`
- `pyright-lsp`
- `remember`
- `superpowers`
- `playwright`
- `chrome-devtools-mcp`
- `skill-creator`
- `github`
- `supabase`
- `vercel`
- `expo`
- `humanizer`

From third-party marketplaces:

- `ponytail@ponytail`
- `kubernetes-skill@kubernetes-skill`
- `ui-ux-pro-max@ui-ux-pro-max-skill`

Tracked in `mac/claude/settings.personal.json` → `enabledPlugins`.

## Note

`~/.claude/settings.personal.json` (the file this repo copies as
`mac/claude/settings.personal.json`) lists a *smaller* set — 17 plugins, the
`claude-plugins-official` subset only. The live `~/.claude-personal/settings.json`
is the richer, current list above. If the two disagree after restore, the list
above wins.
