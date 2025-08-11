# Modern Neovim Configuration for DevOps

A powerful, modern Neovim configuration optimized for DevOps workflows, featuring advanced syntax highlighting, intelligent code completion, integrated Git workflows, and comprehensive language support for infrastructure-as-code tools.

## Features

- 🚀 **Modern Plugin Management** with lazy.nvim
- 🎨 **Beautiful UI** with Catppuccin theme and Lualine statusline
- 🔍 **Powerful Fuzzy Finding** with Telescope
- 💡 **Intelligent Code Completion** with nvim-cmp and AI-powered Codeium
- 📝 **Advanced Language Support** for 20+ DevOps languages
- 🔧 **Built-in LSP** with automated installation and configuration
- 🌳 **Git Integration** with Gitsigns, Fugitive, and Neogit
- 🐛 **Debugging Support** with DAP integration
- 📋 **Code Formatting** with Conform.nvim
- 🔍 **Linting** with nvim-lint
- 🏗️ **DevOps-Specific Tools** for Docker, Terraform, Kubernetes, and Ansible

## Supported Languages & Tools

### Core Languages

- **Bash/Shell** - Full LSP support with shellcheck linting
- **Python** - Pyright LSP with Black/isort formatting
- **Go** - gopls with goimports/gofumpt
- **Lua** - Native Neovim configuration support
- **JavaScript/TypeScript** - Full web development support

### DevOps & Infrastructure

- **Docker** - Dockerfile syntax and docker-compose support
- **Terraform** - HCL syntax with terraform_fmt
- **Kubernetes** - YAML schemas and validation
- **Ansible** - Playbook syntax and validation
- **Helm** - Chart templates and values
- **YAML/JSON** - Schema validation and formatting
- **TOML** - Configuration file support
- **Markdown** - Documentation with live preview

## Installation

### Prerequisites

```bash
# Install Neovim (0.9.0+)
brew install neovim  # macOS
# or
sudo apt install neovim  # Ubuntu/Debian
# or
sudo dnf install neovim  # Fedora

# Install required tools
brew install ripgrep fd  # macOS
# or
sudo apt install ripgrep fd-find  # Ubuntu/Debian
```

### Setup

1. **Backup existing configuration** (if any):

```bash
mv ~/.config/nvim ~/.config/nvim.backup
```

2. **Clone or create the configuration**:

```bash
mkdir -p ~/.config/nvim
# Copy the init.lua file to ~/.config/nvim/init.lua
```

3. **First launch**:

```bash
nvim
```

The configuration will automatically:

- Install the lazy.nvim plugin manager
- Download and install all plugins
- Set up LSP servers for supported languages
- Configure formatters and linters

## Quick Start Guide

### Essential Keybindings

**Leader Key**: `<Space>`

#### File Navigation

| Key              | Action            | Description                           |
| ---------------- | ----------------- | ------------------------------------- |
| `<C-n>`          | Toggle file tree  | Open/close nvim-tree                  |
| `<Space>e`       | Find file in tree | Locate current file in tree           |
| `<Space>ff`      | Find files        | Fuzzy find files in project           |
| `<Space>fg`      | Live grep         | Search text across project            |
| `<Space>fb`      | Find buffers      | Switch between open files             |
| `<Space><Space>` | Recent files      | Quick access to recently opened files |

#### Window Management

| Key           | Action           | Description                |
| ------------- | ---------------- | -------------------------- |
| `<C-h/j/k/l>` | Navigate windows | Move between split windows |
| `<C-Arrow>`   | Resize windows   | Resize current window      |
| `<Space>sv`   | Split vertical   | Create vertical split      |
| `<Space>sh`   | Split horizontal | Create horizontal split    |
| `<Shift-h/l>` | Navigate buffers | Previous/next buffer       |

#### Code Navigation & LSP

| Key         | Action               | Description                          |
| ----------- | -------------------- | ------------------------------------ |
| `gd`        | Go to definition     | Jump to function/variable definition |
| `gi`        | Go to implementation | Jump to implementation               |
| `gr`        | Find references      | Show all references                  |
| `K`         | Show documentation   | Display hover information            |
| `<Space>ca` | Code actions         | Show available code actions          |
| `<Space>rn` | Rename symbol        | Rename variable/function             |
| `<Space>lf` | Format code          | Format current file                  |

#### Git Operations

| Key         | Action         | Description              |
| ----------- | -------------- | ------------------------ |
| `<Space>gg` | Git status     | Open Neogit interface    |
| `<Space>gd` | Git diff       | Open diff view           |
| `<Space>hs` | Stage hunk     | Stage current change     |
| `<Space>hr` | Reset hunk     | Undo current change      |
| `]h` / `[h` | Navigate hunks | Next/previous git change |

## Plugin Reference

### Core Plugins

| Plugin             | Purpose           | Key Features                      |
| ------------------ | ----------------- | --------------------------------- |
| **lazy.nvim**      | Plugin manager    | Fast loading, lazy initialization |
| **nvim-tree**      | File explorer     | Git integration, diagnostics      |
| **telescope**      | Fuzzy finder      | File search, live grep, buffers   |
| **nvim-lspconfig** | LSP client        | Language servers, diagnostics     |
| **nvim-cmp**       | Completion engine | Multi-source completion           |
| **gitsigns**       | Git integration   | Inline diffs, hunk navigation     |

### DevOps Plugins

| Plugin               | Purpose            | Languages                      |
| -------------------- | ------------------ | ------------------------------ |
| **vim-terraform**    | Terraform support  | `.tf`, `.tfvars`               |
| **yaml-companion**   | Kubernetes YAML    | `.yaml`, `.yml`                |
| **vim-docker-tools** | Docker integration | `Dockerfile`, `docker-compose` |
| **schemastore.nvim** | JSON schemas       | Configuration validation       |

## Performance Tips

1. **Lazy Loading**: Most plugins load only when needed
2. **File Exclusions**: Git and node_modules are excluded from searches
3. **Optimized Startup**: Disabled unused built-in plugins
4. **Smart Completion**: Context-aware suggestions reduce noise
5. **Efficient Navigation**: Fuzzy finding is faster than directory browsing

---

## Quick Reference Card

### Most Used Commands (Print This!)

```
FILES:                    GIT:                     CODE:
<C-n>     Toggle tree     <Space>gg  Git status   gd        Go to def
<Space>ff Find files      <Space>gd  Diff view    K         Documentation
<Space>fg Live grep       ]h/[h      Next/prev    <Space>ca Code actions
<Space>e  Find in tree    <Space>hs  Stage hunk   <Space>rn Rename

NAVIGATION:               LSP:                     UTILITY:
<C-hjkl>  Move windows    <Space>ld  Diagnostics  <Esc>     Clear search
<Shift-hl> Buffers       <Space>lf  Format       gcc       Comment line
<Space>sv Split vertical  <Space>li  LSP info     <Space>xx Trouble panel

SEARCH & REPLACE:         SESSION:                 TERMINAL:
n/N       Next/prev       <Space>qs  Save session <Space>tf Float term
*         Search word     <Space>ql  Load session <Space>th Horizontal
<Space>fs Grep string     <Space>qd  Stop session <Space>tv Vertical
```

_Keep this reference handy while learning the configuration!_
