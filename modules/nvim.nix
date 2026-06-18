{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.neovim ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Point ~/.config/nvim at the live repo rather than copying it into the
  # read-only Nix store. LazyVim needs to WRITE lazy-lock.json on
  # :Lazy sync/update/install, which fails with "Permission denied" when the
  # dir is a read-only store symlink. An out-of-store symlink also makes
  # .lua edits take effect on reload without a home-manager rebuild.
  #
  # Using home.activation instead of mkOutOfStoreSymlink because recent
  # Home Manager versions (26.11-pre) reject out-of-store symlinks in the
  # build sandbox with "Error installing file outside $HOME".
  home.activation.linkNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="${config.xdg.configHome}/nvim"
    source="${config.home.homeDirectory}/.dotfiles/common/nvim/.config/nvim"
    
    if [ -L "$target" ]; then
      rm "$target"
    elif [ -d "$target" ]; then
      # Remove directory if it only contains store symlinks (from failed builds)
      if [ -z "$(ls -A "$target" 2>/dev/null | grep -v '^\.\+$')" ] || \
         find "$target" -type l -exec readlink {} \; | grep -q '/nix/store/'; then
        rm -rf "$target"
      else
        echo "Warning: $target exists with user files. Skipping."
        exit 0
      fi
    fi
    
    ln -s "$source" "$target"
  '';
}
