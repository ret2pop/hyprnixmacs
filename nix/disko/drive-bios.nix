{ config, lib, ... }:
let
  spec = {
    disko.devices = {
      disk = {
        main = {
          device = config.monorepo.vars.device;
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                type = "EF02";
              };
              root = {
                label = "disk-main-root"; 
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
in
{
  monorepo.vars.diskoSpec = spec;
  disko.devices = spec.disko.devices;
}
