# emacs/emacs.nix — Emacs recentré : magit + org-roam, bindings vanilla.
# À importer depuis home.nix :  imports = [ ./emacs/emacs.nix ];
# ⚠ Retirez `emacs` de home.packages pour éviter une collision de binaires.
{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs; # emacs30-pgtk si session Wayland native
    extraPackages = epkgs: with epkgs; [
      # Thème
      catppuccin-theme

      # Minibuffer façon fzf
      vertico
      orderless
      marginalia
      consult
      embark
      embark-consult

      # Complétion dans le buffer
      corfu
      corfu-terminal # rend corfu utilisable dans emacsclient -t

      # Les deux raisons d'être de ce setup
      magit
      org-roam

      # Langages — les modes tree-sitter d'Emacs 30 couvrent déjà
      # bash, c, c++, c#, cmake, css, dockerfile, elixir, go, html,
      # java, js/ts/tsx, json, lua, php, python, ruby, rust, toml, yaml.
      # Ci-dessous, les majors modes externes pour le reste de la liste Helix.
      clojure-mode
      crystal-mode
      d-mode
      dart-mode
      dhall-mode
      elm-mode
      erlang
      fish-mode
      fsharp-mode
      gleam-ts-mode
      glsl-mode
      graphql-mode
      haskell-mode
      jsonnet-mode
      julia-mode
      just-mode
      kotlin-mode
      markdown-mode
      meson-mode
      nim-mode
      nix-ts-mode
      protobuf-mode
      racket-mode
      scala-mode
      solidity-mode
      svelte-mode
      swift-mode
      terraform-mode
      tuareg # OCaml
      typst-ts-mode
      web-mode # templates : vue, twig, jinja…
      zig-mode
      treesit-grammars.with-all-grammars
    ];
  };

  # Démon systemd : les popups `emacsclient -t` s'ouvrent instantanément.
  services.emacs = {
    enable = true;
    client.enable = true;
    # Pas de defaultEditor : $EDITOR reste hx.
  };
  systemd.user.services.emacs.Service = {
    Type = pkgs.lib.mkForce "forking";
    ExecStart = pkgs.lib.mkForce "${pkgs.emacs30}/bin/emacs --daemon";
  };

  xdg.configFile."emacs/early-init.el".source = ./early-init.el;
  xdg.configFile."emacs/init.el".source = ./init.el;
}
