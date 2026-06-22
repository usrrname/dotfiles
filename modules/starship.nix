{
  # Configuration written to ~/.config/starship.toml
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      gcloud.disabled = true;

      direnv.enable = true;
      
      memory_usage = {
        disabled = false;
        threshold = 0;
        format = "RAM: [$ram_pct]($style) | SWAP: [$swap_pct]($style) ";
        style = "bold yellow";
      };

     };
  };
}
