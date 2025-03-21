{ config, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age = {
      keyFile = "/home/${config.monorepo.vars.userName}/.ssh/keys.txt";
    };
    secrets = {
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
      znc = {
        format = "yaml";
        path = "${config.sops.defaultSymlinkPath}/znc";
      };
      matrix_bridge = {
        format = "yaml";
        path = "${config.sops.defaultSymlinkPath}/matrix_bridge";
      };
    };
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
  };
}
