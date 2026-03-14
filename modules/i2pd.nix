# [[file:../../config/nix.org::*i2pd][i2pd:1]]
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
# i2pd:1 ends here
