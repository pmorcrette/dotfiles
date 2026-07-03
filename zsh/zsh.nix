{
  pkgs,
  config,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    grc
    lazygit
    lnav
    ccze
    fd
    ripgrep
    helix
    zsh-forgit
    zsh-fzf-tab
  ];

  programs.bat = {
    enable = true;
    config.theme = "Catppuccin Frappe";
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true; 
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--info=inline"
      "--preview-window=right:60%:wrap"
    ];
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [
      "--preview 'bat --color=always --line-range :50 {} 2>/dev/null || cat {}'"
    ];
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'ls -la --color=always {} 2>/dev/null'"
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      custom.jj = {
        command = "starship-jj --ignore-working-copy starship prompt";
        format = "[$output]($style)";
        when = "jj root"; 
        ignore_timeout = true;
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true; 
    autosuggestion.enable = true; 
    syntaxHighlighting.enable = true;
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      {
        name = "forgit";
        src = pkgs.zsh-forgit;
        file = "share/zsh/site-functions/_git-forgit";
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
    };

    shellAliases = {
      ls = "ls --color=yes";
      ll = "grc ls --color=yes -lhF";
      la = "grc ls --color=yes -lhAF";
      l = "grc ls --color=yes -CF";
      cat = "bat";
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
      lg = "lazygit";
      g = "git";
      gs = "git status -sb";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate -20";
      d = "dig +noall +answer";
      dx = "dig +noall +answer -x";
      jf = "journalctl -f | ccze -A";
      jfu = "journalctl -fu";
      logview = "lnav";
      mkdir = "mkdir -pv";
      reload = "source ~/.zshrc";
    };

    sessionVariables = {
      EDITOR = "hx"; 
      VISUAL = "hx";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
      LESS = "-R -i -F -X --mouse";
      TERM = "xterm-256color";
    };

    initContent = builtins.readFile ./zsh-extra.zsh;
  };
}
