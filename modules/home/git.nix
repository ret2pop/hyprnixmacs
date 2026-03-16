# [[file:../../../config/nix.org::*Git][Git:1]]
{ pkgs, lib, config, super, ... }:
{
  programs.git = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    package = pkgs.gitFull;
    userName = super.monorepo.vars.fullName;
    userEmail = super.monorepo.vars.email;
    lfs.enable = lib.mkDefault config.monorepo.profiles.graphics.enable;

    signing = {
      key = super.monorepo.vars.gpgKey;
      signByDefault = true;
    };

    # alias = {
    #   pl = "pull";
    #   ps = "push";
    #   co = "checkout";
    #   c = "commit";
    #   a = "add";
    #   st = "status";
    #   sw = "switch";
    #   b = "branch";
    # };

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
    # settings = {
    #   user = {
    #     name = super.monorepo.vars.fullName;
    #     email = super.monorepo.vars.email;
    #   };

      
    # };

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
# Git:1 ends here
