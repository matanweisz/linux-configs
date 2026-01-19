# Vim Configuration

Vim configuration with vim-plug and DevOps-focused plugins.

## Setup

```bash
# Copy config
cp .vimrc ~/.vimrc

# Install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install plugins
vim +PlugInstall +qall
```

## Key Bindings

| Key | Action |
|-----|--------|
| `Ctrl+n` | Toggle NERDTree |
| `K` | Show documentation (CoC) |
| `Tab` | Confirm autocomplete |

## Included Plugins

- **NERDTree** - File explorer with git status
- **vim-airline** - Status bar
- **coc.nvim** - Autocompletion and LSP
- **vim-fugitive** - Git integration
- **vim-gitgutter** - Git diff in gutter
- **gruvbox** - Color scheme

## DevOps Plugins

- vim-terraform
- Dockerfile.vim
- vim-kubernetes
- ansible-vim
- vim-helm
- vim-yaml

## CoC Extensions

Auto-installed: json, yaml, sh, docker, terraform, pyright, git, prettier
