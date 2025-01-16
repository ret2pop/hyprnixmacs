{ lib, config, ... }:
{
  enable = lib.mkDefault config.monorepo.profiles.home.enable;
  userName = config.vars.fullName;
  userEmail = config.vars.email;
  signing = {
    key = config.vars.gpgKey;
    signByDefault = true;
  };

  extraConfig = {
    init.defaultBranch = "main";
  };

  aliases = {
    co = "checkout";
    c = "commit";
    a = "add";
    s = "switch";
    b = "branch";
  };
}
