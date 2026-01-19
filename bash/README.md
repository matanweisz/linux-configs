# Bash Configuration

Custom shell aliases and functions for DevOps workflow.

## Setup

Add to your `~/.bashrc`:

```bash
# Source bash aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Starship prompt
eval "$(starship init bash)"
```

## Key Aliases

### General
- `ls` - eza with icons
- `ll` - Detailed listing with git status
- `la` - List all including hidden
- `lt` - Tree view (2 levels)
- `vim` - Opens neovim
- `cat` - Uses bat with syntax highlighting
- `ff` - Fuzzy find files and open in nvim
- `lzg` / `lzd` - lazygit / lazydocker

### Git
- `gs`, `ga`, `gc`, `gp`, `gpu` - status, add, commit, push, pull
- `gsw` - switch branch
- `gcl` - clone

### DevOps
- `k` - kubectl
- `t`, `ti`, `ta`, `td` - terraform commands
- `kco` - Interactive kubectl context switcher
- `awsuser` - Interactive AWS profile switcher

### AWS EC2
- `ec2ls` - List EC2 instances in table format
- `ec2ssh <id>` - SSH to instance by ID
- `ec2scp <id> <local> <remote>` - SCP to instance
- `ec2stat <id>` - Start/stop instance

### Python
- `venv` - Create and activate virtual environment
- `py` - python3
- `pipr` - pip install -r
