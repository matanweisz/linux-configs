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

### General
| Key | Action |
|-----|--------|
| `Space` | Leader key |
| `Esc` | Clear search highlights |

### File Navigation
| Key | Action |
|-----|--------|
| `Ctrl+n` | Toggle file tree |
| `<leader>e` | Find current file in tree |
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep (Telescope) |
| `<leader>fb` | Buffer list (Telescope) |
| `Shift+h` | Previous buffer |
| `Shift+l` | Next buffer |
| `<leader>bd` | Close buffer |

### LSP
| Key | Action |
|-----|--------|
| `K` | Hover documentation |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>f` | Format file |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |

### Completion & Snippets
| Key | Action |
|-----|--------|
| `Ctrl+Space` | Trigger completion |
| `Tab` | Select next item |
| `Shift+Tab` | Select previous item |
| `Enter` | Confirm selection |
| `Ctrl+l` | Jump to next snippet placeholder |
| `Ctrl+h` | Jump to previous snippet placeholder |

### Window Navigation
| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Move between splits |

## Included Plugins

- **lazy.nvim** - Modern plugin manager
- **catppuccin** - Mocha theme with transparency support
- **nvim-tree** - File explorer with git integration
- **lualine** - Statusline with catppuccin theme
- **telescope** - Fuzzy finder for files and grep
- **treesitter** - Advanced syntax highlighting and code understanding
- **mason** - LSP/DAP/Linter installer
- **nvim-lspconfig** - LSP configuration
- **nvim-cmp** - Autocompletion engine
- **gitsigns** - Git integration in sign column
- **which-key** - Keybinding helper popup
- **nvim-autopairs** - Auto close brackets/quotes
- **Comment.nvim** - Smart commenting
- **indent-blankline** - Indentation guides

## Language Support

DevOps-focused with LSP support for:
- **Infrastructure**: Bash, Docker, Terraform, HCL, YAML
- **Programming**: Python, Go, JavaScript, TypeScript, Lua
- **Data formats**: JSON, TOML, XML
- **Documentation**: Markdown
- **Version Control**: Git configs and commit messages
