{ config, ... }:
{
  enable = true;
  settings = {
    PasswordAuthentication = true;
    AllowUsers = [ config.vars.userName ];
    PermitRootLogin = "no";
    KbdInteractiveAuthentication = false;
  };
}
