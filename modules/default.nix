{ lib, config, pkgs, ... }:
let
  dirContents = builtins.readDir ./.;
  files = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix") dirContents;
in
{
  imports = lib.mapAttrsToList (name: _: ./. + "${name}") files;

  options = {
    monorepo = {
	    profiles = {
		    cuda.enable = lib.mkEnableOption "Enables CUDA support";
		    documentation.enable = lib.mkEnableOption "Enables documentation on system.";
		    secureBoot.enable = lib.mkEnableOption "Enables secure boot. See sbctl.";
		    pipewire.enable = lib.mkEnableOption "Enables pipewire low latency audio setup";
		    tor.enable = lib.mkEnableOption "Enables tor along with torsocks";

        server = {
          enable = lib.mkEnableOption "Enables server services";
          interface = lib.mkOption { type = lib.types.str; default = "eth0"; };
          ipv4 = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
          ipv6 = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
          gateway = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
        };

        ttyonly.enable = lib.mkEnableOption "TTY only, no xserver";
        grub.enable = lib.mkEnableOption "Enables grub instead of systemd-boot";
        workstation.enable = lib.mkEnableOption "Enables workstation services";
        desktop.enable = lib.mkEnableOption "Enables everything common to desktops";
        impermanence.enable = lib.mkEnableOption "Enables imperamanence";
        home.enable = lib.mkEnableOption "Enables home profiles";
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

    assertions = [
      {
        assertion = !(config.monorepo.profiles.workstation.enable && config.monorepo.profiles.server.enable);
        message = ''
You can't enable both workstation and server profile together. Please select only one.
'';
      }
      {
        assertion = !(config.monorepo.profiles.desktop.enable && config.monorepo.profiles.server.enable);
        message = ''
You can't enable both desktop and server profile together. Please select only one.
'';
      }
    ];
    monorepo = {
	    profiles = {
        desktop.enable = lib.mkDefault config.monorepo.profiles.workstation.enable;
		    documentation.enable = lib.mkDefault true;
		    pipewire.enable = lib.mkDefault true;
		    tor.enable = lib.mkDefault true;
        impermanence.enable = lib.mkDefault false;
        server.enable = lib.mkDefault false;
        ttyonly.enable = lib.mkDefault config.monorepo.profiles.server.enable;
        home.enable = lib.mkDefault config.monorepo.profiles.desktop.enable;
	    };
    };
  };
}
