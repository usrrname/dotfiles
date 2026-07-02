# Raspberry Pi 4B NAS host configuration
# Standalone Home Manager configuration for Debian on Raspberry Pi

{ config, pkgs, lib, ... }:

let
  username = let user = builtins.getEnv "USER"; in if user == "" then "jenc" else user;
  homeDir = "/home/${username}";
in
{
  imports = [
    ../../home
    ../../home/linux.nix
  ];

  # Allow unfree packages (required for 1password-cli, etc.)
  nixpkgs.config.allowUnfree = true;

  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

  # Pi-specific packages (NAS setup)
  # Note: Most packages come from ../../home/default.nix
  # Only add Pi-specific extras here
  home.packages = with pkgs; [
    # Pi-specific additions
    lsb-release
    opencode
    cowsay
    lolcat
  ];

  # System-level packages (install via apt on Debian):
  # sudo apt install ufw fail2ban hd-idle
  # These require root and system-level configuration, so they're managed outside Nix

  # Docker is managed at system level on Pi (requires root)
  # Install via: curl -fsSL https://get.docker.com | sh
  # Then add user to docker group: sudo usermod -aG docker $USER

  # Pi login banner — IPs via dragon cowsay
  home.file.".bash_login".text = ''
    # Pi-NAS network info — shown on SSH login
    for iface in eth0 docker0 tailscale0; do
      ip=$(ip -4 addr show "$iface" 2>/dev/null | sed -n 's/.*inet \([0-9.]*\).*/\1/p')
      [ -n "$ip" ] && echo "$iface: $ip"
    done | ${pkgs.cowsay}/bin/cowsay -f dragon | ${pkgs.lolcat}/bin/lolcat
  '';

  # Ensure .bash_login is sourced from the Home Manager-managed .bash_profile
  programs.bash.profileExtra = ''
    [[ -f ~/.bash_login ]] && . ~/.bash_login
  '';

  # Pi-specific shell aliases
  programs.zsh.shellAliases = {
    xoff = "sudo /usr/local/bin/xSoft.sh 0 27"; # Pi NAS soft shutdown
  };

  # Managed services

  systemd.user.services.syncthing = {
    Unit = {
      Description = "Syncthing - Open Source Continuous File Synchronization";
      After = [ "mnt-nas.mount" ];
      Requires = [ "mnt-nas.mount" ];
    };
    Service = {
      ExecStart = "/usr/bin/syncthing serve --home=/mnt/nas/syncthing --no-browser --no-restart";
      Restart = "on-failure";
      RestartSec = "1";
      SuccessExitStatus = [ "3" "4" ];
      RestartForceExitStatus = [ "3" "4" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  programs.home-manager.enable = true;
}
