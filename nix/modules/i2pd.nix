{ config, lib, ... }:
{
  services.i2pd = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    address = "0.0.0.0";
    inTunnels = {
    };
    outTunnels = {
    };
  };
}
