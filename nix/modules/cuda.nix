{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
	cudatoolkit
	cudaPackages.cudnn
	cudaPackages.libcublas
	linuxPackages.nvidia_x11
  ];
}
