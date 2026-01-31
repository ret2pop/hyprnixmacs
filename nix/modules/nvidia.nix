{ config, lib, pkgs, ... }:
{
  hardware = {
    graphics.extraPackages = (if config.monorepo.profiles.cuda.enable
                              then with pkgs; [
                                libva-vdpau-driver
                                libvdpau-va-gl
                                nvidia-vaapi-driver
                              ] else []);

    nvidia = {
	    modesetting.enable = lib.mkDefault config.monorepo.profiles.cuda.enable;
	    powerManagement = {
		    enable = lib.mkDefault config.monorepo.profiles.cuda.enable;
		    finegrained = false;
	    };
	    nvidiaSettings = lib.mkDefault config.monorepo.profiles.cuda.enable;
	    open = config.monorepo.profiles.cuda.enable;
	    package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
