{ lib, config, ... }:
{
  imports = [
    ../common.nix
    ../../disko/btrfs-simple.nix
  ];
}
