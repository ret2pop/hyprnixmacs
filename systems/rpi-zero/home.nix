{ ... }:
{
  imports = [
    ../home-common.nix
  ];
  config.monorepo.profiles.enable = false;
}
