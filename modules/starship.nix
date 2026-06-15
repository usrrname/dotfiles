{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      gcloud.disabled = true;
      directory.truncation_length = 3;

      memory_usage = {
        disabled = false;
        threshold = 0;
        format = "RAM: [$ram_pct]($style) | SWAP: [$swap_pct]($style) ";
        style = "bold yellow";
      };

      disk_usage = {
        disabled = false;
        mount_points = ["/"];
        show_always = true;
        format = "on [$used: $total]($style) ";
        style = "bold cyan";
      };
    };
  };
}
