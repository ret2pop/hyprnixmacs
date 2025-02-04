{ config, ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [ config.monorepo.vars.userName ];
      PermitRootLogin = "prohibit-password";
      KbdInteractiveAuthentication = false;
    };
  };
}
