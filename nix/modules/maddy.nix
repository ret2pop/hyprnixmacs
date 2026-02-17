{ lib, config, options, ... }:
{
  services.maddy = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    openFirewall = true;
    hostname = "${config.monorepo.vars.orgHost}";
    primaryDomain = "mail.${config.monorepo.vars.orgHost}";
    localDomains = [
      "$(primary_domain)"
      "${config.monorepo.vars.orgHost}"
    ];
    tls = {
      loader = "file";
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
    ] [
      "imap tls://0.0.0.0:993 tcp://0.0.0.0:143"
      "submission tls://0.0.0.0:465 tcp://0.0.0.0:587"
    ] options.services.maddy.config.default;
    ensureCredentials = {
      "${config.monorepo.vars.internetName}@${config.monorepo.vars.orgHost}" = {
        passwordFile = "/run/secrets/mail_password";
      };
      "monorepo@${config.monorepo.vars.orgHost}" = {
        passwordFile = "/run/secrets/mail_monorepo_password";
      };
      "discussion@${config.monorepo.vars.orgHost}" = {
        passwordFile = "/run/secrets/mail_monorepo_password";
      };
    };
  };
}
