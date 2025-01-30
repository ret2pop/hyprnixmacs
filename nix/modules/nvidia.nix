{ config, lib, pkgs, ... }:
{
  hardware = {
    graphics.extraPackages = with pkgs; [
	vaapiVdpau
	libvdpau-va-gl
	nvidia-vaapi-driver
    ];

    nvidia = {
	modesetting.enable = true;
	powerManagement = {
		enable = true;
		finegrained = false;
	};
	nvidiaSettings = true;
	open = false;
	package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
