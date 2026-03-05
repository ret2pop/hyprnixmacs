{ config, ... }:
let
  spec = {
    disko.devices.main = {
      type = "disk";
      device = config.monorepo.vars.device;
      content = {
        type = "gpt";
        partitions = if ((builtins.match "/dev/vd[a-z]+" config.monorepo.vars.device) != null) then
          (import ./virtual-machine.nix)
                     else (if ((builtins.match "/dev/mmcblk[0-9]+" config.monorepo.vars.device) != null) then
                       (import ./rpi.nix)
                           else 
                             (import ./. + "${config.monorepo.vars.fileSystem}.nix"));
      };
    };
  };
in
{
  monorepo.vars.diskoSpec = spec;
  disko.devices = spec.disko.devices;
}
