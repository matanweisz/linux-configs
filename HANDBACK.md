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
| AWS SSO | `aws sso logout` (all profiles), then confirm `~/.aws/sso/cache/` is empty. |
| gcloud | `gcloud auth revoke --all` and `gcloud auth application-default revoke`. |
| Other CLI vendors | Check `~/.config/*/credentials.json` and `~/.netrc` for live API credentials — rotate or delete each. |
| Atuin | Sync is off / local-only, but if a sync key was ever set, rotate it. |
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

Also grab:

- `~/Screenshots/` — screenshot target set by `macos-defaults.sh`, not synced anywhere.
- `~/Documents`, `~/Desktop` — anything personal.
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

---

## 4. Restore on the next machine

```bash
git clone git@github.com:matanweisz/linux-configs.git ~/git/linux-configs
cd ~/git/linux-configs/mac && ./bootstrap.sh   # option 12 = run everything
```

Going to Ubuntu instead? `cd ~/git/linux-configs && ./bootstrap.sh` — option 1 is the
full run. Same dotfiles, Linux-native tooling. See the repo `README.md`.

Then the manual pieces bootstrap can't do:

- **Claude Code** — `mac/claude/RESTORE-NOTES.md`. Both profiles (`~/.claude` and
  `~/.claude-personal`) and `skills/` restore automatically; re-add any `mcpServers`
  blocks by hand (scrubbed on purpose). Plugins/marketplaces: `mac/claude/plugins.md`.
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
