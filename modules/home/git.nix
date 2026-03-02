{ pkgs, lib, config, super, ... }:
{
  programs.git = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    package = pkgs.gitFull;
    lfs.enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    userName = super.monorepo.vars.fullName;
    userEmail = "${super.monorepo.vars.email}";
    signing = {
      key = super.monorepo.vars.gpgKey;
      signByDefault = true;
    };

    extraConfig = {
      init.defaultBranch = "main";
      credential."mail.${super.monorepo.vars.orgHost}" = {
        username = "${super.monorepo.vars.email}";
        helper = "!f() { test \"$1\" = get && echo \"password=$(cat /run/user/1000/secrets/mail)\"; }; f";
      };

      sendemail = {
        smtpserver = "mail.${super.monorepo.vars.orgHost}";
        smtpuser = "${super.monorepo.vars.email}";
        smtpserverport = 465;
        smtpencryption = "ssl";
      };
    };

    aliases = {
      pl = "pull";
      ps = "push";
      co = "checkout";
      c = "commit";
      a = "add";
      st = "status";
      sw = "switch";
      b = "branch";
    };
  };
}
