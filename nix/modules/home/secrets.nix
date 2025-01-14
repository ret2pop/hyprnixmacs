{ lib, config, pkgs, inputs, ... }:
{
  imports = [
    ../vars.nix
  ];

  options = {
    secrets.enable = lib.mkEnableOption "enables encrypted secrets on system";
  };

  config = lib.mkIf config.secrets.enable {
    home-manager = {
      sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
      ];
      users."${user.user}" = {};
    };
  };
}
