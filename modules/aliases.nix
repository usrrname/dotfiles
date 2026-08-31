{...}: {
  # Aliases that work identically in bash and zsh.
  # Shell-specific aliases (reload, package-manager wrappers, etc.)
  # stay in modules/bash/.bash_aliases and modules/zsh/zsh.nix.
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
    py = "python3";
    pip = "pip3";
  };
}
