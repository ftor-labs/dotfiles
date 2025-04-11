#==================================================================================================
#
#                             ███████╗███████╗██╗  ██╗██████╗  ██████╗
#                             ╚══███╔╝██╔════╝██║  ██║██╔══██╗██╔════╝
#                               ███╔╝ ███████╗███████║██████╔╝██║     
#                              ███╔╝  ╚════██║██╔══██║██╔══██╗██║     
#                             ███████╗███████║██║  ██║██║  ██║╚██████╗
#                             ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝
#                                                                               
#                         ✦ ✦ ✦   Maintained by Facundo Torraca   ✦ ✦ ✦
#
#                      🚀 Optimized ZSH configuration for Software Engineers 🚀
#
#==================================================================================================


# =================================================================================================
# ==================================== TERMINAL THEME =============================================
# =================================================================================================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# ZSH options for better user experience
setopt AUTO_CD                 # Just type directory name to cd into it
setopt CORRECT                 # Command auto-correction
setopt EXTENDED_HISTORY        # Save timestamp and duration in history
setopt HIST_EXPIRE_DUPS_FIRST  # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_FIND_NO_DUPS       # Do not display duplicates when searching history
setopt HIST_IGNORE_DUPS        # Don't record immediate duplicate commands
setopt HIST_IGNORE_SPACE       # Don't record commands starting with a space
setopt HIST_VERIFY             # Show command with history expansion before running it
setopt SHARE_HISTORY           # Share history between all sessions

# History configuration
HISTSIZE=50000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# =================================================================================================
# ======================================= USER CONFIG =============================================
# =================================================================================================

# Detect architecture and set appropriate Homebrew path
export BREW_PREFIX=$(brew --prefix)

# Set editor based on connection type
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
   export EDITOR='nvim'
fi

# ────────────────────────────────────────── aliases ─────────────────────────────────────────────┐
# Git aliases
alias g="git"
alias gs="git status"
alias gp="git pull"
alias gl="git log --oneline --graph"

# Common aliases
alias v="nvim"
alias c="clear"
alias k="kubectl"

# Terraform aliases
alias tf="terraform"
alias tfi="terraform init"
alias tfa="terraform apply"
alias tfp="terraform plan"
alias tfs="terraform show"
alias tfd="terraform destroy"

# Docker aliases
alias d="docker"
alias dps="docker ps"
alias dc="docker-compose"
alias dcu="docker-compose up"
alias dcd="docker-compose down"

# Ptyhon aliases
alias pye="python -m venv .venv"
alias pya="source .venv/bin/activate"

# Utilities
alias myip="curl -s https://ifconfig.me && echo"
alias dotfiles="code $HOME/ftor/dotfiles"
# ────────────────────────────────────────────────────────────────────────────────────────────────┘

# ────────────────────────────────────────── scrips ──────────────────────────────────────────────┐
# personal scripts 
export PATH="$HOME/.custom-scripts:$PATH"
# ────────────────────────────────────────────────────────────────────────────────────────────────┘

# =================================================================================================
# ========================================== TOOLS ================================================
# =================================================================================================

# ────────────────────────────────────────── zoxide ──────────────────────────────────────────────┐
eval "$(zoxide init zsh)"
alias cd="z"
# ────────────────────────────────────────────────────────────────────────────────────────────────┘

# ─────────────────────────────────────────── eza ────────────────────────────────────────────────┐
alias ls="eza --icons=always"
alias ll="eza --icons=always -l"
alias la="eza --icons=always -la"
alias lt="eza --tree --icons=always"
alias llt="eza --tree --icons=always -l"
# ────────────────────────────────────────────────────────────────────────────────────────────────┘


# =================================================================================================
# ======================================== LANGUAGES ==============================================
# =================================================================================================

# ──────────────────────────────────────── terraform ─────────────────────────────────────────────┐
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C "$BREW_PREFIX/bin/terraform" terraform
# ────────────────────────────────────────────────────────────────────────────────────────────────┘

# ────────────────────────────────────────── python ──────────────────────────────────────────────┐
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# ────────────────────────────────────────────────────────────────────────────────────────────────┘

# ─────────────────────────────────────────── node ───────────────────────────────────────────────┐
export NVM_DIR="$HOME/.nvm"
[ -s "$BREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$BREW_PREFIX/opt/nvm/nvm.sh"
[ -s "$BREW_PREFIX/opt/nvm/etc/bash_completion" ] && \. "$BREW_PREFIX/opt/nvm/etc/bash_completion"  
# ────────────────────────────────────────────────────────────────────────────────────────────────┘

# ────────────────────────────────────────── java ────────────────────────────────────────────────┐
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
# ────────────────────────────────────────────────────────────────────────────────────────────────┘

# =================================================================================================
# ======================================= CREDENTIALS =============================================
# =================================================================================================

# Load credentials from 
source $HOME/.creds

