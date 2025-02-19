{ config, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age = {
      keyFile = "/home/${config.monorepo.vars.userName}/.ssh/keys.txt";
    };
    secrets.mail = {
      format = "yaml";
      path = "${config.sops.defaultSymlinkPath}/mail";
    };
    secrets.cloudflare-dns = {
      format = "yaml";
      path = "${config.sops.defaultSymlinkPath}/cloudflare-dns";
    };
    secrets.digikey = {
      format = "yaml";
      path = "${config.sops.defaultSymlinkPath}/digikey";
    };

    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
  };
}
