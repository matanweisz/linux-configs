# Machine hand-back checklist

For returning a work-issued Mac. Work top to bottom; nothing here is reversible
after the wipe.

---

## 1. Rotate / revoke (do first — these are live credentials)

| What | Action |
|---|---|
| LLM / API router tokens | Any `*_AUTH_TOKEN` / `*_API_KEY` in `~/.claude/settings*.json`, `~/.config/`, or shell rc files. Rotate in the issuing console, then delete locally. Assume anything that ever appeared in a terminal transcript is compromised. |
| GitHub CLI tokens | `gh auth token` per host (`github.com` is logged in as `matanweisz`, keyring). Revoke each PAT at github.com → Settings → Developer settings → Tokens. Repeat for any employer-hosted git server. |
| SSH key `~/.ssh/id_ed25519` | Deauthorize the **public** key in GitHub → Settings → SSH and GPG keys. Same for any enterprise git host copy. Don't rely on the wipe. |
| SSH key `~/.ssh/google_compute_engine` (`.pub`) | Second keypair gcloud manages for OS Login / instance SSH. Deauthorize/delete alongside `id_ed25519` — don't assume it's covered by the GitHub key rotation. |
| AWS SSO | `aws sso logout` (all profiles), then confirm `~/.aws/sso/cache/` is empty. |
| AWS static keys | `~/.aws/credentials` may hold long-lived access keys (not just SSO cache). Check it and rotate/delete any static credentials found. |
| gcloud | `gcloud auth revoke --all` and `gcloud auth application-default revoke`. |
| Other CLI vendors | Check `~/.config/*/credentials.json` and `~/.netrc` for live API credentials — rotate or delete each. Specifically: `~/.config/higgsfield/credentials.json`, `~/.codex/auth.json`, `~/.gemini/oauth_creds.json`. |
| Secondary Claude Code settings file *(macOS only)* | `~/.claude-personal/settings.requesty.json` — a separate settings file carrying its own router token. Rotate it, don't assume the main settings rotation covers it. Ubuntu is single-profile and has no such file. |
| Docker registry logins | Every registry listed under `auths` in `~/.docker/config.json` — not just `docker.io`/`ghcr.io`. Run `docker logout <registry>` for each (any private/employer container registries included). |
| Atuin | Sync is off / local-only, but if a sync key was ever set, rotate it. |
| Project env files | Sweep for stray `.env*` files before wipe: `fd -H '^\.env' ~ -d 4 -E node_modules` (or `find ~ -maxdepth 4 -iname '.env*'`). Rotate any live keys found in them. |
| VPN / work SSO / MDM | IT's problem — don't try to clean these up yourself. |

---

## 2. Export before wipe

**Verify this repo is pushed** before anything else.

Then sweep for personal git state that exists **only on this machine** — unpushed
commits, dirty trees, and directories that were never `git init`-ed at all:

```bash
# unpushed / dirty repos anywhere under $HOME
fd -H -t d '^\.git$' ~ -x sh -c 'd=$(dirname {}); s=$(git -C "$d" status --porcelain); \
  u=$(git -C "$d" log --branches --not --remotes --oneline 2>/dev/null | wc -l); \
  [ -n "$s" ] || [ "$u" -gt 0 ] && echo "$d  dirty=$([ -n "$s" ] && echo yes || echo no) unpushed=$u"'
```

Look outside `~/git` too — project dirs stashed in `~/ai-sessions`, `~/Documents`,
or `~/Desktop` are the easiest to miss.

LaunchAgents in `~/Library/LaunchAgents/` auto-run at login and are **not**
tracked by this repo — `ls ~/Library/LaunchAgents/` and copy out any plists whose
schedule you want to rebuild. Check what binary each one invokes (e.g. a Rancher
or Docker Desktop path), since the next machine needs that installed first.

Two personal-project LaunchAgents point at repos that die with the wipe — remove
them rather than letting them fail silently at next login: `com.tradingbot.*.plist`
and `com.shorts-theory-tv.ui.plist` (`launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/<name>.plist` then delete the file).

Push any personal repos that only exist locally before the wipe — a `git status`/`log`
sweep like the one above won't necessarily surface repos with unpushed *branches* that
aren't on `HEAD`, or ones nested inside another repo's worktree. Known as of this
refresh:

- `~/ai-sessions/trading-bot` — 17 commits local-only.
- `~/ai-sessions/adhd-application` — 8 commits local-only.
- `~/git/maps-memory` — 1 commit ahead of remote.
- `~/git/shorts-theory-tv` — one feature-branch commit sitting in an agent worktree;
  also ~220 disposable agent branches in the same repo — push what's wanted, prune
  the rest (`git branch -D` / delete the worktrees), don't carry all of them forward.
- `~/git/matanweisz-company` — empty dir, never `git init`-ed. Either init + push or
  delete it; don't let it silently vanish in the wipe.

Record global tool lists before wipe, since neither is tracked by this repo:

```bash
npm ls -g --depth=0 > ~/npm-globals.txt   # last seen: @google/gemini-cli, @higgsfield/cli
uv tool list > ~/uv-tools.txt             # last seen: graphifyy
```

Also grab:

- `~/Screenshots/` — screenshot target set by `macos-defaults.sh`, not synced anywhere.
- `~/Documents`, `~/Desktop` — anything personal, **including screen recordings and
  screenshots saved directly to the Desktop** (not just the `~/Screenshots/` target).
- `~/Downloads` — review and save-or-delete deliberately; don't carry it off-machine
  wholesale. Delete anything employer-owned (exports, attachments, internal docs)
  rather than taking it with you.
- Browser bookmarks / profile, if the browser isn't signed in to a synced account.
- Atuin shell history — local SQLite, nothing syncs it: `atuin history list > ~/atuin-history.txt` if you want it.
- `~/.ssh/` — copy the keys out only if you intend to reuse them (safer: generate new ones next machine).

---

## 3. Deauthorize / sign out

- Apple ID: System Settings → sign out of iCloud **and** App Store if a personal Apple ID was used.
- `gh auth logout` for every host.
- `docker logout` and `docker logout ghcr.io`.
- Slack: sign out of the desktop app; revoke this device in Slack account settings.
- Browsers: sign out of profiles, clear saved passwords.
- Bitwarden: log out (not just lock).
- Rancher Desktop: quit and disable `io.rancherdesktop.autostart`.
- Personal Google account: also logged into `gcloud` on this machine alongside the
  work account. `gcloud auth revoke --all` (§1) covers both, but confirm with
  `gcloud auth list` that no stray personal credential survives.

---

## 4. Restore on the next machine

```bash
git clone git@github.com:matanweisz/linux-configs.git ~/git/linux-configs
cd ~/git/linux-configs/mac && ./bootstrap.sh   # option 12 = run everything
```

Going to Ubuntu instead? `cd ~/git/linux-configs && ./bootstrap.sh` — option 1 is the
full run. Same dotfiles, Linux-native tooling. See the repo `README.md`.

Then the manual pieces bootstrap can't do:

- **Claude Code** — `mac/claude/RESTORE-NOTES.md`. Config, `skills/`, marketplaces and
  plugins all restore automatically (macOS: both profiles; Ubuntu: the single `~/.claude`).
  Only `mcpServers` blocks need re-adding by hand — they are scrubbed on purpose.
- **Raycast** — `mac/raycast/README.md` (the plist restores; snippets/quicklinks need a `.rayconfig` export).
- **AltTab** — `mac/alttab/README.md`.
- **SSH** — bootstrap writes a `github.com` block. Add a block per additional git
  host you use:

  ```
  Host <git-host>
      HostName <git-host>
      User git
      IdentityFile ~/.ssh/id_ed25519
      AddKeysToAgent yes
      UseKeychain yes
  ```

- **AWS SSO profiles** — not tracked. Get the account IDs and role names from your
  AWS SSO portal. Template for `~/.aws/config`:

  ```ini
  [profile <name>]
  sso_session = <session>
  sso_account_id = <account-id>
  sso_role_name = <role>
  region = <region>
  ```

- **kube contexts** — regenerate, don't copy: `gcloud container clusters get-credentials <cluster> --region <r> --project <p>` / `aws eks update-kubeconfig --name <cluster>`.
- **npm / uv globals** — re-install whatever `npm ls -g --depth=0` and `uv tool list` showed on the old machine.
- **pre-commit** — `pre-commit install` in this repo to activate the gitleaks hook.

---

## 5. Deliberately not tracked

Rebuild these by hand; they were excluded on purpose.

- **Claude.app in the Dock runs from a mounted DMG** (`/Volumes/Claude`) — it was never
  installed to `/Applications`. Not currently mounted. Install it properly next time.
- `wimlib` — one-off manual install.
- IB Gateway — vendor installer, licensed.
- python.org installers — the Brewfile's `python@3.12` is the managed one.
