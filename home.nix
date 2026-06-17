{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "gyfm3853";
  home.homeDirectory = "/home/gyfm3853";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    xreader
    bc
    cmake-language-server
    dockerfile-language-server
    docker-compose-language-service
    mesonlsp
    typst
    llama-cpp
    # --- Réseau / diag (tu n'as que dig/ping/traceroute wrappés grc) ---
    trippy # binaire: trip — mtr en bien mieux, TUI live
    bandwhich # quel *process* consomme la bande passante
    gping # ping avec graphe temps réel
    doggo # dig moderne, lisible
    mtr
    nmap # les références, absentes du kit

    # --- Sécu / secrets / supply-chain ( "sécu" mais rien ici) ---
    age
    sops # chiffrement moderne + secrets in-repo
    gitleaks # scan de secrets (pre-commit / CI)
    trivy # vulns : images, fs, IaC, SBOM
    cosign # signature d'artefacts (Sigstore)
    mkcert # certs HTTPS de confiance en local
    step-cli # couteau suisse PKI

    # --- Conteneurs (tu as podman, pas l'outillage) ---
    dive # inspection des couches d'image
    lazydocker # TUI conteneurs (marche avec podman)
    kubectl
    k9s
    stern
    kubectx # seulement si tu touches du k8s

    # --- Données (complète jq/yq/harlequin) ---
    gron # JSON grep-able puis reconstructible
    dasel # query/edit json/yaml/toml/xml, une seule syntaxe
    jc # sortie des commandes unix -> JSON

    # --- Git (au-delà de lazygit/delta/jj) ---
    difftastic # binaire: difft — diff structurel syntaxe-aware
    git-absorb # fixup! automatique sur les bons commits
    koji

    # --- Système (complète btop/lnav) ---
    procs
    dust
    duf # binaires: procs / dust / duf

    # --- Devops & scripting ---
    just # task runner type make, lisible
    act # exécute tes GitHub Actions en local
    gum # composants interactifs pour tes scripts
    hadolint # linter Dockerfile (tu as le LSP, pas le linter)
    restic # sauvegardes chiffrées dédupliquées
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
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".config/kitty/current-theme.conf".source = kitty/current-theme.conf;
    ".config/kitty/kitty.conf".source = kitty/kitty.conf;
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/gyfm3853/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
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
        # forcer difft aussi sur log/show (qui n'utilisent pas diff.external par défaut)
        dl = "log -p --ext-diff";
        ds = "show --ext-diff";
        # repli ponctuel sur le diff unifié classique
        rawdiff = "diff --no-ext-diff";
      };
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
