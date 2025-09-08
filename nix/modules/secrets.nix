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
        sopsFile = config.sops.defaultSopsFile;
#        sopsFile = ../../secrets/secrets.yaml;
        path = "${config.sops.defaultSymlinkPath}/mail";
      };
      cloudflare-dns = {
        format = "yaml";
        sopsFile = config.sops.defaultSopsFile;
        path = "${config.sops.defaultSymlinkPath}/cloudflare-dns";
      };
      digikey = {
        format = "yaml";
        sopsFile = config.sops.defaultSopsFile;
        path = "${config.sops.defaultSymlinkPath}/digikey";
      };
      dn42 = {
        format = "yaml";
        sopsFile = config.sops.defaultSopsFile;
#        sopsFile = ../../secrets/secrets.yaml;
        path = "${config.sops.defaultSymlinkPath}/dn42";
      };
      znc = {
        format = "yaml";
        sopsFile = config.sops.defaultSopsFile;
#        sopsFile = ../../secrets/secrets.yaml;
        path = "${config.sops.defaultSymlinkPath}/znc";
      };
      znc_password_salt = {
        format = "yaml";
        sopsFile = config.sops.defaultSopsFile;
#        sopsFile = ../../secrets/secrets.yaml;
        path = "${config.sops.defaultSymlinkPath}/znc_password_salt";
      };

      znc_password_hash = {
        format = "yaml";
        sopsFile = config.sops.defaultSopsFile;
#        sopsFile = ../../secrets/secrets.yaml;
        path = "${config.sops.defaultSymlinkPath}/znc_password_hash";
      };

      matrix_bridge = {
        format = "yaml";
        sopsFile = config.sops.defaultSopsFile;
#        sopsFile = ../../secrets/secrets.yaml;
        path = "${config.sops.defaultSymlinkPath}/matrix_bridge";
      };
    };
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
  };
}
