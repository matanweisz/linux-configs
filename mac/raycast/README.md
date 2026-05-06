# Raycast configuration backup

This dir captures the **portable** part of Raycast's config — preferences, hotkeys (including the window-tiling shortcuts the project README mentions on first run), and general app settings — by exporting the `com.raycast.macos` defaults domain to an XML plist.

## What's here

- `com.raycast.macos.plist` — XML-format defaults dump. Diffable, safe to commit.

## What's NOT here (and why)

The bulk of Raycast's data lives in encrypted SQLite databases under
`~/Library/Application Support/com.raycast.macos/`:

- `raycast-enc.sqlite*` — main store (snippets, quicklinks, AI presets, …)
- `raycast-activities-enc.sqlite*` — activity / launch history
- `raycast-emoji.sqlite*` — emoji picker history

These are **encrypted with a key stored in the macOS login keychain** for the current user. Raw-copying these files to a new machine will fail to decrypt — the keychain item is host- and user-bound. Backing them up here would also commit your usage history, which is unnecessary noise.

The right way to migrate snippets, quicklinks, AI commands, hotkeys, and extension preferences is Raycast's built-in encrypted export:

1. Open Raycast → `⌘ ,` (Settings)
2. **Advanced** tab → scroll to **Import / Export**
3. Click **Export** → choose what to include → set a passphrase → save the `.rayconfig` file somewhere out of git (1Password, iCloud Drive, etc.)
4. On a new machine, install Raycast, then **Import** the `.rayconfig` and enter the passphrase.

Treat the `.rayconfig` like a secret — it contains your snippets and any API keys you've stored in extension prefs.

## Restoring the plist on a new machine

The `restore_configs` step in `mac/bootstrap.sh` will install this for you when present. Manually:

```bash
# Quit Raycast first, otherwise it'll overwrite our import on next exit
osascript -e 'quit app "Raycast"'

# Import
defaults import com.raycast.macos /path/to/com.raycast.macos.plist

# Reopen
open -a Raycast
```

## Refreshing this backup

Run from the repo root:

```bash
osascript -e 'quit app "Raycast"' 2>/dev/null
defaults export com.raycast.macos mac/raycast/com.raycast.macos.plist
plutil -convert xml1 mac/raycast/com.raycast.macos.plist
open -a Raycast
```

Diff against `git` to see what changed before committing.
