{ config, pkgs, lib, ... }:

let
  # Detect the operating system
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  # User information
  home.username = "jenc";
  home.homeDirectory = if isDarwin then "/Users/jenc" else "/home/jenc";
  home.stateVersion = "24.11";

  # Packages to install
  home.packages = with pkgs; [
    # === Core CLI Tools (all platforms) ===
    git
    curl
    wget
    tree
    ripgrep
    fzf
    stow
    tmux
    
    # === Editors ===
    neovim
    vim
    
    # === Development Tools ===
    direnv
    gh                    # GitHub CLI
    
    # === Build Tools ===
    gnumake
    gcc                   # Provides build tools on both platforms
    openssl
    
    # === Shell Enhancements ===
    zsh
    oh-my-zsh
    starship              # Cross-shell prompt
    
    # === Programming Languages ===
    go
    fnm
    
    # === Additional Tools ===
    gnupg
    ca-certificates
  ] ++ lib.optionals isLinux [
    # === Linux-specific packages ===
    lsb-release
  ] ++ lib.optionals isDarwin [
    # === macOS-specific packages (if needed) ===
    # Most GUI apps should stay in Brewfile
  ];

  # === Program Configurations ===
  
  # Let Home Manager manage itself
  programs.home-manager.enable = true;
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = "jenc";
    # userEmail = "your.email@example.com";  # Add your email
  };

  # Vim configuration
  programs.vim = {
    enable = true;
    extraConfig = ''
      " enable modern features
      set nocompatible

      " arrow keys should work in insert mode
      inoremap <Up> <C-o>k
      inoremap <Down> <C-o>j
      inoremap <Left> <C-o>h
      inoremap <Right> <C-o>l
      " map command s to save file
      imap <D-s> <Esc>:w<CR>a
    '';
  };

  # SSH configuration
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Include ~/.orbstack/ssh/config

      Host *
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

      Host sink
        Hostname 192.168.68.50
        User netserv
        IdentityFile "~/.ssh/netserv SSH Key.pub"
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        IdentitiesOnly yes

      Host node05.din.gy
        HostName fulton.din.gy
        Port 8025
        ForwardAgent yes
        User jenc

      Host paddington.io
        AddKeysToAgent yes
        UseKeychain yes
        IdentityFile "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
  };
  
  # Zsh configuration (complements your existing .zshrc)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "direnv" "gh" ];
      theme = "robbyrussell";
    };
    initExtra = ''
      alias vi='nvim'
      alias vim='nvim'
    '';
  };
  
  # Direnv integration
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  
  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  
  # fzf integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # === Environment Variables ===
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Add Homebrew to PATH on macOS
  home.sessionPath = lib.optionals isDarwin [ "/opt/homebrew/bin" ];

  # === File Management ===
  # Wezterm config (Lua file)
  xdg.configFile."wezterm/wezterm.lua".source = ../../../wezterm/.wezterm.lua;
  # home.file.".config/some-app/config".source = ./some-config-file;
}