{ config, lib, pkgs, ... }:
let
  # OS detection based on system hostname and home username
  isFedora = pkgs.stdenv.isLinux && (
    (config ? system.nixos.hostName && (
      config.system.nixos.hostName == "fedora-mini" ||
      config.system.nixos.hostName == "fedora" ||
      config.system.nixos.hostName == "fedora-desktop"
    )) ||
    (config ? home && (
      config.home.username == "jenc" ||
      config.home.username == "user"
    ))
  );
  isDebianLike = pkgs.stdenv.isLinux && !isFedora;
  
  # Base aliases that work everywhere
  baseAliases = {
    ll = "ls -alF";
    la = "ls -A";
    l = "ls -CF";
    g = "git";
    vi = "nvim";
    nvim = "nvim";
    sudov = "sudo -e";
    py = "python3";
    pip = "pip3";
    "docker-compose" = "docker compose";
    k = "kubectl";
    copilot = "gh copilot";
    cc = "claude code";
    reload = "source ~/.bashrc";
  };
  
  # OS-specific package manager aliases
  osSpecificAliases = {
    update = if isFedora 
      then "sudo dnf update && sudo dnf upgrade" 
      else "sudo apt update && sudo apt upgrade";
    install = if isFedora 
      then "sudo dnf install" 
      else "sudo apt install";
    remove = if isFedora 
      then "sudo dnf remove" 
      else "sudo apt remove";
    autoremove = if isFedora 
      then "sudo dnf autoremove" 
      else "sudo apt autoremove";
    search = if isFedora 
      then "sudo dnf search" 
      else "sudo apt search";
  };
in
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    
    bashrcExtra = ''
      # If not running interactively, don't do anything
      case $- in
        *i*) ;;
        *) return ;;
      esac
    '';
    
    initExtra = ''
      # History settings
      HISTCONTROL=ignoreboth
      shopt -s histappend
      HISTSIZE=1000
      HISTFILESIZE=2000
      shopt -s checkwinsize
      
      # Colored output
      export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
      
      # PATH additions
      export PATH="$HOME/.local/bin:$PATH"
      
      # Functions
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }
      
      extract() {
        if [ -f "$1" ]; then
          case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unrar e "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }
    '';
    
    shellAliases = baseAliases // osSpecificAliases;
    
    shellOptions = [
      "histappend"
      "checkwinsize"
    ];
  };
}
