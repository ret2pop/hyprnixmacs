{ config, lib, ... }:
{
  imports = [
    ./home.nix
    ../modules/default.nix
  ];
  # Put configuration (e.g. monorepo variable configuration) common to all configs here
}
