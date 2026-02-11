{ lib, config, ... }:
{
  config = lib.mkIf config.monorepo.profiles.graphics.enable {
    sops.secrets = {
      mail = {
        format = "yaml";
        path = "${config.sops.defaultSymlinkPath}/mail";
      };
      cloudflare-dns = {
        format = "yaml";
        path = "${config.sops.defaultSymlinkPath}/cloudflare-dns";
      };
      digikey = {
        format = "yaml";
        path = "${config.sops.defaultSymlinkPath}/digikey";
      };
      dn42 = {
        format = "yaml";
        path = "${config.sops.defaultSymlinkPath}/dn42";
      };
    };
  };
}
