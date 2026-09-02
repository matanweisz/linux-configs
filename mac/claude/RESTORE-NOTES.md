# Claude Code restore notes

What lands where on a fresh machine, and what has to be re-entered by hand.
`restore_configs()` in `mac/bootstrap.sh` (option 3, also part of Run ALL) populates
both profiles — see **Bootstrap wiring** below.

## Profile map

Two live profiles on this machine:

| Live path | Flavor | Repo source |
|---|---|---|
| `~/.claude` | default profile | `mac/claude/` + `settings.json` |
| `~/.claude-personal` | richer plugin set | `mac/claude/` + `settings.claude-personal.json` |

Claude Code reads whatever `CLAUDE_CONFIG_DIR` points at, defaulting to `~/.claude`.
The second profile is selected by the alias in `mac/zsh/.zsh_aliases`:

```sh
alias claude-personal="CLAUDE_CONFIG_DIR=~/.claude-personal claude"
```

So plain `claude` runs the default profile, `claude-personal` runs the other one.
Everything except `settings.json` is identical between the two — bootstrap copies
the same sources into both dirs, and only the settings file differs per profile.

The Ubuntu-side `claude/` dir mirrors the same content, adapted for Linux — minus
`skills/`, which it pulls from here (see **Skills** below). It carries the same three
settings files and `install/claude.sh` populates both profiles the same way.

## File map

Everything in the first block is copied into **both** `~/.claude/` and
`~/.claude-personal/`.

| Repo | Restores to | Notes |
|---|---|---|
| `mac/claude/CLAUDE.md` | `<profile>/CLAUDE.md` | macOS-flavored |
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
| `mac/claude/settings.json` | `~/.claude/settings.json` | default profile |
| `mac/claude/settings.claude-personal.json` | `~/.claude-personal/settings.json` | second profile |
| `mac/claude/settings.personal.json` | `~/.claude/settings.personal.json` | alternate settings kept alongside the default profile |

## Skills

`mac/claude/skills/` (~484K, 16 skill dirs + `llms.txt`) is the union of both live
profiles: `app-review`, `apple-design`, `graphify` (present in both) plus the
animation/design set (`animation-vocabulary`, `find-animation-opportunities`, the
`gsap-*` family, `improve-animations`, `review-animations`,
`mobile-app-ui-design`). `llms.txt` is the GSAP skill index, a loose file — copy
it alongside the dirs.

Skills are OS-agnostic and this is the **single source for both OSes**. Ubuntu's
`install/claude.sh` already copies this directory into both profiles' `skills/` — no manual
step needed. They are deliberately NOT duplicated under the top-level `claude/`; if you
add or update a skill, do it here.

Nothing secret-looking was found in the copied skill files (scanned for token /
key / password / bearer patterns).

## Scrubbed — needs manual re-entry

| File | Key | Value in repo |
|---|---|---|
| `mac/claude/settings.json` | `mcpServers` | `{}` — emptied |
| `mac/claude/settings.personal.json` | `mcpServers` | `{}` — emptied |
| `mac/claude/settings.claude-personal.json` | `mcpServers` | `{}` — emptied |

`mcpServers` is machine-specific and is deliberately not committed. Re-add any MCP
servers you want by hand after restore (`claude mcp add`, or edit the settings
file), and keep their tokens in 1Password / Vault — never in this repo.

No auth tokens or API base URLs are stored in any tracked settings file. All three
profiles authenticate interactively on first run.

## No `permissions` block — deliberate

None of the settings files carries a `permissions` allow/deny/ask block any more.
It was removed on request: `deny` entries still apply under
`--dangerously-skip-permissions`, so the block kept interrupting the very workflow
it was supposed to stand aside for. The `hooks` are kept and are the remaining
guard rail.

Do not reintroduce a `permissions` key when refreshing these files from a live
machine — its absence is the desired state, not drift.

## Plugins — restored automatically

Plugin *code* is not tracked (it lives under `~/.claude*/plugins/`), so copying the
settings files alone leaves every plugin **declared but not installed**. That is how
`ponytail`, `humanizer` and the skills they provide went missing on a fresh machine
even though the settings looked correct.

`install/claude.sh:restore_plugins()` closes that gap: for each profile it reads
`extraKnownMarketplaces` and `enabledPlugins` from that profile's own settings file
and drives `claude plugin marketplace add` / `claude plugin install`. It is
idempotent and needs network plus a logged-in `claude`.

Adding a plugin therefore means enabling it in the settings file — nothing else.
`mac/claude/plugins.md` is a human-readable mirror of those lists.

Verify a restore:

```bash
CLAUDE_CONFIG_DIR=~/.claude-personal claude plugin list | grep -c '@'   # expect 25
```

## Profile parity check

`~/.claude-personal/rules/` and `~/.claude-personal/output-styles/` are byte-identical
to the default profile's (`git-workflow.md`, `kubernetes.md`, `terraform.md`,
`devops-terse.md`), so there is nothing second-profile-only to preserve.
`output-styles/human.md` exists only in `~/.claude` and is generic — it is tracked
on both the mac and Ubuntu sides.

Note: `~/.claude-personal/settings.json` points `statusLine.command` at
`~/.claude/statusline.sh`, so the default profile's statusline script must exist
even when running the second profile.

## Bootstrap wiring

`restore_configs()` in `mac/bootstrap.sh` loops over both profile dirs
(`~/.claude` and `~/.claude-personal`), and inside each over
`agents commands hooks output-styles rules skills`, plus `CLAUDE.md` and
`statusline.sh`. The three settings files are copied afterwards, one per target.
Nothing here needs a manual `cp` any more.

`settings.personal.json` is restored to `~/.claude/settings.personal.json` but is
**not** auto-read by Claude Code — it is a manual-swap alternate settings file
(copy it over `settings.json` when you want that profile).

`plugins.md` and this file are documentation — do not copy them into either profile.
