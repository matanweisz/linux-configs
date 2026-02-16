# Mac DevOps Workstation Setup

Bootstrap automation for a Mac DevOps workstation. Installs tools via Homebrew, restores dotfiles, and configures the system with the **Tokyo Night** theme across all tools.

## Quick Start

```bash
cd mac
./bootstrap.sh   # Choose option 7 to run everything
```

After bootstrap:
1. Open a new terminal for zsh config to load
2. Run `nvim` — plugins install automatically on first launch
3. Open tmux, press `Ctrl+a` then `I` to install tmux plugins
4. Launch AeroSpace: `open -a AeroSpace`
5. Generate SSH key: `ssh-keygen -t ed25519 -C "your@email.com"`

---

## Directory Structure

```
mac/
├── bootstrap.sh              # Main setup script (interactive menu)
├── Brewfile                  # All Homebrew packages and casks
├── macos-defaults.sh         # macOS system preferences for developers
├── configs/
│   ├── .gitconfig            # Git config with delta diffs
│   ├── .gitignore_global     # Global gitignore (.DS_Store, .env, etc.)
│   └── starship.toml         # One-line prompt with Tokyo Night colors
├── zsh/
│   ├── .zshrc                # Shell config with Zinit plugins
│   └── .zsh_aliases          # All aliases and shell functions
├── ghostty/
│   └── config                # Terminal config (Tokyo Night theme)
├── nvim/
│   └── init.lua              # Neovim config (lazy.nvim, Tokyo Night)
├── tmux/
│   └── tmux.conf             # tmux config (Tokyo Night colors, TPM)
└── aerospace/
    └── aerospace.toml        # Tiling window manager (i3-like keybindings)
```

---

## What Gets Installed

### CLI Tools

| Tool | Replaces | What it does |
|------|----------|-------------|
| `eza` | `ls` | File listing with icons, git status, tree view |
| `bat` | `cat` | Syntax-highlighted file viewer |
| `fd` | `find` | Fast file finder, respects `.gitignore` |
| `ripgrep` | `grep` | Fast text search across files |
| `fzf` | — | Fuzzy finder for files, history, completions |
| `zoxide` | `cd` | Smart directory jumping, learns your habits |
| `btop` | `htop` | System monitor with graphs |
| `jq` / `yq` | — | JSON / YAML processors |
| `git-delta` | `diff` | Side-by-side git diffs with syntax highlighting |
| `lazygit` | — | Terminal UI for git |
| `lazydocker` | — | Terminal UI for Docker |
| `k9s` | — | Terminal UI for Kubernetes |
| `atuin` | `ctrl+r` | Shell history search with SQLite backend |
| `direnv` | — | Auto-loads `.envrc` files per directory |
| `starship` | `PS1` | Fast cross-shell prompt |

### DevOps Tools

| Tool | Purpose |
|------|---------|
| `awscli` | AWS CLI |
| `terraform` / `terragrunt` | Infrastructure as Code |
| `ansible` | Configuration management |
| `kubectl` / `kubectx` / `helm` | Kubernetes management |
| `argocd` | GitOps CD |
| `stern` | Multi-pod log tailing |
| `dive` | Docker image layer inspection |
| `trivy` | Container vulnerability scanning |
| `gitleaks` | Secret scanning in git repos |
| `gh` | GitHub CLI |

### GUI Apps

Ghostty, VS Code, Docker Desktop, Raycast, AeroSpace, Chrome, Slack, WhatsApp, Bitwarden, Spotify, Stats (menu bar monitor).

---

## Configuration Details

### Shell (Zsh + Zinit)

**Plugin manager:** [Zinit](https://github.com/zdharma-continuum/zinit) — fast, supports lazy loading and turbo mode. Auto-installs on first shell launch if missing.

**Plugins:**

| Plugin | What it does |
|--------|-------------|
| `zsh-completions` | Extra completion definitions for common tools |
| `zsh-autosuggestions` | Fish-like inline suggestions from history (accept with `Ctrl+Space`) |
| `zsh-syntax-highlighting` | Real-time command coloring (valid = green, invalid = red) |
| `fzf-tab` | Replaces default tab completion with fzf fuzzy matching |

**Tool integrations loaded in `.zshrc`:**
- `starship` — prompt
- `zoxide` — replaces `cd` (use `cd` normally, it learns your frequent directories)
- `direnv` — auto-loads `.envrc` when entering directories
- `atuin` — replaces `Ctrl+R` with searchable history database
- `fzf` — `Ctrl+T` to find files, `Ctrl+R` for history (if atuin disabled), `Alt+C` for directories
- `kubectl` completion — tab completion for all kubectl commands

### Starship Prompt

Single-line prompt showing only essential info with Tokyo Night colors:

```
~/project  main !2+1 k8s prod aws dev 3s ❯
```

- **Directory** (blue) — truncated to 3 segments, relative to repo root
- **Git branch** (green) — current branch name
- **Git status** (red) — modified/staged/untracked counts
- **K8s context** (cyan) — only shows when kubectl is configured
- **AWS profile** (orange) — only shows when AWS_PROFILE is set
- **Duration** (yellow) — only shows for commands taking >2 seconds
- **Prompt char** — green `❯` on success, red `❯` on error

### Ghostty Terminal

- **Theme:** Tokyo Night (built-in)
- **Font:** JetBrainsMono Nerd Font, size 14, thickened for retina
- **Window:** Hidden titlebar, slight transparency (0.95) with blur
- **Splits:** `Cmd+D` horizontal, `Cmd+Shift+D` vertical, `Cmd+W` close
- **Tabs:** `Cmd+Shift+[` / `Cmd+Shift+]` to switch

### Neovim

**Plugin manager:** [lazy.nvim](https://github.com/folke/lazy.nvim) — auto-bootstraps on first launch.

**Theme:** [Tokyo Night](https://github.com/folke/tokyonight.nvim) (night variant)

**Plugins:**

| Plugin | Purpose |
|--------|---------|
| `nvim-tree` | File explorer sidebar (`Ctrl+N` to toggle) |
| `lualine` | Statusline with git branch, diagnostics, file info |
| `treesitter` | Syntax highlighting for 20+ languages |
| `mason` + `mason-lspconfig` | Auto-installs LSP servers |
| `nvim-lspconfig` | LSP configuration for bash, docker, yaml, json, terraform, python, go, lua |
| `nvim-cmp` | Autocompletion with LSP, snippets, buffer, and path sources |
| `telescope` | Fuzzy finder (`<leader>ff` files, `<leader>fg` grep, `<leader>fb` buffers) |
| `gitsigns` | Git diff markers in the sign column |
| `which-key` | Shows available keybindings when you press `<leader>` |
| `nvim-autopairs` | Auto-close brackets and quotes |
| `Comment.nvim` | Toggle comments with `gcc` (line) or `gc` (visual selection) |
| `indent-blankline` | Visual indentation guides |
| `lazygit.nvim` | Open lazygit inside Neovim (`<leader>gg`) |
| `vim-tmux-navigator` | Seamless `Ctrl+H/J/K/L` navigation between tmux panes and Neovim splits |

**LSP servers auto-installed:** bashls, dockerls, yamlls (with Kubernetes schemas), jsonls, terraformls, pyright, gopls, lua_ls.

**Key bindings:**

| Key | Action |
|-----|--------|
| `Space` | Leader key |
| `Ctrl+N` | Toggle file tree |
| `Space+ff` | Find files |
| `Space+fg` | Live grep |
| `Space+fb` | Open buffers |
| `Space+gg` | Open LazyGit |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover docs |
| `Space+rn` | Rename symbol |
| `Space+ca` | Code actions |
| `Space+f` | Format file |
| `Shift+H/L` | Previous/next buffer |
| `Ctrl+H/J/K/L` | Navigate splits (works across tmux panes) |
| `gcc` | Toggle line comment |
| `gc` (visual) | Toggle block comment |

### tmux

**Prefix:** `Ctrl+a` (instead of default `Ctrl+b`)

**Theme:** Tokyo Night colors applied directly (no theme plugin needed).

**Plugins (via TPM):**

| Plugin | Purpose |
|--------|---------|
| `tmux-sensible` | Sensible default settings |
| `tmux-resurrect` | Save/restore tmux sessions across restarts |
| `tmux-continuum` | Auto-saves sessions every 15 minutes, auto-restores on tmux start |
| `tmux-yank` | Copy to system clipboard |
| `vim-tmux-navigator` | Seamless Ctrl+H/J/K/L between tmux panes and Neovim |

**Key bindings:**

| Key | Action |
|-----|--------|
| `Ctrl+a \|` | Split pane vertically |
| `Ctrl+a -` | Split pane horizontally |
| `Ctrl+a h/j/k/l` | Navigate panes |
| `Ctrl+a H/J/K/L` | Resize panes |
| `Ctrl+a c` | New window |
| `Ctrl+a r` | Reload config |
| `Ctrl+a [` | Enter copy mode (vi keys, `v` to select, `y` to copy) |

### AeroSpace (Tiling Window Manager)

i3-like tiling window manager for macOS. Does **not** require disabling SIP.

**Key bindings (all use `Alt`):**

| Key | Action |
|-----|--------|
| `Alt+H/J/K/L` | Focus window left/down/up/right |
| `Alt+Shift+H/J/K/L` | Move window left/down/up/right |
| `Alt+1-6` | Switch to workspace |
| `Alt+Shift+1-6` | Move window to workspace |
| `Alt+F` | Toggle fullscreen |
| `Alt+Shift+Space` | Toggle floating |
| `Alt+/` | Toggle horizontal/vertical split |
| `Alt+Shift+-/=` | Shrink/grow window |
| `Alt+Shift+Tab` | Move workspace to next monitor |

Finder and System Preferences windows float automatically.

### Git

- **Diff pager:** `delta` with side-by-side view and line numbers
- **Pull:** Rebase by default (no merge commits for pulls)
- **Push:** Auto-sets upstream (`git push` works without `-u` on first push)
- **Fetch:** Auto-prunes deleted remote branches
- **Rerere:** Remembers how you resolved merge conflicts
- **Diff algorithm:** Histogram (produces cleaner diffs than default Myers)
- **Credential helper:** GitHub CLI (`gh auth`)
- **Global gitignore:** `.DS_Store`, `.env`, `.terraform/`, `node_modules/`, etc.

### macOS Defaults

The `macos-defaults.sh` script applies these developer-friendly settings:

- **Keyboard:** Fast key repeat (essential for Vim), disable all auto-correct
- **Finder:** Show hidden files, show path bar, list view, show file extensions
- **Dock:** Auto-hide with no delay, no recent apps, small icons
- **Mission Control:** Don't rearrange spaces, fast animations
- **Screenshots:** Save to `~/Screenshots` as PNG, no shadow
- **Trackpad:** Tap to click, three-finger drag

---

## Shell Aliases Reference

### General
| Alias | Command |
|-------|---------|
| `ls` | `eza --icons` |
| `ll` | `eza -lah --icons --git` |
| `lt` | `eza --tree --level=2` |
| `cat` | `bat` |
| `vim` / `vi` | `nvim` |
| `top` | `btop` |
| `lg` | `lazygit` |
| `lzd` | `lazydocker` |
| `ff` | Fuzzy find + open in Neovim |
| `mkd <dir>` | Create directory and cd into it |
| `pwdc` | Copy current path to clipboard |
| `myip` | Show public IP and location |

### Git
`gs` (status), `ga` (add), `gc "msg"` (commit), `gp` (push), `gpu` (pull), `gsw` (switch), `gcl` (clone), `glog` (graph log)

### Terraform
`t` (terraform), `ti` (init), `tp` (plan), `ta` (apply -auto-approve), `td` (destroy), `tg` (terragrunt)

### Kubernetes
`k` (kubectl), `kg` (get), `ka` (apply -f), `kd` (describe), `kl` (logs), `ke` (exec -it), `kns` (kubens), `kctx` (kubectx), `k9` (k9s)

### Interactive Switchers
| Function | What it does |
|----------|-------------|
| `kco` | Interactive kubectl context switcher |
| `awsuser` | Interactive AWS profile switcher with credential verification |
| `ec2ls` | List EC2 instances in a table (name, state, ID, IPs, type) |
| `ec2ssh <id>` | SSH to EC2 instance by ID (auto-detects user from AMI) |

### Docker
`dps` (running containers table), `dimg` (images table)
