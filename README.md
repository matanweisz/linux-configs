# DevOps Ubuntu Bootstrap — Mac-parity edition

Automated setup that brings the macOS workflow (in `mac/`) to Ubuntu/GNOME, using
Linux-native tooling. Built and verified on **Ubuntu 24.04 LTS, GNOME 46, Wayland**.

What you get:
- **CLI via Homebrew on Linux** (one `Brewfile`, same tool names/versions as the Mac)
- **zsh + Zinit** (turbo plugins) — same `.zshrc`/aliases as the Mac
- **Ghostty** terminal (Tokyo Night, JetBrains Mono Nerd Font)
- **Neovim 2026** (snacks/blink/Mason v2, Tokyo Night) — shared with the Mac config
- **Starship** prompt with k8s/cloud/terraform modules + **git-delta**
- **Vicinae** — native, Raycast-compatible launcher (Super+Space)
- **Tiling Shell** + built-in tiling shortcuts (Super+arrows)
- **Claude Code** — sanitized (generic) config: statusline, safe hooks, permissions

## Usage

```bash
git clone https://github.com/matanweisz/linux-configs.git ~/git/linux-configs
cd ~/git/linux-configs
./bootstrap.sh           # interactive menu; option 1 = full run, in order
```

Menu options: 1) Full · 2) Homebrew+CLI · 3) Zsh+Zinit · 4) Docker+gcloud ·
5) Desktop apps+Ghostty · 6) Restore configs · 7) Claude Code · 8) Vicinae ·
9) GNOME tweaks+Tiling+fonts · 10) Git identity.

Privileged steps (apt, PPAs, initial Homebrew, Docker) prompt for your sudo password.
User-level steps (Vicinae, GNOME extensions/settings, fonts, Zinit, Claude config,
dotfiles) need no sudo.

## Package model (hybrid)

- **CLI tools → Homebrew** (`Brewfile`): identical names (`bat`, `fd`) and versions to the Mac.
- **GUI apps → apt/deb/snap** (`install/desktop-apps.sh`): Homebrew casks are macOS-only.
- **Native daemons → apt** (`install/devops-tools.sh`): Docker Engine, gcloud SDK.

## Directory structure

```
linux-configs/
├── bootstrap.sh              # entry point — drives the modules below
├── Brewfile                  # CLI tools (Homebrew on Linux)
├── install/
│   ├── brew.sh               # Homebrew + brew bundle + krew
│   ├── zsh.sh                # zsh + Zinit (+ chsh hint)
│   ├── devops-tools.sh       # Docker Engine + gcloud (native)
│   ├── desktop-apps.sh       # Ghostty, VS Code, Chrome, Slack, WhatsApp, etc.
│   ├── launcher.sh           # Vicinae + GNOME companion + Super+Space
│   ├── gnome-setup.sh        # gsettings + Tiling Shell + JetBrains Mono Nerd Font
│   ├── claude.sh             # Claude Code (native) + sanitized config
│   └── restore-configs.sh    # copy dotfiles into place (with backups)
├── zsh/{.zshrc,.zsh_aliases} # shell config
├── ghostty/config            # terminal config
├── nvim/init.lua             # editor config (shared with mac/nvim)
├── configs/{starship.toml,.gitconfig,.gitignore_global,btop/}
├── claude/                   # sanitized Claude Code config (settings, hooks, agents, ...)
├── bash/.bash_aliases        # bash fallback aliases
├── alacritty/, vim/          # legacy (kept for reference; not installed by default)
├── github/                   # SSH setup guide
├── backup/, gnome-backup.sh  # GNOME state capture (for migrations)
└── mac/                      # the macOS counterpart (source of truth for parity)
```

## After installation (manual / interactive)

1. `chsh -s "$(command -v zsh)"` then **log out/in** (also activates Homebrew PATH,
   the docker group, and the Vicinae + Tiling Shell GNOME extensions on Wayland).
2. `gh auth login` · `aws configure` · `gcloud init`
3. `ssh-keygen -t ed25519 -f ~/.ssh/github_ed25519` and add the pubkey to GitHub.
4. Run `nvim` once so lazy.nvim installs plugins.
5. Press **Super+Space** for Vicinae; **Super+arrows** to tile.

## Before moving to a new machine

```bash
./gnome-backup.sh
git add -A && git commit -m "Pre-migration backup" && git push
```

## Key aliases

| Alias | Description | | Alias | Description |
|-------|-------------|-|-------|-------------|
| `ls`/`ll`/`lt` | eza (icons/detail/tree) | | `k` | kubectl |
| `cat` | bat | | `kco` | switch kubectl context |
| `lg`/`lzd` | lazygit / lazydocker | | `awsuser` | switch AWS profile |
| `vim` | nvim | | `ec2ls`/`ec2ssh` | list / SSH EC2 by ID |
| `t`/`tp`/`ta` | terraform / plan / apply | | `rm`/`unrm` | safe-trash / restore |
