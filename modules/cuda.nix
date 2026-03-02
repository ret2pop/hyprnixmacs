{ config, lib, pkgs, ... }:
{
  environment.systemPackages = (if config.monorepo.profiles.cuda.enable then with pkgs; [
	cudatoolkit
	cudaPackages.cudnn
	cudaPackages.libcublas
	linuxPackages.nvidia_x11
  ] else []);
}
