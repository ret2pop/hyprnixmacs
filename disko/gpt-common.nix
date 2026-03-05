{ config, ... }:
let
  spec = {
    disko.devices.main = {
      type = "disk";
      device = config.monorepo.vars.device;
      content = {
        type = "gpt";
        partitions = if (config.monorepo.vars.device == "/dev/vda") then
          (import ./virtual-machine.nix)
          else (import ./. + "${config.monorepo.vars.fileSystem}.nix");
      };
    };
  };
in
{
  monorepo.vars.diskoSpec = spec;
  disko.devices = spec.disko.devices;
}
