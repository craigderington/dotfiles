# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Load secrets (if exists)
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"

# Load bash aliases
[[ -f "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

export EDITOR="nvim"
export KUBECONFIG="$HOME/.kube/config"
export KUBE_EDITOR="nvim"
export ANDROID_HOME="/opt/android-sdk"
export NVM_DIR="$HOME/.config/nvm"

# Consolidated PATH (single assignment for better performance)
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:/opt/android-sdk/cmdline-tools/latest/bin:$PATH"

# Cargo environment
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# ============================================================================
# LAZY LOADING (Performance optimization)
# ============================================================================

# Lazy load NVM (major performance improvement!)
nvm() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

node() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  node "$@"
}

npm() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  npm "$@"
}

npx() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  npx "$@"
}

# ============================================================================
# TOOL INITIALIZATIONS (with conditional checks)
# ============================================================================

# Initialize only if commands exist
command -v tv &>/dev/null && eval "$(tv init bash)"
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"
command -v pipx &>/dev/null && eval "$(register-python-argcomplete pipx)"
command -v starship &>/dev/null && eval "$(starship init bash)"

# ============================================================================
# COOL TRICKS & UTILITIES
# ============================================================================

# Command-not-found handler (suggests packages)
command_not_found_handle() {
  echo "Command '$1' not found. Searching packages..."
  pacman -Ss "^$1$" | head -5
}

# Directory bookmarking system
export MARKPATH="$HOME/.marks"
mark() { mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"; }
unmark() { rm -i "$MARKPATH/$1"; }
marks() { ls -l "$MARKPATH" 2>/dev/null | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9-; }
jump() { cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"; }

# Quick directory navigation
up() {
  local d=""
  local limit="${1:-1}"
  for ((i=1; i<=limit; i++)); do
    d="../$d"
  done
  cd "$d" || return
}

# Extract any archive format
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1" || return; }

# Show nerdfetch only in interactive shells (moved to end for faster startup)
[[ $- == *i* ]] && command -v nerdfetch &>/dev/null && nerdfetch -e
