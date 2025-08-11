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

## Workflow Integration

### 1. Daily Development Workflow

#### Starting Your Work Session

```bash
# Navigate to your project
cd /path/to/project

# Open Neovim
nvim
```

**First Steps:**

1. `<Space>e` - Open file tree to see project structure
2. `<Space>ff` - Find and open files you need to work on
3. `<Space>gg` - Check git status for any pending changes

#### Working with Files

1. **Finding Files**: Use `<Space>ff` instead of navigating through directories
2. **Searching Code**: Use `<Space>fg` to search for specific text across all files
3. **Quick File Switching**: Use `<Space><Space>` for recently opened files

#### Code Editing

1. **Intelligent Completion**:
   - LSP provides context-aware suggestions
   - Codeium AI gives smart completions (accept with `<Tab>`)
   - Use `<C-Up/Down>` to navigate completion menu

2. **Code Navigation**:
   - `gd` to jump to definitions
   - `<C-o>` to go back to previous location
   - `K` to see documentation without leaving your file

3. **Error Handling**:
   - Red underlines show errors
   - `<Space>xx` opens diagnostics panel
   - `]d` / `[d` to navigate between errors

### 2. DevOps-Specific Workflows

#### Working with Infrastructure Code

**Terraform Projects:**

1. Open `.tf` files - automatic syntax highlighting
2. `<Space>lf` - Auto-format with terraform_fmt
3. LSP provides validation and completion for resources

**Docker Development:**

1. Dockerfile gets syntax highlighting and validation
2. docker-compose.yml has schema validation
3. Use `<Space>fg` to search for container configurations

**Kubernetes Manifests:**

1. YAML files get Kubernetes schema validation
2. Hover over fields (`K`) for documentation
3. Errors show for invalid configurations

**Ansible Playbooks:**

1. Full syntax highlighting for playbooks
2. Schema validation for task structure
3. Quick navigation between roles and tasks

#### Git Workflow Integration

**Daily Git Operations:**

1. `<Space>gg` - Open Neogit for visual git interface
2. Stage changes with `s`, unstage with `u`
3. Commit with `c c`, write message, and `:wq`
4. Push with `P p`

**Reviewing Changes:**

1. `<Space>gd` - Open diff view for all changes
2. Navigate files in diff view
3. `<Space>gc` - Close diff view when done

**Handling Conflicts:**

1. Conflicts show up in file tree with special icons
2. Open conflicted files to see conflict markers
3. Use LSP actions to resolve conflicts
4. Stage resolved files in Neogit

### 3. Advanced Features

#### AI-Powered Development

- **Codeium Integration**: Accept suggestions with `<Tab>`
- **Context-Aware**: AI understands your project structure
- **Multi-Language**: Works with all supported languages

#### Session Management

- `<Space>qs` - Save current session (windows, buffers, etc.)
- `<Space>ql` - Restore last session
- Automatic session detection when reopening projects

#### Debugging (when configured)

- `<Space>db` - Toggle breakpoint
- `<Space>dc` - Start/continue debugging
- `<Space>di/do` - Step into/over functions

## Language-Specific Features

### Python Development

```python
# Automatic imports organization
# Type hints validation
# Black formatting on save
# Flake8 linting
```

**Workflow:**

1. `<Space>lf` - Format with Black + isort
2. Errors show inline with Pyright
3. Virtual environment auto-detection

### Go Development

```go
// Automatic goimports
// gofumpt formatting
// Full gopls integration
```

**Workflow:**

1. Save file - auto-format and organize imports
2. `gd` - Jump to definitions across packages
3. Built-in testing support

### Bash/Shell Scripts

```bash
#!/bin/bash
# Shellcheck integration
# Syntax highlighting
# Auto-completion
```

**Workflow:**

1. Shellcheck shows common script issues
2. LSP provides command completion
3. Format with shfmt on save

## Customization

### Adding New Languages

1. **Add LSP Server** (in `mason-lspconfig` setup):

```lua
ensure_installed = {
    "new_language_ls",  -- Add your language server
    -- ... existing servers
}
```

2. **Add Formatter** (in `conform.nvim` setup):

```lua
formatters_by_ft = {
    your_language = { "your_formatter" },
    -- ... existing formatters
}
```

3. **Add Linter** (in `nvim-lint` setup):

```lua
linters_by_ft = {
    your_language = { "your_linter" },
    -- ... existing linters
}
```

### Changing Theme

Replace `catppuccin` with another theme in the plugin configuration:

```lua
{
    "your-theme/nvim",
    config = function()
        vim.cmd.colorscheme("your-theme")
    end,
}
```

### Custom Keybindings

Add to the key mappings section:

```lua
keymap("n", "<your-key>", ":YourCommand<CR>", opts)
```

## Troubleshooting

### Common Issues

**LSP Not Working:**

1. `:LspInfo` - Check if LSP is attached
2. `:Mason` - Verify language server is installed
3. Restart Neovim

**Formatting Not Working:**

1. `:ConformInfo` - Check formatter availability
2. Manually install formatter: `:Mason`
3. Check formatter configuration

**Git Integration Issues:**

1. Ensure you're in a git repository
2. Check git status: `git status`
3. Restart Neovim if needed

**Performance Issues:**

1. Check plugin loading: `:Lazy`
2. Disable unused plugins
3. Reduce `updatetime` in configuration

### Getting Help

**Within Neovim:**

- `:help <topic>` - Built-in help system
- `:Telescope help_tags` - Search help topics
- `:checkhealth` - System health check

**Key Mapping Reference:**

- `<Space>fk` - Search all keymaps
- Which-key popup shows available commands

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

## Contributing

To extend this configuration:

1. **Fork the configuration**
2. **Add new plugins** in the appropriate sections
3. **Test thoroughly** with your workflows
4. **Document changes** in this README
5. **Share improvements** with the community

## License

This configuration is provided as-is for educational and productivity purposes. Individual plugins retain their respective licenses.

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
