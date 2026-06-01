# Keyboard backlight automation (ASUS Aura / rogauracore)

Turns the laptop keyboard lights on (green, brightness 3) automatically at **every
boot** and **after resume from suspend/hibernate** — no manual run, no password.

## Why a systemd system service
`rogauracore` needs root (raw USB-HID access). A **systemd system service runs as root
at boot**, so the privilege is granted by the init system — the modern, correct approach
(vs. `rc.local`, cron `@reboot`, or a desktop autostart that would prompt for a password).

## Install (one time, needs sudo)
```bash
cd ~/git/linux-configs
sudo bash services/keyslight/install.sh
```
The installer:
1. Copies `keyslight.sh` → `/usr/local/sbin/keyslight.sh` (root-owned, not user-writable).
2. Installs `keyslight.service` (boot) and `keyslight-resume.service` (after sleep).
3. Retires the old broken duplicates: removes the typo'd `keylight.service` and masks the
   legacy SysV `asus_keyboard_backlight` so nothing double-drives the keyboard.
4. `enable --now` — lights come on immediately and at every boot/resume thereafter.

## Verify / manage
```bash
systemctl status keyslight.service
systemctl is-enabled keyslight.service keyslight-resume.service
journalctl -u keyslight.service -b          # this boot's log
sudo systemctl start keyslight.service      # re-apply lights now
```

## Change the color / brightness
Edit `keyslight.sh` here (`single_static 00ff00` = green; `brightness 3` = max), then
re-run the installer to push it to `/usr/local/sbin`.

## Undo
```bash
sudo systemctl disable --now keyslight.service keyslight-resume.service
sudo rm /etc/systemd/system/keyslight.service /etc/systemd/system/keyslight-resume.service
sudo systemctl unmask asus_keyboard_backlight.service   # if you want the old one back
sudo systemctl daemon-reload
```
