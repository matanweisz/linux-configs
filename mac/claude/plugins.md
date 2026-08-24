# Claude Code plugin manifest

Restore reference only — not executable. Plugin *code* is not tracked in this repo
(it lives under `~/.claude*/plugins/`, managed by Claude Code). On a new machine,
add the marketplaces below, then enable the plugins. `enabledPlugins` keys in the
settings files use the form `<plugin>@<marketplace>`.

## Marketplaces

| Marketplace | Source |
|---|---|
| `claude-plugins-official` | github `anthropics/claude-plugins-official` |
| `ponytail` | github `DietrichGebert/ponytail` |
| `kubernetes-skill` | github `LukasNiessen/kubernetes-skill` |
| `ui-ux-pro-max-skill` | github `nextlevelbuilder/ui-ux-pro-max-skill` |
| `humanizer` | github `blader/humanizer` |

All five have their `source` block captured in
`mac/claude/settings.claude-personal.json` → `extraKnownMarketplaces`, so a restore
of that file re-registers them. To add one by hand:
`/plugin marketplace add <owner>/<repo>`.

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
- `humanizer`

From third-party marketplaces:

- `ponytail@ponytail`
- `kubernetes-skill@kubernetes-skill`
- `ui-ux-pro-max@ui-ux-pro-max-skill`

Tracked in `mac/claude/settings.claude-personal.json` → `enabledPlugins`. This is
the full, current set — treat it as the source of truth.

## Note

The other two settings files enable smaller subsets:
`mac/claude/settings.json` (7 plugins) and `mac/claude/settings.personal.json`
(17, the `claude-plugins-official` subset only). If they disagree with the list
above after a restore, the list above wins.
