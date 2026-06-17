{ config, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Point ~/.config/nvim at the live repo rather than copying it into the
  # read-only Nix store. LazyVim needs to WRITE lazy-lock.json on
  # :Lazy sync/update/install, which fails with "Permission denied" when the
  # dir is a read-only store symlink. An out-of-store symlink also makes
  # .lua edits take effect on reload without a home-manager rebuild.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/common/nvim/.config/nvim";
}
