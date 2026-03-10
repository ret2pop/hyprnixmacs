{ config, super, ... }:
{
  sops = {
    defaultSopsFile = if config.monorepo.profiles.graphics.enable
                      then ../../secrets/secrets.yaml
                      else ../../secrets/vps_secrets.yaml;

    age = {
      keyFile = "/home/${super.monorepo.vars.userName}/.config/sops/age/keys.txt";
    };

    secrets = if super.monorepo.profiles.desktop.enable then {
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

      ntfy = {
        format = "yaml";
        path = "${config.sops.defaultSymlinkPath}/${super.monorepo.vars.ntfySecret}";
        sopsFile = ../../secrets/common-secrets.yaml;
      };
    } else {
    };
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
  };
}
