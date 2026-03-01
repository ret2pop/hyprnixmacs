{ lib, config, super, ... }:
{
  programs.mbsync = {
    enable = lib.mkDefault config.monorepo.profiles.email.enable;
    extraConfig = ''
      IMAPAccount ${super.monorepo.vars.internetName}
      Host mail.${super.monorepo.vars.orgHost}
      User ${super.monorepo.vars.email}
      PassCmd "cat ${config.sops.secrets.mail.path}"
      Port 993
      TLSType IMAPS
      AuthMechs *
      CertificateFile /etc/ssl/certs/ca-certificates.crt

      IMAPStore ${super.monorepo.vars.internetName}-remote
      Account ${super.monorepo.vars.internetName}

      MaildirStore ${super.monorepo.vars.internetName}-local
      Path ~/email/${super.monorepo.vars.internetName}/
      Inbox ~/email/${super.monorepo.vars.internetName}/INBOX
      SubFolders Verbatim

      Channel ${super.monorepo.vars.internetName} 
      Far :${super.monorepo.vars.internetName}-remote:
      Near :${super.monorepo.vars.internetName}-local:
      Patterns *
      Create Near
      Sync All
      Expunge None
      SyncState *
    '';
  };
}
