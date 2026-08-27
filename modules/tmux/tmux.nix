{
  pkgs,
  ...
}: {
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    escapeTime = 0;
    plugins = with pkgs.tmuxPlugins; [ vim-tmux-navigator ];
    extraConfig = builtins.readFile ./tmux.conf;
  };
}
