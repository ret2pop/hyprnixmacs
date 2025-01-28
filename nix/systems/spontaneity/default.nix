{ ... }:
{
  imports = [
    ../../modules/default.nix
  ];
  monorepo = {
    pipewire.enable = false;
    home.enable = false;
  };
}
