{ lib, config, options, ... }:
{
  services.maddy = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    openFirewall = true;
    hostName = "${config.monorepo.vars.remoteHost}";
    primaryDomain = "mail.${config.monorepo.vars.orgHost}";
    tls = {
      certificates = [
        {
          keyPath = "/var/lib/acme/mail.${config.monorepo.vars.orgHost}/key.pem";
          certPath = "/var/lib/acme/mail.${config.monorepo.vars.orgHost}/fullchain.pem";
        }
      ];
    };
    config = builtins.replaceStrings [
      "imap tcp://0.0.0.0:143"
      "submission tcp://0.0.0.0:587"
      "smtp tcp://0.0.0.0:25"
    ] [
      "imap tls://0.0.0.0:993 tcp://0.0.0.0:143"
      "submission tls://0.0.0.0:465 tcp://0.0.0.0:587"
      "smtps tls://0.0.0.0:465 smtp tcp://0.0.0.0:25"
    ] options.services.maddy.config.default;
    ensureCredentials = {
      "${config.monorepo.vars.userName}@localhost" = {
        passwordFile = "/run/secrets/mail_password";
      };
    };
  };
}
