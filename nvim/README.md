# Neovim Configuration

Single-file Lua configuration for Neovim with DevOps-focused plugins.

## Setup

Copy to nvim config directory:

```bash
mkdir -p ~/.config/nvim
cp init.lua ~/.config/nvim/
```

On first launch, plugins will auto-install via lazy.nvim.

## Key Bindings

| Key | Action |
|-----|--------|
| `Space` | Leader key |
| `Ctrl+n` | Toggle file tree |
| `K` | Show hover documentation |
| `gd` | Go to definition |
| `gr` | Find references |
| `Tab` | Confirm autocomplete |

## Included Plugins

- **lazy.nvim** - Plugin manager
- **nvim-tree** - File explorer
- **telescope** - Fuzzy finder
- **treesitter** - Syntax highlighting
- **lspconfig** - Language server support
- **cmp** - Autocompletion
- **gruvbox** - Color scheme

## Language Support

Configured for: Lua, Python, Bash, YAML, JSON, Terraform, Docker, Kubernetes
