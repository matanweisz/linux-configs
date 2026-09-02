# Claude Code plugin manifest

Plugin *code* is not tracked in this repo (it lives under `~/.claude*/plugins/`,
managed by Claude Code) — only the manifest is.

**This is now restored automatically.** `install/claude.sh:restore_plugins()` reads
`extraKnownMarketplaces` and `enabledPlugins` straight out of each profile's settings
file and drives `claude plugin marketplace add` / `claude plugin install`. The settings
files are the single source of truth; this page is a human-readable mirror of them.
Restoring settings alone is NOT enough — it leaves every plugin declared but not
installed, which is exactly how ponytail/humanizer and the skills they provide went
missing on a fresh machine.

`enabledPlugins` keys use the form `<plugin>@<marketplace>`.

## Marketplaces

| Marketplace | Source |
|---|---|
| `claude-plugins-official` | github `anthropics/claude-plugins-official` |
| `ponytail` | github `DietrichGebert/ponytail` |
| `kubernetes-skill` | github `LukasNiessen/kubernetes-skill` |
| `ui-ux-pro-max-skill` | github `nextlevelbuilder/ui-ux-pro-max-skill` |
| `humanizer` | github `blader/humanizer` |

All five have their `source` block captured in
`mac/claude/settings.claude-personal.json` → `extraKnownMarketplaces`, which is what
`restore_plugins()` iterates. Only `source: github` entries are automated; anything
else is reported as needing a manual `/plugin marketplace add <owner>/<repo>`.

## Plugin list (25)

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

From third-party marketplaces:

- `ponytail@ponytail`
- `kubernetes-skill@kubernetes-skill`
- `ui-ux-pro-max@ui-ux-pro-max-skill`
- `humanizer@humanizer`

Tracked in `mac/claude/settings.claude-personal.json` → `enabledPlugins`. This is
the full, current set — treat it as the source of truth.

## Note

The other two settings files enable smaller subsets:
`mac/claude/settings.json` (7 plugins) and `mac/claude/settings.personal.json`
(17, the `claude-plugins-official` subset only). If they disagree with the list
above after a restore, the list above wins.
