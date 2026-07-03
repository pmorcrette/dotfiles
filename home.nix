{ config, pkgs, ... }:

{
  home.username = "gyfm3853";
  home.homeDirectory = "/home/gyfm3853";
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home.stateVersion = "26.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    xreader
    bc
    cmake-language-server
    dockerfile-language-server
    docker-compose-language-service
    mesonlsp
    docker
    docker-compose
    typst
    conan
    meson
    mesonlsp
    go
    llama-cpp
    trippy 
    bandwhich 
    gping 
    doggo 
    mtr
    nmap 
    age
    sops 
    gitleaks 
    trivy 
    cosign
    mkcert
    step-cli
    dive 
    lazydocker
    gron
    dasel
    jc

    difftastic 
    git-absorb 
    koji

    procs
    dust
    duf 

    just
    act 
    gum 
    hadolint
    restic
    jq-lsp
    helm-ls
    terraform-ls
    coreutils
    gdb
    screen
    jq
    quickshell
    yq
    logseq
    fastfetch
    hevi
    elixir
    superhtml
    harlequin
    bagels
    binsider
    elixir-ls
    emacs
    ansible-lint
    yaml-language-server
    bash-language-server
    ansible
    shellcheck
    shfmt
    ripgrep
    podman
    zig
    zig-shell-completions
    zig-zlint
    zls
    nixd
    btop
    nil
    nushell
    carapace
    fzf
    tmux
    helix
    atuin
    bacon
    nix-bash-completions
    nix-doc
    git
    bat
    grc
    ccze
    lnav
    lazygit
    starship
    starship-jj
    zoxide
    delta
  ];

  home.file = {
    ".config/kitty/current-theme.conf".source = kitty/current-theme.conf;
    ".config/kitty/kitty.conf".source = kitty/kitty.conf;
  };

  home.sessionVariables = {
     EDITOR = "hx";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.difftastic = {
    enable = true;
    git.enable = true;
    options = {
      background = "dark";
      display = "side-by-side";
    };
  };
  programs.git = {
    enable = true;
    settings = {
      aliases = {
        dl = "log -p --ext-diff";
        ds = "show --ext-diff";
        rawdiff = "diff --no-ext-diff";
      };
      init.defaultBranch = "master";
      
    };
  };
  programs.helix = {
    enable = true;
    settings = {
      theme = "kanagawa";
      editor = {
        cursorline = true;
        cursorcolumn = true;
        line-number = "relative";
        statusline = {
          right = [
            "diagnostics"
            "selections"
            "register"
            "position"
            "file-encoding"
            "total-line-numbers"
          ];
        };
      };
      keys = {
        normal.space = {
          space = [
            ":write-all"
            ":sh lazygit"
            ":redraw"
            ":reload-all"
          ];
        };
      };
    };
  };

  programs.home-manager.enable = true;

}
