# DevOps Ubuntu Bootstrap

Automated setup for Ubuntu workstation with DevOps tools and personal configurations.

## Usage

```bash
git clone https://github.com/matan-github/linux-configs.git ~/linux-configs
cd ~/linux-configs
./bootstrap.sh
```

The script provides installation options:
- **Full installation** - Everything (recommended for new machines)
- **Core CLI tools** - eza, bat, fzf, ripgrep, lazygit, starship, etc.
- **DevOps tools** - Docker, kubectl, helm, Terraform, AWS/GCloud CLIs
- **Desktop apps** - VS Code, Chrome, Spotify, WhatsApp
- **Restore configs** - Dotfiles and GNOME settings only

## Directory Structure

```
linux-configs/
├── bootstrap.sh          # Main entry point
├── install/
│   ├── core-tools.sh     # CLI tools (eza, bat, fzf, lazygit, starship)
│   ├── devops-tools.sh   # Docker, K8s, Terraform, Cloud CLIs
│   ├── desktop-apps.sh   # VS Code, Chrome, Spotify
│   └── restore-configs.sh
├── configs/
│   ├── starship.toml     # Prompt config
│   ├── .gitconfig
│   └── btop/
├── bash/
│   └── .bash_aliases     # Shell aliases and functions
├── alacritty/            # Terminal config
├── nvim/init.lua         # Neovim config
├── vim/.vimrc            # Vim config
├── github/               # SSH setup guide
├── backup/               # GNOME settings backups
└── gnome-backup.sh       # GNOME backup script
```

## Before Moving to New Machine

```bash
# Update GNOME backup with latest settings
./gnome-backup.sh

# Commit and push
git add -A && git commit -m "Pre-migration backup" && git push
```

## After Installation

1. Log out and back in (Docker group)
2. Generate SSH key: `ssh-keygen -t ed25519 -f ~/.ssh/github_ed25519`
3. Add key to GitHub: `cat ~/.ssh/github_ed25519.pub`
4. Authenticate: `gh auth login`
5. Configure AWS: `aws configure`
6. Configure GCloud: `gcloud init`

## Managing This Directory

### Adding new tools

Edit the appropriate script in `install/`:
- `core-tools.sh` - Terminal utilities
- `devops-tools.sh` - DevOps/cloud tools
- `desktop-apps.sh` - GUI applications

### Adding new configs

1. Copy config file to appropriate location (`configs/`, `bash/`, etc.)
2. Add restore logic to `install/restore-configs.sh`

### Updating GNOME settings

Run `./gnome-backup.sh` to create a new backup archive.

## Key Aliases

| Alias | Description |
|-------|-------------|
| `ls` | eza with icons |
| `ll` | Detailed listing with git status |
| `lt` | Tree view |
| `vim` | nvim |
| `cat` | bat |
| `lzg` | lazygit |
| `lzd` | lazydocker |
| `k` | kubectl |
| `t` | terraform |
| `kco` | Switch kubectl context |
| `awsuser` | Switch AWS profile |
| `ec2ls` | List EC2 instances |
| `ec2ssh` | SSH to EC2 by ID |
