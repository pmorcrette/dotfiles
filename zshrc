# ============================================================================
#  ~/.zshrc
#  Stack : Zinit + Starship + fzf + zoxide + outils modernes
#  Cible : démarrage < 100ms, fonctionnalités complètes via lazy-loading
# ============================================================================

# ----------------------------------------------------------------------------
#  1. Options zsh et historique  (en premier, avant tout le reste)
# ----------------------------------------------------------------------------

# Historique : large, partagé entre sessions, dédoublonné
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000

setopt EXTENDED_HISTORY          # timestamp dans l'historique
setopt SHARE_HISTORY             # partage entre sessions ouvertes
setopt HIST_IGNORE_ALL_DUPS      # pas de doublons
setopt HIST_IGNORE_SPACE         # commandes préfixées d'un espace = privées
setopt HIST_REDUCE_BLANKS        # nettoie les espaces superflus
setopt HIST_VERIFY               # !! et !$ demandent confirmation

# Navigation
setopt AUTO_PUSHD                # cd push automatiquement sur la pile
setopt PUSHD_IGNORE_DUPS         # pas de doublons dans la pile
setopt PUSHD_SILENT              # silencieux

# Globbing et complétion
setopt EXTENDED_GLOB             # patterns avancés (^, ~, #)
setopt NO_CASE_GLOB              # globbing insensible à la casse
setopt NUMERIC_GLOB_SORT         # tri numérique naturel

# Confort
setopt INTERACTIVE_COMMENTS      # # en interactif autorisés
setopt NO_BEEP                   # silence

# ----------------------------------------------------------------------------
#  2. Zinit  (gestionnaire de plugins)
# ----------------------------------------------------------------------------

# Installation auto si absent
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# ----------------------------------------------------------------------------
#  3. Plugins  (turbo mode : chargés après l'apparition du prompt)
# ----------------------------------------------------------------------------

# fzf-tab : doit être chargé avant syntax-highlighting et autosuggestions
zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
        Aloxaf/fzf-tab \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    zdharma-continuum/fast-syntax-highlighting

# Config fzf-tab : preview avec bat / eza selon le contexte
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --line-range :40 $realpath 2>/dev/null || ls -la $realpath'
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':completion:*' menu no   # requis par fzf-tab

# Config autosuggestions : couleur discrète, stratégie historique
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#666666'

# ----------------------------------------------------------------------------
#  4. fzf  (bindings Ctrl+R, Ctrl+T, Alt+C)
# ----------------------------------------------------------------------------

if command -v fzf >/dev/null 2>&1; then
    # fzf >= 0.48
    source <(fzf --zsh) 2>/dev/null

    export FZF_DEFAULT_OPTS="
        --height 40%
        --layout=reverse
        --border
        --info=inline
        --preview-window=right:60%:wrap
    "

    # Si fd installé, l'utiliser ; sinon ripgrep ; sinon find
    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    elif command -v rg >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi

    # Previews : bat pour fichiers, arborescence pour dossiers
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {} 2>/dev/null || cat {}'"
    export FZF_ALT_C_OPTS="--preview 'ls -la --color=always {} 2>/dev/null'"
fi

# ----------------------------------------------------------------------------
#  5. Starship  (prompt)
# ----------------------------------------------------------------------------

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# ----------------------------------------------------------------------------
#  6. zoxide  (cd intelligent — z et zi)
# ----------------------------------------------------------------------------

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
    # Optionnel : remplacer cd par z (z apprend tes répertoires fréquents)
    alias cd='z'
fi

# ----------------------------------------------------------------------------
#  7. Variables d'environnement pour les outils
# ----------------------------------------------------------------------------

# Editeur par défaut
alias hx=helix
export EDITOR="${EDITOR:-helix}"
export VISUAL="$EDITOR"

# bat : thème + pager pour man
if command -v bat >/dev/null 2>&1; then
    export BAT_THEME="Catppuccin Frappe"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"   # corrige les caractères mal rendus dans man
fi

# less : couleurs ANSI préservées
export LESS='-R -i -F -X --mouse'

# ----------------------------------------------------------------------------
#  8. Alias  (outils modernes EN COMPLÉMENT, pas en remplacement)
# ----------------------------------------------------------------------------

# --- ls : on garde GNU ls (pour -Z, -o, -g, scripts SELinux) ---
# alias dédiés pour le confort, sans toucher à ls
alias ls='ls --color=yes'
alias ll='grc ls --color=yes -lhF'
alias la='grc ls --color=yes -lhAF'
alias l='grc ls --color=yes -CF'

# bat : remplaçant safe de cat pour usage interactif
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

# ripgrep : pas d'alias sur grep (scripts), accès via rg direct
# fd : pareil, accès direct

# Colorisation grc des outils sysadmin (préserve toutes les options)
if command -v grc >/dev/null 2>&1; then
    alias ps='grc --colour=auto ps'
    alias df='grc --colour=auto df'
    alias du='grc --colour=auto du'
    alias mount='grc --colour=auto mount'
    alias netstat='grc --colour=auto netstat'
    alias ping='grc --colour=auto ping'
    alias traceroute='grc --colour=auto traceroute'
    alias dig='grc --colour=auto dig'
    alias ip='grc --colour=auto ip'
    alias lsof='grc --colour=auto lsof'
fi

# Git via lazygit pour les actions, alias courts pour le reste
alias lg='lazygit'
alias g='git'
alias gs='git status -sb'
alias gd='git diff'      # passera dans delta via gitconfig
alias gl='git log --oneline --graph --decorate -20'

# Alias dig pour tes usages spécifiques
alias digall='dig -all +answer'
alias digrev='dig -all +answer -x'

# Logs : ccze pour le streaming, lnav pour l'investigation
alias jf='journalctl -f | ccze -A'
alias jfu='journalctl -fu'   # usage : jfu monservice | ccze -A
alias logview='lnav'

# Confort divers
alias mkdir='mkdir -pv'
alias path='echo -e ${PATH//:/\\n}'
alias reload='source ~/.zshrc'

# ----------------------------------------------------------------------------
#  9. Fonctions custom
# ----------------------------------------------------------------------------

# Recherche fuzzy d'un PID
pid() {
    ps -eF | fzf --ansi --header-lines=1 --height=60% | awk '{print $2}'
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

# Recherche dans le contenu des fichiers avec preview interactif
rgf() {
    rg --color=always --line-number --no-heading --smart-case "${*:-}" |
        fzf --ansi \
            --delimiter=: \
            --preview 'bat --color=always --highlight-line {2} {1}' \
            --preview-window 'right:60%:+{2}+3/2'
}

# ----------------------------------------------------------------------------
#  10. Complétion zsh
# ----------------------------------------------------------------------------

# Insensible à la casse, smart-case
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:warnings' format 'Aucune complétion pour : %d'

# ----------------------------------------------------------------------------
#  11. Local overrides
# ----------------------------------------------------------------------------

# Charge un .zshrc.local si présent (secrets, alias machine-spécifiques)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
