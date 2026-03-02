{ lib, config, ... }:
{
  config = lib.mkIf (!config.monorepo.profiles.graphics.enable) {
    sops.secrets = {
      znc = {
        format = "yaml";
        path = "${config.sops.defaultsymlinkpath}/znc";
      };
      znc_password_salt = {
        format = "yaml";
        path = "${config.sops.defaultsymlinkpath}/znc_password_salt";
      };
      znc_password_hash = {
        format = "yaml";
        path = "${config.sops.defaultsymlinkpath}/znc_password_hash";
      };
      matrix_bridge = {
        format = "yaml";
        path = "${config.sops.defaultsymlinkpath}/matrix_bridge";
      };
      coturn_secret = {
        format = "yaml";
        path = "${config.sops.defaultsymlinkpath}/coturn_secret";
      };
      livekit_secret = {
        format = "yaml";
        path = "${config.sops.defaultsymlinkpath}/livekit_secret";
      };
      livekit = {
        format = "yaml";
        path = "${config.sops.defaultsymlinkpath}/livekit";
      };
      conduit_secrets = {
        format = "yaml";
        path = "${config.sops.defaultsymlinkpath}/conduit_secrets";
      };
      mautrix_env = {
        format = "yaml";
        path = "${config.sops.defaultsymlinkpath}/mautrix_env";
      };
    };
  };
}
