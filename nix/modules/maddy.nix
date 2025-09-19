{ lib, config, options, ... }:
{
  services.maddy = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    openFirewall = true;
    hostName = "${config.monorepo.vars.remoteHost}";
    primaryDomain = "mail.${config.monorepo.vars.remoteHost}";
    tls = {
      loader = "acme";
    };
    config = builtins.replaceStrings [
      "imap tcp://0.0.0.0:143"
      "submission tcp://0.0.0.0:587"
    ] [
      "imap tls://0.0.0.0:993 tcp://0.0.0.0:143"
      "submission tls://0.0.0.0:465 tcp://0.0.0.0:587"
    ] options.services.maddy.config.default;
    ensureCredentials = {
      "${config.monorepo.vars.userName}@localhost" = {
        passwordFile = "/secrets/${config.monorepo.vars.userName}-localhost";
      };
    };
  };
}
