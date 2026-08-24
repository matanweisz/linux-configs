# Git workflow rules

These apply when working in any git repository, regardless of language or platform.

## Default workflow for any change

1. Start from a clean state: `git switch master` (or `main`), `git pull --ff-only`. Confirm `git status` is clean before branching.
2. Branch name = ticket key (e.g. `IEDO-92809`). For multi-PR work on the same ticket, suffix the scope (e.g. `IEDO-92809-prd`).
3. Make the change. Show the user `git diff` before committing for any non-trivial edit.
4. Commit with `git commit -m "<TICKET>: <imperative summary>"`. Use `git commit -am` only when every modified file is intended.
5. Push with `git push -u origin <branch>`. Never force-push without explicit user approval.
6. Open the PR via `gh pr create` if `gh` is authenticated for the host, otherwise hand the user the new-PR URL from the push response and a clean title + body to paste.

## Safety

- **Never** push directly to `master` / `main`. Open a PR.
- **Never** force-push (`-f`, `--force`, `--force-with-lease`) without explicit user OK in the same turn — even on personal feature branches, ask first.
- **Never** use `git reset --hard`, `git checkout .`, `git clean -fd`, or `git branch -D` to "clean up" without confirming first. Investigate unfamiliar files / branches before destroying them.
- **Never** use `--no-verify` or `--no-gpg-sign`. If a hook fails, fix the underlying issue.
- **Never** amend a commit you've already pushed. Always create a new commit.
- Prefer `git switch` over `git checkout` for branch ops; prefer `git restore` over `git checkout --` for file ops.

## Pre-commit hooks

- Some repos run formatters (`tf_fmt`, `prettier`, etc.) automatically. Let them. Don't try to revert hook-applied formatting fixes — the CI will fail without them. If the hook touches files outside your intended diff, mention it to the user but commit anyway.

## Internal git host (`git.zoominfo.com`)

- The `gh` CLI works against the internal host via `GH_HOST=git.zoominfo.com gh <subcommand>` (env var, not `--hostname` flag).
- If `gh auth status -h git.zoominfo.com` shows the token is invalid, do NOT loop on it — surface the issue to the user and either ask them to run `gh auth login -h git.zoominfo.com` or fall back to giving them the new-PR URL from the push response.

## `git.zoominfo.com` write-access model

- **HTTPS push requires per-org write permission**, even with a `repo`-scope PAT. Read works fleet-wide via cached osxkeychain creds, but `git push` returns `remote: Write access to repository not granted. fatal: ... 403` if the user isn't a collaborator on that repo's org. When a 403 hits, ask the user to request write access to the specific org (e.g. `dozi`, `data-innovation`, `zoominformation`); don't assume the PAT itself is the problem.
- **Replace a stale cached cred without exposing the token**: `printf "protocol=https\nhost=git.zoominfo.com\nusername=<user>\npassword=<NEW_PAT>\n" | git credential approve`. To force a re-prompt instead: `git credential reject` then any `git fetch`/`ls-remote` will prompt fresh.
- **`gh` CLI auth on `git.zoominfo.com` is independent of git credentials.** A 403 on `gh pr create` does NOT mean git push will fail (and vice versa). Always test both paths separately.
- **PR creation without working `gh` CLI**: push the branch via plain `git push`, then hand the user the GHE compare URL `https://git.zoominfo.com/<org>/<repo>/compare/<base>...<branch>?expand=1` — clicking it opens a new-PR page with title/body prefilled from the commit.

## Shallow clone tracking-ref gotcha

- `git clone --depth=N <url>` sets a single-branch refspec. A later `git fetch origin <branch>` will NOT populate `refs/remotes/origin/<branch>` without an explicit refspec — silently breaks `git reset --hard origin/<branch>`, `--force-with-lease`, and `branch -f origin/<branch>`.
- **Fix**: `git fetch origin "+refs/heads/<BRANCH>:refs/remotes/origin/<BRANCH>"` to force-store the tracking ref. The leading `+` allows non-fast-forward updates.
- **`--force-with-lease` requires a tracking ref to compare against.** If you're overwriting a branch you just pushed (no fetch in between), the lease check fails with `[rejected] (stale info)`. Either fetch the tracking ref first, or use plain `--force`, or — safest for a branch you just created — `git push origin --delete <branch>` then push fresh.

## `git -C <dir>` path resolution gotcha

`git -C <dir> apply <patch>` (and other `-C` invocations that take a file path) resolves the file path relative to the CWD, NOT relative to `<dir>`. From a script that may run from any directory, always pass absolute paths:
```bash
patch="$(realpath research/patches/foo.patch)"
git -C "$repo_dir" apply "$patch"
```

## `git apply --check` passes on whitespace-only diffs

`git apply --check <patch>` returns 0 success even when the patch would only add/remove trailing newlines. Any pipeline that uses `--check` as a "should I push" gate must follow up with a semantic-diff check:
```bash
git diff <base> <branch> --ignore-all-space --ignore-blank-lines --stat
```
Empty output → whitespace only → delete branch (`git push origin --delete <branch>`), don't open a PR.

## PR description template

For ticket-driven PRs, the body should include at minimum:
- One-paragraph summary of what's changing and why
- Link to the Jira/issue ticket
- For infra PRs: pointer to the env0/CI plan run that will be produced (or the local plan output if you ran one)
- Reference to any sibling PRs (e.g. `Follow-up to #48`) when work is split across multiple PRs

Keep titles under 70 chars. Lead with the ticket key: `IEDO-XXXXX: <imperative summary>`.

## After-merge follow-up

When a tracking ticket has multiple sub-PRs, comment the merged PR URL on the relevant sub-ticket (only after merge, only if the ticket has an assignee other than yourself — let them close it). Never auto-close tickets you don't own.
