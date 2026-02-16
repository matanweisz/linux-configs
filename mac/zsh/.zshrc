# =============================================================================
# .zshrc - Mac DevOps
# =============================================================================

# ---- Homebrew (Apple Silicon) ----
[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# ---- Zinit Plugin Manager ----
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# ---- Plugins ----
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light Aloxaf/fzf-tab

# ---- Completion ----
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --color=always $realpath 2>/dev/null || ls $realpath'

# ---- History ----
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory sharehistory
setopt hist_ignore_space hist_ignore_all_dups hist_save_no_dups

# ---- Key Bindings ----
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^ ' autosuggest-accept

# ---- Tool Init ----
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(direnv hook zsh)"
command -v atuin &>/dev/null && eval "$(atuin init zsh)"
command -v fzf &>/dev/null && source <(fzf --zsh)
command -v kubectl &>/dev/null && source <(kubectl completion zsh)

# ---- FZF Config ----
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"

# ---- Aliases ----
source ~/.zsh_aliases

# ---- PATH ----
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
export EDITOR="nvim"
