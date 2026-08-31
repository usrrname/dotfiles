{
  # Config is authored as raw TOML in ../common/starship/.config/starship.toml
  # and deployed verbatim below (same pattern as ghostty/wezterm). `settings`
  # is left empty so Home Manager doesn't generate its own config file, which
  # would collide with the xdg.configFile definition.
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile."starship.toml".source = .config/starship.toml;
}
