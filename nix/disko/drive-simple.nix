{ lib, config, ... }:
let
  spec = {
    disko.devices = {
      disk = {
        my-disk = {
          device = config.monorepo.vars.device;
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                type = "EF00";
                size = "500M";
                priority = 1;
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              root = {
                size = "100%";
                priority = 2;
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
