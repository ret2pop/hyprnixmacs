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
