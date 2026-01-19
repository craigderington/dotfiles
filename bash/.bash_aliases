# ============================================================================
# FILE & DIRECTORY MANAGEMENT
# ============================================================================
alias lo="ls -al --color=auto"
alias ls="lsd"
alias n="nvim"
alias yy="yazi"

# ============================================================================
# LAZY TOOLS (TUI Applications)
# ============================================================================
alias lzs="lazysql"
alias lsh="lazyssh"
alias lzj="lazyjournal"
alias lzd="lazydocker"
alias lzg="lazygit"

# ============================================================================
# SYSTEM & MONITORING
# ============================================================================
alias ff="fastfetch"
alias nf="nerdfetch"
alias btp="btop"
alias srvcs="systemctl list-units --type=service --state=running"
alias status="sudo systemctl status"
alias renew="sudo systemctl restart"
alias net="sudo $HOME/.cargo/bin/netscanner"
alias sdm="sudo $HOME/.cargo/bin/systemd-manager-tui"

# ============================================================================
# PACKAGE MANAGEMENT
# ============================================================================
alias update="sudo pacman -Syu"
alias install="sudo pacman -S"
alias clean="sudo pacman -Sc"

# ============================================================================
# POWER MANAGEMENT
# ============================================================================
alias shutdown="sudo shutdown now"
alias reboot="sudo shutdown -r now"
alias restart="sudo shutdown -r now"

# ============================================================================
# SHELL MANAGEMENT
# ============================================================================
alias reload="source ~/.bashrc"
alias hst="history"

# ============================================================================
# NETWORK & API TOOLS
# ============================================================================
alias ipa="ifdata -pa wlan0"
alias rtx="curl rate.sx?n=10"
alias cht="curl cht.sh"
alias wtr="curl wttr.in?32808"
alias trp="trip -p tcp 8.8.8.8"
alias htpm="httpmonitor -interval 120s -timeout 30s -url"
alias pst="posting"
alias ctt="curl -fsSL https://christitus.com/linux | sh"

# ============================================================================
# DEVELOPMENT TOOLS
# ============================================================================
alias cl="claude"
alias csp="codesnap"
alias dlph="dolphie"
alias mmr="memray"
alias oc="opencode"
alias gemi="gemini"
alias ola="ollama"
alias olas="journalctl -fu ollama.service"
alias trans="transcribe"

# ============================================================================
# GIT SHORTCUTS
# ============================================================================
alias gpom="git push origin master"

# ============================================================================
# KUBERNETES
# ============================================================================
alias k9z="k9s --kubeconfig $HOME/.kube/config"

# ============================================================================
# TERMINAL MULTIPLEXERS & SESSIONS
# ============================================================================
alias tm="tmux"
alias zj="zellij --layout ~/.config/zellij/layout.kdl"

# ============================================================================
# FUN & VISUAL
# ============================================================================
alias cxx="cxxmatrix 'NodeZero-01' 'ONLINE'"
alias clk="clock-rs -c '#8bb2c9' --blink --bold --fmt '%A, %B %d, %Y'"
alias pipes="pipes.sh -t 7"
alias rdw="for i in {0..10}; do randomword; done;"

# ============================================================================
# MISC UTILITIES
# ============================================================================
alias pbpaste="xclip -selection clipboard -o"
alias ytt="youtube-tui"
alias bz="bzmenu -l walker"
alias omb="n .config/omarchy/current/theme/hyprland.conf"
alias tunnel="sudo systemctl start tunnel.service"
alias upk="uptimekit"
alias tuis="xsv table $HOME/Documents/netstuff/tui.csv"
alias rez="restic -v"
alias lvsk="lvsk-calendar"
alias px="prox"
alias cnb="cronboard"
alias sht="shuttle"
alias kway="pkill waybar && hyprctl dispatch exec waybar"
# ============================================================================
# PROJECT SPECIFIC
# ============================================================================
alias mki="for i in {1..50}; do curl -X POST -d {'agent':'scraper'} http://192.168.1.204:8000/api/increment; done;"
