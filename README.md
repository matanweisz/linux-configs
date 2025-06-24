# Vim Configuration Setup & Cheat Sheet

A comprehensive DevOps-focused Vim configuration with modern features, syntax highlighting, git integration, and AI-powered code completion.

## 🚀 Quick Setup on New Linux Machine

### 1. Prerequisites Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y vim git curl nodejs npm python3 python3-pip

# CentOS/RHEL/Fedora
sudo dnf install -y vim git curl nodejs npm python3 python3-pip

# Arch Linux
sudo pacman -S vim git curl nodejs npm python3 python3-pip
```

### 2. Clone and Setup Configuration

```bash
# Clone your dotfiles repository
git clone <your-repo-url> ~/dotfiles

# Copy .vimrc to home directory
cp ~/dotfiles/.vimrc ~/.vimrc

# Create necessary directories
mkdir -p ~/.vim/undodir
mkdir -p ~/.vim/plugged
```

### 3. Install vim-plug Plugin Manager

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

### 4. Install Plugins

```bash
# Open vim and install plugins
vim +PlugInstall +qall

# Alternative: Install plugins from command line
vim +'PlugInstall --sync' +qa
```

### 5. Install Nerd Fonts (Optional but Recommended)

```bash
# Download and install a Nerd Font for better icons
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" \
    https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
fc-cache -fv
```

### 6. Setup CoC Extensions

The CoC extensions will auto-install on first startup, but you can manually install them:

```bash
vim -c 'CocInstall coc-json coc-yaml coc-sh coc-docker coc-terraform coc-pyright coc-git coc-tsserver coc-prettier' -c 'qa'
```

---

## 📁 File Structure

```
~/.vim/
├── autoload/
│   └── plug.vim              # vim-plug plugin manager
├── plugged/                  # Installed plugins directory
├── undodir/                  # Persistent undo files
└── .vimrc                    # Main configuration file
```

---

## 🔧 Key Features

### Core Functionality

- **Syntax Highlighting**: Multi-language support via vim-polyglot
- **Line Numbers**: Absolute and relative line numbering
- **Smart Indentation**: Language-specific indentation rules
- **Persistent Undo**: Undo history survives file closing
- **System Clipboard**: Seamless copy/paste integration
- **Mouse Support**: Full mouse interaction

### DevOps Tools Support

- **Terraform**: Syntax highlighting, auto-formatting, completion
- **Kubernetes**: YAML support with proper indentation
- **Docker**: Dockerfile syntax and highlighting
- **Ansible**: Playbook syntax support
- **Helm**: Chart template support
- **JSON/YAML**: Proper formatting and validation

### Git Integration

- **Fugitive**: Full git workflow integration
- **GitGutter**: Real-time diff indicators in gutter
- **Airline Git**: Branch and change info in status bar

### AI & Auto-completion

- **CoC.nvim**: Language Server Protocol support
- **Codeium**: Free AI code suggestions
- **Multiple LSP**: Python, JavaScript, Terraform, Docker, etc.

---

## ⌨️ Essential Key Bindings

### File Navigation

| Key Binding   | Action                        |
| ------------- | ----------------------------- |
| `Ctrl+n`      | Toggle NERDTree file explorer |
| `:e filename` | Edit/open file                |
| `:w`          | Save file                     |
| `:q`          | Quit                          |
| `:wq` or `ZZ` | Save and quit                 |
| `:q!`         | Quit without saving           |

### NERDTree Navigation

| Key Binding | Action                             |
| ----------- | ---------------------------------- |
| `Enter`     | Open file/directory                |
| `i`         | Open file in horizontal split      |
| `s`         | Open file in vertical split        |
| `t`         | Open file in new tab               |
| `m`         | Show menu (create, delete, rename) |
| `R`         | Refresh tree                       |
| `?`         | Show help                          |

### Movement & Editing

| Key Binding | Action                    |
| ----------- | ------------------------- |
| `h/j/k/l`   | Left/Down/Up/Right        |
| `w/b`       | Next/previous word        |
| `0/$`       | Beginning/end of line     |
| `gg/G`      | Top/bottom of file        |
| `Ctrl+u/d`  | Page up/down              |
| `dd`        | Delete line               |
| `yy`        | Copy line                 |
| `p/P`       | Paste after/before cursor |
| `u`         | Undo                      |
| `Ctrl+r`    | Redo                      |

### Search & Replace

| Key Binding      | Action                      |
| ---------------- | --------------------------- |
| `/pattern`       | Search forward              |
| `?pattern`       | Search backward             |
| `n/N`            | Next/previous search result |
| `:%s/old/new/g`  | Replace all occurrences     |
| `:%s/old/new/gc` | Replace with confirmation   |

### CoC Auto-completion

| Key Binding | Action             |
| ----------- | ------------------ |
| `Tab`       | Accept completion  |
| `K`         | Show documentation |
| `gd`        | Go to definition   |
| `gr`        | Go to references   |
| `:CocList`  | Show CoC commands  |

### Git Operations (Fugitive)

| Command    | Action             |
| ---------- | ------------------ |
| `:Gstatus` | Show git status    |
| `:Gadd`    | Stage current file |
| `:Gcommit` | Commit changes     |
| `:Gpush`   | Push to remote     |
| `:Gblame`  | Show git blame     |
| `:Gdiff`   | Show diff          |

---

## 🎨 Visual Indicators

### Git Status Symbols (NERDTree)

- `✹` Modified files
- `✚` Staged files
- `✭` Untracked files
- `➜` Renamed files
- `━` Deleted files
- `✗` Dirty (uncommitted changes)
- `✔︎` Clean (no changes)

### GitGutter Symbols (Line Gutter)

- `✚` Added lines (green)
- `✹` Modified lines (yellow)
- `━` Removed lines (red)

---

## 🔧 Customization

### Changing Theme

```vim
" In .vimrc, replace:
colorscheme gruvbox
" With your preferred theme, e.g.:
colorscheme molokai
```

### Adding New Languages

```vim
" Add language support plugins in the plugin section:
Plug 'rust-lang/rust.vim'          " Rust support
Plug 'fatih/vim-go'                " Go support
Plug 'pangloss/vim-javascript'     " Better JavaScript
```

### Custom Key Mappings

```vim
" Add custom mappings to .vimrc:
nnoremap <leader>w :w<CR>          " Save with leader+w
nnoremap <leader>q :q<CR>          " Quit with leader+q
" Leader key is backslash (\) by default
```

---

## 🛠️ Troubleshooting

### Common Issues

#### Plugins Not Working

```bash
# Reinstall plugins
vim +PlugClean +PlugInstall +qall
```

#### CoC Not Working

```bash
# Check Node.js version (needs 14+)
node --version

# Rebuild CoC
vim -c 'CocRebuild' -c 'qa'
```

#### Icons Not Showing

- Install a Nerd Font and configure your terminal
- Ensure terminal supports UTF-8 encoding

#### Slow Performance

```vim
" Add to .vimrc for better performance:
set lazyredraw                    " Don't redraw during macros
set ttyfast                       " Faster terminal connection
```

### Checking Plugin Status

```vim
:PlugStatus                       " Check plugin installation status
:CocInfo                          " Show CoC information
:checkhealth                      " Check Vim health (Neovim only)
```

---

## 📚 Learning Resources

### Vim Basics

- `:help` - Built-in help system
- `:Tutor` - Interactive Vim tutorial
- [Vim Adventures](https://vim-adventures.com/) - Gamified learning

### Advanced Usage

- `:help user-manual` - Complete user manual
- [Practical Vim](https://pragprog.com/titles/dnvim2/practical-vim-second-edition/) - Excellent book
- [Vim Casts](http://vimcasts.org/) - Video tutorials

---

## 🔄 Maintenance

### Updating Plugins

```bash
# Update all plugins
vim +PlugUpdate +qall

# Update specific plugin
vim +PlugUpdate nerdtree +qall
```

### Backup Configuration

```bash
# Backup your .vimrc
cp ~/.vimrc ~/.vimrc.backup.$(date +%Y%m%d)

# Commit changes to git
cd ~/dotfiles
git add .vimrc
git commit -m "Update vim configuration"
git push
```

---

## 🚀 Performance Tips

1. **Disable unnecessary features** for large files:

   ```vim
   autocmd BufReadPre * if getfsize(@%) > 1000000 | syntax off | endif
   ```

2. **Use minimal config** for quick edits:

   ```bash
   vim -u NONE filename    # Start with no configuration
   ```

3. **Profile startup time**:
   ```bash
   vim --startuptime startup.log
   ```

---

## 🤝 Contributing

Feel free to customize this configuration for your needs. Common additions:

- Language-specific plugins
- Custom color schemes
- Additional key mappings
- Workflow-specific shortcuts

Remember to test changes in a separate branch and backup your working configuration before major modifications.

---

_Happy Vimming! 🎉_
