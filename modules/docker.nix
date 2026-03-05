{ lib, ... }:
{
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {};
    };
    containers.enable = lib.mkDefault false;
    podman = {
      enable = lib.mkDefault false;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
