{ config, ... }:
let
  inherit
    (config.lib.topology);
in
{
  nodes = {
    spontaneity = {
      interfaces.wan.network = "remote";
    };
    installer = {
      interfaces.lan.network = "home";
    };
    affinity = {
      interfaces.lan = {
        network = "home";
        physicalConnections = [
          {
            node = "spontaneity";
            interface = "wan";
          }
          {
            node = "installer";
            interface = "lan";
          }
        ];
      };
    };
    continuity = {
      interfaces.lan = {
        network = "home";
        physicalConnections = [
          {
            node = "spontaneity";
            interface = "wan";
          }
          {
            node = "affinity";
            interface = "lan";
          }
        ];
      };
    };
  };
  networks = {
    home = {
      name = "Home Network";
      cidrv4 = "192.168.1.1/24";
    };
    remote = {
      name = "Remote Network";
      cidrv4 = "144.202.27.169/32";
    };
  };
}
