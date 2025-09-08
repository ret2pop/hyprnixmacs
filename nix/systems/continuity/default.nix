{ ... }:
{
  imports = [
    ../../disko/drive-simple.nix
    ../includes.nix
  ];
  config = {
    # drive to install to
    monorepo.vars.device = "/dev/sda";
  };
}
