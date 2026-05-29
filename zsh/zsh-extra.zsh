# ============================================================================
#  zsh-extra.zsh — chargé par programs.zsh.initContent (builtins.readFile)
#  Tout ce qui n'a pas d'option home-manager dédiée. zsh brut, zéro échappement.
# ============================================================================

# --- setopt sans option home-manager dédiée ---------------------------------
setopt HIST_REDUCE_BLANKS        # nettoie les espaces superflus
setopt HIST_VERIFY               # !! et !$ demandent confirmation
setopt AUTO_PUSHD                # cd push automatiquement sur la pile
setopt PUSHD_IGNORE_DUPS         # pas de doublons dans la pile
setopt PUSHD_SILENT              # silencieux
setopt EXTENDED_GLOB             # patterns avancés (^, ~, #)
setopt NO_CASE_GLOB              # globbing insensible à la casse
setopt NUMERIC_GLOB_SORT         # tri numérique naturel
setopt INTERACTIVE_COMMENTS      # # en interactif autorisés
setopt NO_BEEP                   # silence

# --- fzf-tab : configuration (le plugin est chargé via programs.zsh.plugins) -
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --line-range :40 $realpath 2>/dev/null || ls -la $realpath'
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':completion:*' menu no   # requis par fzf-tab

# --- autosuggestions : réglages ---------------------------------------------
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#666666'

# --- alias 'path' (substitution ${PATH//:/\n} incompatible avec shellAliases)-
alias path='echo -e ${PATH//:/\n}'

# --- complétion zsh ---------------------------------------------------------
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:warnings' format 'Aucune complétion pour : %d'

# ============================================================================
#  Fonctions custom
# ============================================================================

# Recherche fuzzy d'un PID
pid() {
    grc --colour=on ps -eF | fzf --ansi --header-lines=1 --height=60% | awk '{print $2}'
}

# Kill fuzzy
fkill() {
    local pid
    pid=$(ps -eF | fzf --ansi --header-lines=1 --multi --height=60% | awk '{print $2}')
    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs kill -${1:-15}
    fi
}

# Recherche fuzzy dans l'historique avec exécution
fh() {
    print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' )
}

# cd vers un dossier trouvé en fuzzy (avec preview)
fcd() {
    local dir
    dir=$(fd --type d --hidden --exclude .git 2>/dev/null | fzf --preview 'ls -la --color=always {}') && cd "$dir"
}

# Extract universel
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

source <(carapace _carapace zsh)
# ============================================================================
#  Override local (secrets / alias machine-spécifiques, hors dépôt Nix)
# ============================================================================
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
