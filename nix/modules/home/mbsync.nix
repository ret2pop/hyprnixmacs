{ lib, config, ... }:
{
  enable = lib.mkDefault config.profiles.home.email.enable;
  extraConfig = ''
      IMAPAccount ret2pop
      Host ${config.profiles.home.email.imapsServer}
      User ${config.profiles.email.email}
      PassCmd "cat ${config.sops.secrets.mail.path}"
      Port 993
      TLSType IMAPS
      AuthMechs *
      CertificateFile /etc/ssl/certs/ca-certificates.crt

      IMAPStore ret2pop-remote
      Account ret2pop

      MaildirStore ret2pop-local
      Path ~/email/ret2pop/
      Inbox ~/email/ret2pop/INBOX
      SubFolders Verbatim

      Channel ret2pop 
      Far :ret2pop-remote:
      Near :ret2pop-local:
      Patterns *
      Create Near
      Sync All
      Expunge None
      SyncState *
    '';
}
