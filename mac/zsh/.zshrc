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

# ---- Plugins (zinit turbo mode for sub-100ms startup) ----

# completions BEFORE compinit
zinit ice wait"0a" lucid blockf
zinit light zsh-users/zsh-completions

# compinit must run synchronously
autoload -Uz compinit && compinit -C
zinit cdreplay -q

# fzf-tab AFTER compinit, BEFORE autosuggestions
zinit ice wait"0b" lucid
zinit light Aloxaf/fzf-tab

# fast-syntax-highlighting (replaces zsh-syntax-highlighting — 3x faster)
zinit ice wait"0c" lucid
zinit light zdharma-continuum/fast-syntax-highlighting

# autosuggestions
zinit ice wait"0c" lucid atload'!_zsh_autosuggest_start; bindkey "^ " autosuggest-accept'
zinit light zsh-users/zsh-autosuggestions

# history substring search (Up/Down completes from history matching prefix)
zinit ice wait"0c" lucid atload'
    bindkey "^[[A" history-substring-search-up
    bindkey "^[[B" history-substring-search-down
'
zinit light zsh-users/zsh-history-substring-search

# forgit — fzf-driven git: ga, glo, gd, gco, etc.
zinit ice wait"1" lucid
zinit light wfxr/forgit

# DevOps completions via OMZ snippets (lighter than full plugins)
zinit ice wait"1" lucid as"completion"; zinit snippet OMZP::kubectl
zinit ice wait"1" lucid as"completion"; zinit snippet OMZP::helm
zinit ice wait"1" lucid as"completion"; zinit snippet OMZP::terraform
zinit ice wait"1" lucid as"completion"; zinit snippet OMZP::aws
zinit ice wait"1" lucid as"completion"; zinit snippet OMZP::docker
zinit ice wait"1" lucid as"completion"; zinit snippet OMZP::gcloud

# ---- Completion styling ----
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

# ---- Key Bindings ----# ---- Tool Init ----
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(direnv hook zsh)"
command -v atuin &>/dev/null && eval "$(atuin init zsh)"
command -v fzf &>/dev/null && source <(fzf --zsh)

# ---- FZF Config ----
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"

# ---- Aliases ----
source ~/.zsh_aliases

# ---- PATH ----
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export EDITOR="nvim"

# ---- gcloud SDK (official installer at ~/google-cloud-sdk) ----
if [[ -d "$HOME/google-cloud-sdk" ]]; then
    source "$HOME/google-cloud-sdk/path.zsh.inc"
    source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi
