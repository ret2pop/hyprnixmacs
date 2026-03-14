# [[file:../../config/nix.org::*CUDA][CUDA:1]]
{ config, pkgs, ... }:
{
  environment.systemPackages = (if config.monorepo.profiles.cuda.enable then with pkgs; [
    cudatoolkit
    cudaPackages.cudnn
    cudaPackages.libcublas
    linuxPackages.nvidia_x11
  ] else []);
}
# CUDA:1 ends here
