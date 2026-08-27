{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      # Enable extended keys for CSI-u support
      set -g extended-keys on
      # Use CSI-u format for extended keys
      set -g extended-keys-format csi-u
      # Allow passthrough for nested apps (e.g. nvim OSC52)
      set -gq allow-passthrough on
      # Sync tmux clipboard with system clipboard
      set -g set-clipboard on
      # Enable mouse support
      set -g mouse on
      # Start window numbering at 1
      set -g base-index 1
      # Split pane horizontally with |
      bind | split-window -h
    '';
  };
}
