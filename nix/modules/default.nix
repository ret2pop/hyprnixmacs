{ lib, config, pkgs, ... }:
{
  imports = [
    ./configuration.nix
    ./home/home.nix
    ./vars.nix
  ];

  options = {
    monorepo = {
      profiles = {
        cuda.enable = lib.mkEnableOption "Enables CUDA support";
        documentation.enable = lib.mkEnableOption "Enables documentation on system.";
        secureBoot.enable = lib.mkEnableOption "Enables secure boot. See sbctl.";
        pipewire.enable = lib.mkEnableOption "Enables pipewire low latency audio setup";
        tor.enable = lib.mkEnableOption "Enables tor along with torsocks";
        home.enable = lib.mkEnableOption "Enables home user";
      };
    };
  };

  config = {
    home-manager.users."${config.monorepo.vars.userName}" = {
      programs.home-manager.enable = config.monorepo.profiles.home.enable;
    };

    environment.systemPackages = lib.mkIf config.monorepo.profiles.documentation.enable (with pkgs; [
      linux-manual
      man-pages
      man-pages-posix
    ]);

    monorepo = {
      profiles = {
        documentation.enable = lib.mkDefault true;
        pipewire.enable = lib.mkDefault true;
        tor.enable = lib.mkDefault true;
        home.enable = lib.mkDefault true;
      };
    };
  };
}
