{ config, ... }:
{
  sops = {
    defaultSopsFile = if config.monorepo.profiles.graphics.enable
                      then ../../secrets/secrets.yaml
                      else ../../secrets/vps_secrets.yaml;

    age = {
      keyFile = "/home/${config.monorepo.vars.userName}/.config/sops/age/keys.txt";
    };

    secrets = if config.monorepo.profiles.graphics.enable then {
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
    } else {
    };
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
  };
}
