# Vim Configuration Setup & Cheat Sheet

A comprehensive DevOps-focused Vim configuration with modern features, syntax highlighting, git integration, and AI-powered code completion.

## 🚀 Quick Setup on New Linux Machine

### 1. Prerequisites Installation

```bash
sudo apt update
sudo apt install -y vim git curl nodejs npm python3 python3-pip
```

### 2. Clone and Setup Configuration

```bash
# Clone your dotfiles repository
git clone https://github.com/matanweisz/linux-configs.git

# Copy .vimrc to home directory
cp ~/linux-configs/.vimrc ~/.vimrc

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
# Install plugins from command line
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

## 🔄 Maintenance

### Updating Plugins

```bash
# Update all plugins
vim +PlugUpdate +qall
```

### Cleaning Unused Plugins

```bash
# Remove unused plugins
vim +PlugClean +qall
```

---
