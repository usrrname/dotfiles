{ config, ... }: {
  sops.secrets.hydra_password = {
    sopsFile = ./secrets/secrets.yaml;
  };

  sops.templates.netrc = {
    content = ''
      machine hydra.vital.company
          login readonly
          password ${config.sops.placeholder.hydra_password}
    '';
    path = "/etc/netrc";
    mode = "0600";
  };
}
