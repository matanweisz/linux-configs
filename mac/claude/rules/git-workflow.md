# Git workflow rules

These apply when working in any git repository, regardless of language or platform.

## Default workflow for any change

1. Start from a clean state: `git switch main` (or `master`), `git pull --ff-only`. Confirm `git status` is clean before branching.
2. Branch name = issue key or a short kebab-case slug (e.g. `fix-nvim-treesitter`). For multi-PR work on the same issue, suffix the scope.
3. Make the change. Show the user `git diff` before committing for any non-trivial edit.
4. Commit with `git commit -m "<imperative summary>"` (prefix the issue key when there is one). Use `git commit -am` only when every modified file is intended.
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

- Some repos run formatters (`prettier`, `shfmt`, etc.) automatically. Let them. Don't try to revert hook-applied formatting fixes — the CI will fail without them. If the hook touches files outside your intended diff, mention it to the user but commit anyway.

## Push access and credentials

- A `repo`-scope token is not the same as write access. On hosts with per-org permissions, read works fleet-wide from cached credentials while `git push` still returns `remote: Write access to repository not granted. fatal: ... 403`. When a 403 hits, the fix is requesting write access to that repo/org — don't assume the token itself is broken.
- **Replace a stale cached credential without exposing the token**: `printf "protocol=https\nhost=<host>\nusername=<user>\npassword=<NEW_TOKEN>\n" | git credential approve`. To force a re-prompt instead: `git credential reject`, then any `git fetch` / `ls-remote` prompts fresh.
- **`gh` CLI auth is independent of git credentials.** A 403 on `gh pr create` does NOT mean `git push` will fail (and vice versa). Test both paths separately.
- If `gh auth status` shows an invalid token, do NOT loop on it — surface it to the user and fall back to the new-PR URL from the push response.

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

- One-paragraph summary of what's changing and why
- Link to the issue, if there is one
- For infra PRs: pointer to the CI plan run that will be produced (or the local plan output if you ran one)
- Reference to any sibling PRs (e.g. `Follow-up to #48`) when work is split across multiple PRs

Keep titles under 70 chars, imperative mood.

## After-merge follow-up

When a tracking issue has multiple sub-PRs, comment the merged PR URL on the relevant sub-issue (only after merge, only if it has an assignee other than yourself — let them close it). Never auto-close issues you don't own.
