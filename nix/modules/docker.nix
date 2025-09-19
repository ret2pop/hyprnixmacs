{ lib, config, vars, ... }:
{
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {};
    };
    containers.enable = true;
    docker.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
