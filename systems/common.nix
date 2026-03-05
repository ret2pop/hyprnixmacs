{ ... }:
{
  imports = [
    ./home.nix
    ../modules/default.nix
    ../disko/gpt-common.nix
  ];
  # Put configuration (e.g. monorepo variable configuration) common to all configs here
}
