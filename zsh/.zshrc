# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"
export EDITOR="/usr/bin/nvim"

ZSH_THEME="agnosterzak"

plugins=( 
    gitxargs -I {} tmux kill-session -t {}'
    dnf
    zsh-autosuggestions
    zsh-syntax-highlighting
    copypath
    extract
)

source $ZSH/oh-my-zsh.sh

# check the dnf plugins commands here
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dnf


# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r #without fastfetch
#pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
# fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=400
SAVEHIST=400
setopt appendhistory

# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# Custom
eval "$(zoxide init zsh)"

export PATH="$HOME/.local/bin:$PATH"

alias 'rm -rf'='trash-put'
alias zshconfig='nvim ~/.zshrc'
alias zshconfigok='source ~/.zshrc'
alias defaultapps='sudo nvim ~/.config/mimeapps.list'
alias tclup='sudo tailscale up'
alias tcldn='sudo tailscale down'
alias tcls='tailscale status'
alias ff/='sudo find / -type f'
alias fd/='sudo find / -type d'
alias aliases='grep alias ~/.zshrc'
alias tshs='find . -maxdepth 1 -type f | fzf -m | xargs trash-put'
alias kittyconf='nvim ~/.config/kitty/kitty.conf'
alias pyinit='~/Documents/scripts/pyinit.sh'
alias pypy='pypy3.10'
alias timgview='kitty +kitten icat'
alias html='~/Documents/scripts/html5.sh'
alias re='exec zsh'
alias temuxconf='nvim ~/.tmux.conf.local'

# Custom functions
xt() {
  find . -maxdepth 1 -type f -name "*.zip" | fzf -m | while IFS= read -r archive; do
    dirname="${archive%.*}"
    mkdir -p "$dirname"
    7z x "$archive" -o"$dirname" -y
  done
}

r() {
  ranger --choosedir=$HOME/.rangerdir "${@:-$PWD}"
  if [ -f "$HOME/.rangerdir" ]; then
    cd "$(cat $HOME/.rangerdir)"
  fi
}

tmuxkm() {
    if ! tmux list-sessions &>/dev/null; then
        echo "No session active found."
        return 1
    fi
    
    local sessions=$(tmux list-sessions -F '#S' | \
        fzf --multi \
            --prompt="Select sessions to kill: " \
            --height=40% \
            --border \
            --preview='tmux list-windows -t {} -F "  Window {}: #{window_name}"' \
            --preview-window=right:50%)
    
    if [[ -z "$sessions" ]]; then
        echo "Cancelled - No sessions selected."
        return 0
    fi
    
    echo "Sessions to kill:"
    echo "$sessions" | sed 's/^/  - /'
    echo
    
    read -p "Confirm your choice? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Killed."
        return 0
    fi
    
    local count=0
    while IFS= read -r session; do
        if tmux kill-session -t "$session" 2>/dev/null; then
            echo "Session '$session' killed"
            ((count++))
        else
            echo "Couldn't kill the session '$session'"
        fi
    done <<< "$sessions"
    
    echo
    echo "Total: $count sessions killed."
}

# Custom init commands
export TMUX_MODE=new
if [ -z "$TMUX" ]; then
  case "${TMUX_MODE:-new}" in
    "shared")
      tmux attach -t shared || tmux new -s shared
      ;;
    "reuse")
      tmux attach || tmux new-session
      ;;
    "new"|*)
      # New session with unique name
      tmux new-session -s "TERM_$(date +%H%M%S)"
      ;;
  esac
  exit
fi
