{ ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-b";          
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;          
    historyLimit = 100000;
    terminal = "tmux-256color";
    sensibleOnTop = false;   
    extraConfig = builtins.readFile ./tmux-extra.conf;
  };
}
