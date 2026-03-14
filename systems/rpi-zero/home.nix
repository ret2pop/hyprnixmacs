# [[file:../../../config/nix.org::*Home][Home:1]]
{ ... }:
{
  imports = [
    ../home-common.nix
  ];
  config.monorepo.profiles.enable = false;
}
# Home:1 ends here
