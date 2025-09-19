{ lib, config, pkgs, ... }:
{
  imports = [
    ./configuration.nix
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
		    server.enable = lib.mkEnableOption "Enables server services";
        ttyonly.enable = lib.mkEnableOption "TTY only, no xserver";
        grub.enable = lib.mkEnableOption "Enables grub instead of systemd-boot";
        workstation.enable = lib.mkEnableOption "Enables workstation services";
        impermanence.enable = lib.mkEnableOption "Enables imperamanence";
	    };
    };
  };

  config = {
    environment.systemPackages = lib.mkIf config.monorepo.profiles.documentation.enable ((with pkgs; [
	    linux-manual
	    man-pages
	    man-pages-posix
      iproute2
      silver-searcher
      ripgrep
    ]) ++
    (if (config.monorepo.vars.fileSystem == "btrfs") then with pkgs; [
      btrfs-progs
      btrfs-snap
      btrfs-list
      btrfs-heatmap
    ] else []));

    boot.loader.grub = lib.mkIf config.monorepo.profiles.grub.enable {
      enable = true;
    };

    monorepo = {
	    profiles = {
		    documentation.enable = lib.mkDefault true;
		    pipewire.enable = lib.mkDefault true;
		    tor.enable = lib.mkDefault true;
		    home.enable = lib.mkDefault true;
        impermanence.enable = lib.mkDefault false;
	    };
    };
  };
}
