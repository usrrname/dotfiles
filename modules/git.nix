{
  config,
  lib,
  pkgs,
  ...
}:
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Jen Chan";
        email = "6406037+usrrname@users.noreply.github.com";
        signingkey = "~/.ssh/id_ed25519.pub";
      };
      color.ui = "auto";
      core.editor = "nvim";
      core.excludesFile = "~/.gitignore_global";
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
      pull.rebase = true;
      alias = {
        g = "git";
        gco = "checkout";
        gst = "status";
        gcb = "checkout -b";
        gcm = "commit -m";
        noedit = "commit --amend --no-edit";
        log = "log --pretty=format:\"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]\" --decorate";
        assume = "update-index --assume-unchanged";
        assumed = "!git ls-files -v | grep ^h | cut -c 3-";
        unassume = "update-index --no-assume-unchanged";
        unassumeall = "!git assumed | xargs git update-index --no-assume-unchanged";
        alias = "!git config -l | grep alias | cut -c 7-";
      };
    } // lib.optionalAttrs isDarwin {
      gpg.format = "ssh";
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      commit.gpgsign = true;
      credential."https://github.com".helper = [ "" "!/opt/homebrew/bin/gh auth git-credential" ];
      credential."https://gist.github.com".helper = [ "" "!/opt/homebrew/bin/gh auth git-credential" ];
    };
  };
}
