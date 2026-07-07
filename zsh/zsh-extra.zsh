setopt HIST_REDUCE_BLANKS        
setopt HIST_VERIFY
setopt AUTO_PUSHD                
setopt PUSHD_IGNORE_DUPS         
setopt PUSHD_SILENT              
setopt EXTENDED_GLOB             
setopt NO_CASE_GLOB              
setopt NUMERIC_GLOB_SORT         
setopt INTERACTIVE_COMMENTS      
setopt NO_BEEP
bindkey -e
bindkey "^[[3~" delete-char
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --line-range :40 $realpath 2>/dev/null || ls -la $realpath'
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':completion:*' menu no   # requis par fzf-tab

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#666666'

alias path='echo -e ${PATH//:/\n}'

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:warnings' format 'Aucune complétion pour : %d'

pid() {
    grc --colour=on ps -eF | fzf --ansi --header-lines=1 --height=60% | awk '{print $2}'
}

fkill() {
    local pid
    pid=$(ps -eF | fzf --ansi --header-lines=1 --multi --height=60% | awk '{print $2}')
    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs kill -${1:-15}
    fi
}

fh() {
    print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' )
}

fcd() {
    local dir
    dir=$(fd --type d --hidden --exclude .git 2>/dev/null | fzf --preview 'ls -la --color=always {}') && cd "$dir"
}

extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)  tar xjf "$1"   ;;
            *.tar.gz)   tar xzf "$1"   ;;
            *.tar.xz)   tar xJf "$1"   ;;
            *.bz2)      bunzip2 "$1"   ;;
            *.rar)      unrar x "$1"   ;;
            *.gz)       gunzip "$1"    ;;
            *.tar)      tar xf "$1"    ;;
            *.tbz2)     tar xjf "$1"   ;;
            *.tgz)      tar xzf "$1"   ;;
            *.zip)      unzip "$1"     ;;
            *.Z)        uncompress "$1";;
            *.7z)       7z x "$1"      ;;
            *)          echo "Format non géré: $1" ;;
        esac
    else
        echo "Fichier introuvable: $1"
    fi
}

rgf() {
  local file line
  IFS=: read -r file line _ < <(
    rg --color=always --line-number --no-heading --smart-case "${*:-}" |
      fzf --ansi --delimiter=: \
          --preview 'bat --color=always --highlight-line {2} {1}' \
          --preview-window 'right:60%:+{2}+3/2'
  )
  [[ -n "$file" ]] && hx "$file:$line"
}

if (( $+commands[carapace] )); then
  source <(carapace _carapace zsh)
fi
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
