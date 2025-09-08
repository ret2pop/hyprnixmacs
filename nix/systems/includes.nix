{ config, lib, ... }:
{
  imports = [
    ./home.nix
    ../modules/default.nix
  ];
}
