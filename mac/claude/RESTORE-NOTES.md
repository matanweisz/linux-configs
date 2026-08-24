# Claude Code restore notes

What lands where on a fresh machine, and what has to be re-entered by hand.
`restore_configs()` in `mac/bootstrap.sh` (option 3, also part of Run ALL) populates
both profiles — see **Bootstrap wiring** below.

## Profile map

Two live profiles on this machine:

| Live path | Flavor | Repo source |
|---|---|---|
| `~/.claude` | work (ZoomInfo), the default profile | `mac/claude/` + `settings.json` |
| `~/.claude-personal` | personal, richer plugin set | `mac/claude/` + `settings.claude-personal.json` |

Claude Code reads whatever `CLAUDE_CONFIG_DIR` points at, defaulting to `~/.claude`.
The personal profile is selected by the alias in `mac/zsh/.zsh_aliases`:

```sh
alias claude-personal="CLAUDE_CONFIG_DIR=~/.claude-personal claude"
```

So plain `claude` runs the work profile, `claude-personal` runs the personal one.
Everything except `settings.json` is identical between the two — bootstrap copies
the same sources into both dirs, and only the settings file differs per profile.

The Ubuntu-side `claude/` dir is a deliberately sanitized mirror — generic only,
no employer-internal hosts, tickets, or vocabulary.

## File map

Everything in the first block is copied into **both** `~/.claude/` and
`~/.claude-personal/`.

| Repo | Restores to | Notes |
|---|---|---|
| `mac/claude/CLAUDE.md` | `<profile>/CLAUDE.md` | work-flavored |
| `mac/claude/statusline.sh` | `<profile>/statusline.sh` | `chmod +x` |
| `mac/claude/agents/` | `<profile>/agents/` | |
| `mac/claude/commands/` | `<profile>/commands/` | |
| `mac/claude/hooks/` | `<profile>/hooks/` | `chmod +x` all |
| `mac/claude/rules/` | `<profile>/rules/` | referenced from CLAUDE.md |
| `mac/claude/output-styles/` | `<profile>/output-styles/` | |
| `mac/claude/skills/` | `<profile>/skills/` | OS-agnostic, see below |

Per-profile settings:

| Repo | Restores to | Notes |
|---|---|---|
| `mac/claude/settings.json` | `~/.claude/settings.json` | work profile, see scrub list |
| `mac/claude/settings.claude-personal.json` | `~/.claude-personal/settings.json` | personal profile, see scrub list |
| `mac/claude/settings.personal.json` | `~/.claude/settings.personal.json` | alternate settings kept alongside the work profile |

## Skills

`mac/claude/skills/` (~484K, 16 skill dirs + `llms.txt`) is the union of both live
profiles: `app-review`, `apple-design`, `graphify` (present in both) plus the
personal-only animation/design set (`animation-vocabulary`,
`find-animation-opportunities`, the `gsap-*` family, `improve-animations`,
`review-animations`, `mobile-app-ui-design`). `llms.txt` is the GSAP skill index,
a loose file — copy it alongside the dirs.

Skills are OS-agnostic. **Ubuntu setup should copy this same directory** to
`~/.claude/skills/` — they are deliberately NOT duplicated under `claude/`.
Reference `mac/claude/skills/` from the Ubuntu restore step.

Nothing secret-looking was found in the copied skill files (scanned for token /
key / password / bearer patterns).

## Scrubbed — needs manual re-entry

| File | Key | Value in repo |
|---|---|---|
| `mac/claude/settings.json` | `env.ANTHROPIC_AUTH_TOKEN` | `REPLACE_ME_BEFORE_USE` |
| `mac/claude/settings.json` | `env.ANTHROPIC_BASE_URL` | `REPLACE_ME_BASE_URL` |
| `mac/claude/settings.json` | `mcpServers` | `{}` — emptied |
| `mac/claude/settings.personal.json` | `mcpServers` | `{}` — emptied |
| `mac/claude/settings.claude-personal.json` | `mcpServers` | `{}` — emptied |

`ANTHROPIC_BASE_URL` in the live work profile points at the internal requesty
router (an internal-only host), so it is scrubbed here — re-enter it manually
alongside `mcpServers`, from the internal docs.

`mcpServers` in all three live files points at internal work hosts and is
deliberately not committed — it is machine- and work-specific. Two entries to
re-add by hand after restore: `DataDog-MCP` and `ie-automation-mcp`, both
`streamable-http`. Get the URLs from the internal docs, not from this repo.

`mac/claude/settings.claude-personal.json` is a copy of live
`~/.claude-personal/settings.json` with `mcpServers` emptied. It carries no auth
token (that profile logs in via console), so `mcpServers` was the only scrub.

`settings.personal.json` carries no auth token at all (it logs in via console),
so nothing else was replaced there.

**Not committed:** `~/.claude/settings.requesty.json`. It duplicates the `env`
block already in `settings.json` and contributes nothing but a live token — no
restore value, so it is skipped on purpose.

## Desired-state drift (intentional)

`mac/claude/settings.json` keeps a `permissions` allow/deny/ask block that live
`~/.claude/settings.json` does not have. That is deliberate — it is the desired
state for a new machine, not a mirror of the current one. Everything else
(`model`, `hooks`, `statusLine`, `enabledPlugins`, `extraKnownMarketplaces`,
`forceLoginMethod`, `outputStyle`, `alwaysThinkingEnabled`,
`skipDangerousModePermissionPrompt`) is synced to live.

## Plugins

Plugin code is not tracked. See `mac/claude/plugins.md` for the per-profile
`enabledPlugins` lists and the marketplaces to re-add first.

## Profile parity check

`~/.claude-personal/rules/` and `~/.claude-personal/output-styles/` are byte-identical
to the work profile's (`git-workflow.md`, `kubernetes.md`, `terraform.md`,
`devops-terse.md`), so there is nothing personal-profile-only to preserve.
`output-styles/human.md` exists only in `~/.claude` and is generic — it is tracked
on both the mac and Ubuntu sides.

Note: `~/.claude-personal/settings.json` points `statusLine.command` at
`~/.claude/statusline.sh` (the work path), so the work profile's statusline script
must exist even when running the personal profile.

## Bootstrap wiring

`restore_configs()` in `mac/bootstrap.sh` loops over both profile dirs
(`~/.claude` and `~/.claude-personal`), and inside each over
`agents commands hooks output-styles rules skills`, plus `CLAUDE.md` and
`statusline.sh`. The three settings files are copied afterwards, one per target.
Nothing here needs a manual `cp` any more.

After the copy, bootstrap warns if any `REPLACE_ME` placeholder is still present
in either profile's `settings.json`.

`plugins.md` and this file are documentation — do not copy them into either profile.
