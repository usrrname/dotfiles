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
    # Note: Use mise/fnm for Node.js version management
    # Note: Use rustup for Rust (not in nixpkgs directly)
    
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

  # === File Management ===
  # You can symlink specific files if needed
  # home.file.".config/some-app/config".source = ./some-config-file;
}
