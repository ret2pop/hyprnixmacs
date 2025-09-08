{ config, lib, ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkDefault (! config.monorepo.profiles.server.enable);
      AllowUsers = [ config.monorepo.vars.userName "root" "git" ];
      PermitRootLogin = "prohibit-password";
      KbdInteractiveAuthentication = false;
    };
  };
}
