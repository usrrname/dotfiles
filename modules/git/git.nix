{
  lib,
  pkgs,
  ...
}: {
  # File-based git config: the .gitconfig files in this directory are the
  # source of truth, deployed as-is (no Nix-generated settings). git itself
  # comes from the shared home.packages in home/default.nix.
  home.file.".gitconfig".source = ./.gitconfig;

  # mac-only ssh signing + credential helpers. git reads ~/.config/git/config
  # before ~/.gitconfig; the key sets don't overlap, so precedence is moot.
  home.file."config/git/config" = lib.mkIf pkgs.stdenv.isDarwin {
    source = ./.gitconfig-mac;
  };
}
