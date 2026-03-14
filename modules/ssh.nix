# [[file:../../config/nix.org::*SSH][SSH:1]]
{ config, lib, ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ config.monorepo.vars.userName "git" ];
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };
  networking.firewall.allowedTCPPorts = lib.mkIf config.services.openssh.enable [ 22 ];
}
# SSH:1 ends here
