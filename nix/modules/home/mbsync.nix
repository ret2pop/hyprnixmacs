{ lib, config, ... }:
{
  programs.mbsync = {
    enable = lib.mkDefault config.monorepo.profiles.email.enable;
    extraConfig = ''
      IMAPAccount ${config.monorepo.vars.internetName}
      Host ${config.monorepo.profiles.email.imapsServer}
      User ${config.monorepo.profiles.email.email}
      PassCmd "cat ${config.sops.secrets.mail.path}"
      Port 993
      TLSType IMAPS
      AuthMechs *
      CertificateFile /etc/ssl/certs/ca-certificates.crt

      IMAPStore ${config.monorepo.vars.internetName}-remote
      Account ${config.monorepo.vars.internetName}

      MaildirStore ${config.monorepo.vars.internetName}-local
      Path ~/email/${config.monorepo.vars.internetName}/
      Inbox ~/email/${config.monorepo.vars.internetName}/INBOX
      SubFolders Verbatim

      Channel ${config.monorepo.vars.internetName} 
      Far :${config.monorepo.vars.internetName}-remote:
      Near :${config.monorepo.vars.internetName}-local:
      Patterns *
      Create Near
      Sync All
      Expunge None
      SyncState *
    '';
  };
}
