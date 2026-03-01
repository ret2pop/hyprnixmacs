{ lib, config, super, ... }:
{
  programs.msmtp = {
    enable = lib.mkDefault config.monorepo.profiles.email.enable;
    extraConfig = ''
      # Set default values for all following accounts.
      defaults
      auth           on
      tls            on
      tls_trust_file /etc/ssl/certs/ca-certificates.crt
      tls_certcheck  off
      logfile        ~/.msmtp.log

      # Gmail
      account        ${super.monorepo.vars.internetName}
      host           mail.${super.monorepo.vars.orgHost}
      port           587
      from           ${super.monorepo.vars.email}
      user           ${super.monorepo.vars.email}
      passwordeval   "cat ${config.sops.secrets.mail.path}"


      # Set a default account
      account default : ${super.monorepo.vars.internetName}
    '';
  };
}
