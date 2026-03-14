# [[file:../../config/nix.org::*Containers][Containers:1]]
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
# Containers:1 ends here
