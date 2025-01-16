{ lib, config, ... }:
{
  enable = lib.mkDefault config.monorepo.profiles.home.email.enable;
  extraConfig = ''
      # Set default values for all following accounts.
      defaults
      auth           on
      tls            on
      tls_trust_file /etc/ssl/certs/ca-certificates.crt
      tls_certcheck  off
      logfile        ~/.msmtp.log

      # Gmail
      account        ${config.monorepo.vars.userName}
      host           ${config.monorepo.profiles.home.email.smtpsServer}
      port           587
      from           ${config.monorepo.profiles.home.email.email}
      user           ${config.monorepo.profiles.home.email.email}
      passwordeval   "cat ${config.sops.secrets.mail.path}"


      # Set a default account
      account default : ${config.monorepo.vars.userName}
    '';
}
