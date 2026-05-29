{ ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-b";          # garde ton préfixe par défaut
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;          # réactivité helix/emacs
    historyLimit = 100000;
    terminal = "tmux-256color";
    sensibleOnTop = false;   # contrôle explicite, pas de plugin caché
    extraConfig = builtins.readFile ./tmux-extra.conf;
  };
}
