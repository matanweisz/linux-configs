# Machine hand-back checklist

For returning **this** MacBook. Work top to bottom; nothing here is reversible
after the wipe. Verified state as of 2026-08-19.

---

## 1. Rotate / revoke (do first — these are live credentials)

| What | Action |
|---|---|
| Requesty `ANTHROPIC_AUTH_TOKEN` | **Rotate regardless** — it was exposed in a session transcript. Revoke the old key in the Requesty console. Lives in `~/.claude/settings.json` + `~/.claude/settings.requesty.json` (neither is tracked). |
| GitHub CLI tokens | `gh auth token` per host (`github.com` is logged in as `matanweisz`, keyring). Revoke each PAT at github.com → Settings → Developer settings → Tokens. Also check `gh auth status -h git.zoominfo.com`. |
| SSH key `~/.ssh/id_ed25519` | Deauthorize the **public** key in GitHub → Settings → SSH and GPG keys. Same for any GHE (`git.zoominfo.com`) copy. Don't rely on the wipe. |
| AWS SSO | `aws sso logout` (all profiles), then confirm `~/.aws/sso/cache/` is empty. |
| gcloud | `gcloud auth revoke --all` and `gcloud auth application-default revoke`. |
| Higgsfield | `~/.config/higgsfield/credentials.json` holds a live API credential — rotate or delete. |
| Atuin | Sync is off / local-only, but if a sync key was ever set, rotate it. |
| Okta / VPN / work SSO | IT's problem — don't try to clean these up yourself. |

---

## 2. Export before wipe

**Verify this repo is pushed** — currently on branch `mac-backup-2026-08` with
uncommitted work. `git push` it before anything else.

Personal git state that exists **only on this machine**:

| Path | State | Note |
|---|---|---|
| `~/ai-sessions/trading-bot` | **35 unpushed commits, 13 dirty files** | Highest risk. Outside `~/git`, easy to miss. Drives the four `com.tradingbot.*` LaunchAgents. |
| `~/git/matanweisz-company` | **not a git repo** | No remote at all — local only. |
| `~/git/shorts-gsap` | **not a git repo** | No remote at all — local only. |
| `~/git/maps-memory` | 1 unpushed commit | |
| `~/git/shorts-theory-tv` | 1 unpushed commit | Drives `com.shorts-theory-tv.ui` LaunchAgent. |

LaunchAgents in `~/Library/LaunchAgents/` auto-run at login and are **not**
tracked by this repo — copy the plists out if you want to rebuild the schedule:
`com.tradingbot.{earnings,news,reflect,sentiment}`, `com.shorts-theory-tv.ui`.
They invoke `~/.rd/bin/docker` (Rancher), so the next machine needs Rancher first.

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

Then the manual pieces bootstrap can't do:

- **Claude Code** — `mac/claude/RESTORE-NOTES.md`. Re-enter `ANTHROPIC_AUTH_TOKEN`
  and both `mcpServers` blocks (scrubbed on purpose). Plugins/marketplaces:
  `mac/claude/plugins.md`.
- **Raycast** — `mac/raycast/README.md` (the plist restores; snippets/quicklinks need a `.rayconfig` export).
- **AltTab** — `mac/alttab/README.md`.
- **SSH** — bootstrap writes a `github.com` block. Add the internal host if still relevant:

  ```
  Host git.zoominfo.com
      HostName git.zoominfo.com
      User git
      IdentityFile ~/.ssh/id_ed25519
      AddKeysToAgent yes
      UseKeychain yes
  ```

- **AWS SSO profiles** — not tracked. Get the account IDs and role names from the AWS SSO
  portal. Template for `~/.aws/config`:

  ```ini
  [profile org-excep-<role>-<account-id-1>]
  sso_session = <org>
  sso_account_id = <account-id-1>
  sso_role_name = <role>
  region = il-central-1

  [profile org-infdev-<role>-<account-id-2>]
  sso_session = <org>
  sso_account_id = <account-id-2>
  sso_role_name = <role>
  region = il-central-1
  ```

- **kube contexts** — regenerate, don't copy: `gcloud container clusters get-credentials <cluster> --region <r> --project <p>` / `aws eks update-kubeconfig --name <cluster>`.
- **npm globals** — `npm i -g @google/gemini-cli @higgsfield/cli`.
- **uv tools** — `uv tool install graphifyy`.
- **pre-commit** — `pre-commit install` in this repo to activate the gitleaks hook.

---

## 5. Deliberately not tracked

Rebuild these by hand; they were excluded on purpose.

- **Claude.app in the Dock runs from a mounted DMG** (`/Volumes/Claude`) — it was never
  installed to `/Applications`. Not currently mounted. Install it properly next time.
- `wimlib` — one-off manual install.
- IB Gateway — vendor installer, licensed.
- python.org installers — the Brewfile's `python@3.12` is the managed one.
