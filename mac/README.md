# Mac DevOps Workstation Setup

Bootstrap automation for a Mac DevOps workstation. Installs tools via Homebrew, restores dotfiles, and configures the system with the **Tokyo Night** theme across all tools.

## Quick Start

```bash
cd mac
./bootstrap.sh   # Choose option 11 to run everything
```

> Updating an existing machine? Re-run `./bootstrap.sh` and pick option **10 (Cleanup orphaned packages)** to uninstall anything you removed from the Brewfile. The cleanup is opt-in and shows you what it would remove before doing it.

After bootstrap:
1. Open a new terminal for zsh config to load
2. Run `nvim` — plugins install automatically on first launch
3. Launch Raycast: `open -a Raycast` — handles window tiling and global keyboard shortcuts
4. Launch AltTab: `open -a AltTab` — Cmd+Tab replacement that sees every window
5. JankyBorders auto-starts as a `brew services` daemon (focus ring on the active window)
6. Launch Rancher Desktop: `open -a "Rancher Desktop"` — first run sets up Kubernetes & container runtime
7. Generate SSH key: `ssh-keygen -t ed25519 -C "your@email.com"`

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
├── ghostty/
│   └── config                # Terminal config (Tokyo Night theme)
└── nvim/
    └── init.lua              # Neovim config (lazy.nvim, Tokyo Night)
```

> Window management & keyboard shortcuts: **Raycast** (configured via its UI) + **JankyBorders** (focus ring, `configs/borders/bordersrc`) + **AltTab** (window switcher, configured via its UI).

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

Ghostty, VS Code, Rancher Desktop, Raycast, Chrome, Slack, WhatsApp, Bitwarden, Spotify, Stats (menu bar monitor).

---

## Configuration Details

### Shell (Zsh + Zinit)

**Plugin manager:** [Zinit](https://github.com/zdharma-continuum/zinit) — fast, supports lazy loading and turbo mode. Auto-installs on first shell launch if missing. The 2026 config uses turbo loading (`wait` + `lucid`) for sub-100ms startup.

**Plugins (turbo-loaded):**

| Plugin | What it does |
|--------|-------------|
| `zsh-completions` | Extra completion definitions for common tools |
| `fzf-tab` | Replaces tab completion with fzf fuzzy matching |
| `fast-syntax-highlighting` | Real-time command coloring (~3× faster than zsh-syntax-highlighting) |
| `zsh-autosuggestions` | Fish-like inline suggestions from history (accept with `Ctrl+Space`) |
| `zsh-history-substring-search` | Up/Down arrows complete from history matching the typed prefix |
| `zsh-you-should-use` | Nudges you when you type a command that has an alias |
| `forgit` | fzf-driven git: `ga`, `glo`, `gd`, `gco`, etc. |
| OMZ snippets | Completion-only snippets for kubectl, helm, terraform, aws, docker, gcloud |

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

**Plugins (2026 stack):**

| Plugin | Purpose |
|--------|---------|
| `snacks.nvim` | Swiss-army-knife: picker, explorer, lazygit, terminal, dashboard, indent, notifier, statuscolumn, bigfile (replaces ~8 plugins) |
| `blink.cmp` | Rust-powered completion (replaces nvim-cmp) |
| `mason.nvim` v2 + `mason-lspconfig` v2 | Auto-installs LSP servers via the new `vim.lsp.config()` native API |
| `mason-tool-installer` | Auto-installs CLI tools for formatters & linters |
| `nvim-lspconfig` | LSP server registry (yamlls, terraformls, helm-ls, dockerls, bashls, basedpyright, gopls, marksman, jsonls, lua_ls) |
| `nvim-treesitter` (+ textobjects) | Syntax + indentation for 25+ languages |
| `SchemaStore.nvim` | JSON/YAML schema bundle (Kubernetes, GitHub Actions, kustomization, etc.) |
| `oil.nvim` | Buffer-as-directory editing — press `-` to open parent dir |
| `gitsigns.nvim` | Diff markers, hunk staging, blame |
| `diffview.nvim` | Side-by-side diff / PR-style review |
| `lualine.nvim` | Statusline |
| `which-key.nvim` | Keymap discoverability |
| `flash.nvim` | `s{char}{char}` motion jumping |
| `trouble.nvim` v3 | Diagnostics / quickfix panel |
| `todo-comments.nvim` | TODO/FIXME/HACK highlighting + search |
| `mini.surround` / `mini.pairs` / `mini.ai` / `mini.comment` | Editor utilities |
| `render-markdown.nvim` | In-buffer markdown rendering (headings, code blocks, tables) |
| `conform.nvim` | Format-on-save dispatcher (stylua, ruff, gofmt, terraform fmt, yamlfmt, prettier, shfmt) |
| `nvim-lint` | Async linting (hadolint, tflint, yamllint, ruff, shellcheck, actionlint) |

**LSP servers auto-installed:** yamlls (with Kubernetes + datreeio CRD store), terraformls, helm-ls, dockerls, bashls, basedpyright, gopls, marksman, jsonls, lua_ls.

**CLI tools auto-installed (via mason-tool-installer):** hadolint, tflint, actionlint, shellcheck, yamllint, ruff, stylua, shfmt, prettier, markdownlint-cli2, yamlfmt, goimports.

**Key bindings:**

| Key | Action |
|-----|--------|
| `Space` | Leader key |
| `Ctrl+N` | Toggle file tree (snacks.explorer) |
| `Space+e` | Reveal current file in explorer |
| `-` | Open parent directory as buffer (oil.nvim) |
| `Space+ff` | Find files |
| `Space+fg` | Live grep |
| `Space+fb` | Open buffers |
| `Space+fr` | Recent files |
| `Space+gg` | Open LazyGit |
| `Space+gd` | Open Diffview |
| `Space+cc` | Toggle Claude Code in floating terminal |
| `Space+tt` | Toggle generic terminal |
| `Space+xx` | Toggle Trouble diagnostics |
| `s{char}{char}` | Flash jump |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover docs |
| `Space+rn` | Rename symbol |
| `Space+ca` | Code actions |
| `Space+f` | Format file (conform.nvim) |
| `Shift+H/L` | Previous/next buffer |
| `Ctrl+H/J/K/L` | Navigate splits |

### Raycast (window tiling + keyboard shortcuts)

Raycast is the unified launcher / window-tiler / clipboard manager / shortcut runner. The bootstrap installs it via Brew but does **not** sync settings — those are configured per-machine through Raycast Pro's iCloud sync or its built-in import/export.

What Raycast handles in this setup:
- **Window tiling** (Settings → Window Management): half/quarter splits, full-screen, throw-to-display, etc. Avoid colliding with Ghostty (`Cmd+D`/`Cmd+Shift+D` splits).
- **Application launching** (`Option+Space` is the default; rebind in Settings → General if you want).
- **Clipboard history**, snippets, calculator, system commands.

No config file lives in this repo — set everything up in Raycast's UI on first launch.

### JankyBorders (focus ring)

Draws an 8px rounded border around the focused window in Tokyo Night blue (`#7aa2f7`); inactive windows get a dim border (`#414868`). Configured at `~/.config/borders/bordersrc` and run as a `brew services` daemon.

```bash
brew services restart borders   # apply config changes
```

Bootstrap option 8 installs the service. Border thickness, colors, and the blacklist are easy to tweak in the file.

### AltTab (window switcher)

[AltTab](https://github.com/lwouis/alt-tab-macos) replaces macOS's stock Cmd+Tab with a Windows-style switcher that lists every window across every Space. Open `AltTab → Preferences` after first launch and turn on:

- **Show windows from all spaces**
- **Start at login**

Default trigger is **Cmd+Tab** (it overrides the system one). All other defaults are sane.

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

### Modern CLI replacements (2026 additions)
| Alias | Tool |
|-------|------|
| `du` | `dust` (visual disk usage) |
| `df` | `duf` (colored partition view) |
| `ps` | `procs` (colored process tree) |
| `htop` | `btm` (bottom — modern alternative) |
| `http` | `xh` (Rust httpie, ~10× faster) |
| `help` | `tldr` (man pages for humans) |
| `kubectl` | `kubecolor` (colored kubectl output, transparent wrapper) |

---

## Safe `rm`

The shell defines `rm` as a function that **moves** files to `~/.local/share/trash/<timestamp>/` instead of deleting them. The trash dir survives reboots.

| Command | Behavior |
|---------|----------|
| `rm <path>...` | Trash items into a new timestamped batch |
| `unrm` | Show contents of the most recent trash batch |
| `unrm <name>` | Restore an item from the most recent batch back to `./` |
| `trash-clean` | Permanently delete all batches older than 7 days |
| `\rm <path>` | Bypass the function — real `/bin/rm` deletion (use this when you mean it) |
| `/bin/rm <path>` | Same effect as `\rm` — direct binary call |

The `\rm` escape works because zsh expands aliases but NOT functions when prefixed with `\`. Same trick lets you call `\ls` to bypass the eza alias, etc.

---

## Claude Code

Bootstrap option 7 installs Claude Code via the official native installer (auto-updating) and copies a custom statusline + permissions to `~/.claude/`.

The statusline shows two lines:

```
[Sonnet 4.6] high  📁 mac  🌿 main  ⎈ prod-eks  ☁️ default
██████████ 64% | $0.42 | ⏱ 12m04s
```

Top line: model + effort + dir + git branch + k8s context + AWS profile.
Bottom line: context bar (green/yellow/red by usage) + cost + duration.

Customize in `mac/claude/statusline.sh`. The script caches `git`/`kubectl` lookups for 5 seconds per session to avoid spam.

The included `~/.claude/settings.json` pre-allows safe read-only Bash commands (git status, kubectl get, ls, cat, rg, etc.) so you don't get permission prompts for them.

---

## What's new in the 2026 refresh

- **Window mgmt:** Raycast (tiling + shortcuts) + JankyBorders (8px focus ring) + AltTab (Cmd+Tab replacement)
- **Containers/K8s:** Rancher Desktop replaces Docker Desktop (open source, integrated K8s)
- **No tmux:** removed — workflow uses Ghostty splits when terminal multiplexing is needed
- **Safe rm:** `rm` now trashes to `~/.local/share/trash/<ts>/`; added `unrm` + `trash-clean`
- **Zsh:** turbo-loading; switched to `fast-syntax-highlighting`; added `zsh-history-substring-search`, `you-should-use`, `forgit`, OMZ completion snippets for kubectl/helm/tf/aws/docker/gcloud
- **Brewfile:** added `tlrc`, `mkcert`, `gum`, `just`, `dust`, `duf`, `procs`, `bottom`, `xh`, `fx`, `glow`, `yamllint`, `git-absorb`, `kubescape`, `kubecolor`, `helm-docs`, `kustomize`, `kind`, `helmfile`, `flux`
- **kubectl plugins:** krew + `tree`, `neat`, `view-secret`, `resource-capacity`, `images`, `who-can`, `node-shell`, `deprecations`, `explore`, `rolesum`
- **Claude Code:** native installer + DevOps statusline + permission defaults
- **Neovim:** full 2026 stack — `snacks.nvim`, `blink.cmp`, `oil.nvim`, `conform.nvim`, `nvim-lint`, `flash.nvim`, `trouble.nvim` v3, `mini.nvim`, `render-markdown.nvim`, `SchemaStore.nvim`. LSP via Mason v2 + native `vim.lsp.config()`. Added `helm-ls` and `basedpyright`.
