{...}: {
  # Aliases that work identically in bash and zsh.
  # Shell-specific aliases (reload, package-manager wrappers, etc.)
  # stay in modules/bash.nix and modules/zsh.nix.
  base = {
    ll = "ls -alF";
    la = "ls -A";
    l = "ls -CF";
    g = "git";
    vi = "nvim";
    vim = "nvim";
    sudov = "sudo -e";
    "docker-compose" = "docker compose";
    k = "kubectl";
  };
}
