alias rm='trash-put'
alias zshconfig='nvim ~/.zshrc'
alias zshconfigok='source ~/.zshrc'
alias defaultapps='sudo -E nvim ~/.config/mimeapps.list'
alias tclup='sudo tailscale up'
alias tcldn='sudo tailscale down'
alias tcls='tailscale status'
alias aliases='grep alias ~/.zshrc'
alias tshs='find . -maxdepth 1 -print0 | fzf -m --read0 | xargs -0 trash-put'
alias kittyconf='nvim ~/.config/kitty/kitty.conf'
alias pyinit='~/Documents/scripts/pyinit.sh'
alias pypy='pypy3.10'
alias re='exec zsh'
alias temuxconf='nvim ~/.tmux.conf.local'
alias archvm='~/Documents/scripts/archvm.sh'
alias win10vm='~/Documents/scripts/win10vm.sh'
alias gitst='git status -uno'
alias start-ai="~/Documents/scripts/start-ai.sh"
alias stop-ai="~/Documents/scripts/stop-ai.sh"

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

n() {
  tmpfile="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
  mkdir -p "$(dirname "$tmpfile")"
  NNN_TMPFILE="$tmpfile" command nnn "$@"
  if [[ -f "$tmpfile" ]]; then
    dir=$(<"$tmpfile")
    [[ -d "$dir" ]] && eval "cd \"$dir\""
    rm -f "$tmpfile"
  fi
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
    "new" | *)
      # New session with unique name
      tmux new-session -s "TERM_$(date +%H%M%S)"
      ;;
  esac
  exit
fi
