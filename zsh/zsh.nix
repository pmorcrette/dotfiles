{
  pkgs,
  config,
  lib,
  ...
}:
{
  # --------------------------------------------------------------------------
  #  Outils installés de façon déclarative.
  #  -> plus besoin des gardes `command -v` de ton .zshrc : Nix garantit
  #     la présence des binaires, donc on supprime tous les `if command -v`.
  #  (bat / fzf / zoxide / starship sont installés par leurs modules ci-dessous)
  # --------------------------------------------------------------------------
  home.packages = with pkgs; [
    grc
    lazygit
    lnav
    ccze
    fd
    ripgrep
    helix
  ];

  # bat : thème (remplace export BAT_THEME)
  programs.bat = {
    enable = true;
    config.theme = "Catppuccin Frappe";
  };

  # fzf : remplace tout le bloc `source <(fzf --zsh)` + les export FZF_*.
  # La logique `if fd ... elif rg` disparaît : on installe fd, donc on fixe fd.
  programs.fzf = {
    enable = true;
    enableZshIntegration = true; # remplace `source <(fzf --zsh)`
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--info=inline"
      "--preview-window=right:60%:wrap"
    ];
    # Ctrl-T
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [
      "--preview 'bat --color=always --line-range :50 {} 2>/dev/null || cat {}'"
    ];
    # Alt-C
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'ls -la --color=always {} 2>/dev/null'"
    ];
  };

  # starship : remplace `eval "$(starship init zsh)"`
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      custom.jj = {
        command = "starship-jj --ignore-working-copy starship prompt";
        format = "[$output]($style)";
        when = "jj root"; # ou "jj root" pour ne l'afficher que dans un repo jj
        ignore_timeout = true;
      };
    };
  };

  # zoxide : remplace `eval "$(zoxide init zsh)"` + `alias cd='z'`
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ]; # cd devient zoxide (et cdi = zi)
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true; # lance compinit (remplace zicompinit/zicdreplay)
    autosuggestion.enable = true; # HM < 24.05 : enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    # HM < 24.05 : enableSyntaxHighlighting = true;
    # NB : utilise zsh-syntax-highlighting, PAS
    # fast-syntax-highlighting (voir notes plus bas)

    # fzf-tab n'a pas d'option dédiée -> plugin depuis nixpkgs.
    # (le chemin `file` peut varier selon la version de nixpkgs)
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    history = {
      path = "${config.home.homeDirectory}/.zsh_history";
      size = 1000000; # HISTSIZE
      save = 1000000; # SAVEHIST
      extended = true; # EXTENDED_HISTORY
      share = true; # SHARE_HISTORY
      ignoreAllDups = true; # HIST_IGNORE_ALL_DUPS
      ignoreSpace = true; # HIST_IGNORE_SPACE
      # HIST_REDUCE_BLANKS et HIST_VERIFY : pas d'option -> dans zsh-extra.zsh
    };

    shellAliases = {
      # éditeur
      # ls (on garde GNU ls)
      ls = "ls --color=yes";
      ll = "grc ls --color=yes -lhF";
      la = "grc ls --color=yes -lhAF";
      l = "grc ls --color=yes -CF";
      # cat -> bat
      cat = "bat";
      # grc sysadmin
      ps = "grc --colour=on ps";
      df = "grc --colour=on df";
      du = "grc --colour=on du";
      mount = "grc --colour=on mount";
      netstat = "grc --colour=on netstat";
      ping = "grc --colour=on ping";
      traceroute = "grc --colour=on traceroute";
      dig = "grc --colour=on dig";
      ip = "grc --colour=on ip";
      lsof = "grc --colour=on lsof";
      # git / lazygit
      lg = "lazygit";
      g = "git";
      gs = "git status -sb";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate -20";
      # dig
      digall = "dig -all +answer";
      digrev = "dig -all +answer -x";
      # logs
      jf = "journalctl -f | ccze -A";
      jfu = "journalctl -fu";
      logview = "lnav";
      # divers
      mkdir = "mkdir -pv";
      reload = "source ~/.zshrc";
      # 'path' a une substitution ${PATH//:/\n} -> géré dans zsh-extra.zsh
    };

    sessionVariables = {
      EDITOR = "helix"; # le `${EDITOR:-helix}` n'a pas de sens en statique
      VISUAL = "helix";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
      LESS = "-R -i -F -X --mouse";
    };

    # Tout le zsh brut sans équivalent d'option :
    # setopt restants, zstyles fzf-tab/complétion, fonctions, override local.
    # readFile => AUCUN échappement de `$` à gérer (contrairement à un bloc ''...'').
    initContent = builtins.readFile ./zsh-extra.zsh;
    # HM < 24.11 : remplace `initContent` par `initExtra`.
  };
}
