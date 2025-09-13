{ lib, config, ... }:
{
  programs.git = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    userName = config.monorepo.vars.fullName;
    userEmail = config.monorepo.profiles.email.email;
    signing = {
      key = config.monorepo.vars.gpgKey;
      signByDefault = true;
    };

    extraConfig = {
      init.defaultBranch = "main";
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
