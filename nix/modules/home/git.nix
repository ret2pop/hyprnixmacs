{ pkgs, lib, config, ... }:
{
  programs.git = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    package = pkgs.gitFull;
    lfs.enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    userName = config.monorepo.vars.fullName;
    userEmail = config.monorepo.profiles.email.email;
    signing = {
      key = config.monorepo.vars.gpgKey;
      signByDefault = true;
    };

    extraConfig = {
      init.defaultBranch = "main";
      credential."${config.monorepo.profiles.email.smtpsServer}" = {
        username = "${config.monorepo.profiles.email.email}";
        helper = "!f() { test \"$1\" = get && echo \"password=$(cat /run/user/1000/secrets/mail)\"; }; f";
      };
      sendemail = {
        smtpserver = "${config.monorepo.profiles.email.smtpsServer}";
        smtpuser = "${config.monorepo.profiles.email.email}";
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
