{ lib, ... }:
{
  services.i2pd = {
    enable = lib.mkDefault false;
    address = "0.0.0.0";
    inTunnels = {
    };
    outTunnels = {
    };
  };
}
