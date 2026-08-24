# AltTab configuration backup

Captures the portable part of AltTab's config — hotkeys, appearance, window-listing
behaviour — by exporting the `com.lwouis.alt-tab-macos` defaults domain to an XML plist.

## What's here

- `com.lwouis.alt-tab-macos.plist` — XML-format defaults dump. Diffable, safe to commit.

## What's stripped

The live domain also carries Microsoft AppCenter telemetry identifiers
(`MSAppCenterInstallId`, `MSAppCenterPastDevices`, `MSAppCenterSessionIdHistory`,
`MSAppCenterUserIdHistory`). Those are machine/user-bound and meaningless on a new
box, so they're removed from the committed copy. No credentials live in this domain.

## Restoring on a new machine

`restore_configs` in `mac/bootstrap.sh` imports this automatically when AltTab isn't
running. Manually:

```bash
osascript -e 'quit app "AltTab"'
defaults import com.lwouis.alt-tab-macos /path/to/com.lwouis.alt-tab-macos.plist
open -a AltTab
```

## Refreshing this backup

Run from the repo root:

```bash
osascript -e 'quit app "AltTab"' 2>/dev/null
defaults export com.lwouis.alt-tab-macos mac/alttab/com.lwouis.alt-tab-macos.plist
for k in MSAppCenterInstallId MSAppCenterPastDevices MSAppCenterSessionIdHistory MSAppCenterUserIdHistory; do
    /usr/libexec/PlistBuddy -c "Delete :$k" mac/alttab/com.lwouis.alt-tab-macos.plist 2>/dev/null || true
done
plutil -convert xml1 mac/alttab/com.lwouis.alt-tab-macos.plist
open -a AltTab
```

Diff against `git` to see what changed before committing.
