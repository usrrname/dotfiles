{ config, ... }: {
  sops.secrets.hydra_password = {
    sopsFile = ./secrets/secrets.yaml;
  };

  environment.etc."netrc" = {
    text = ''
      machine hydra.vital.company
          login readonly
          password ${builtins.readFile config.sops.secrets.hydra_password.path}
    '';
    mode = "0600";
  };
}
