{ lib, config, ... }:
{
  services.znc = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    openFirewall = true;
    confOptions = {
      useSSL = true;
      passBlock = ''
<Pass password>
  Method = sha256
  Hash = ${config.sops.secrets.znc_password_hash}
  Salt = ${config.sops.secrets.znc_password_salt}
</Pass>
'';
      modules = [
        "partyline"
        "webadmin"
        "adminlog"
        "log"
      ];
      networks = {
        "libera" = {
          server = "irc.libera.chat";
          port = 6697;
          useSSL = true;
          modules = [ "simple_away" ];
        };
      };
    };
  };
}
