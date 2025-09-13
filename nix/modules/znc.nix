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
  Hash = d4abdd69aa24de69693885c5bd83a4a0e9ee989e1a69a905041b0dad9abc06ea
  Salt = sDY,?H5AxC-!gH3a.:)D
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
