# [[file:../../config/nix.org::*Nixpkgs][Nixpkgs:1]]
{ lib, config, isIntegrationTest, system, ... }:
{
  nixpkgs = lib.mkIf (! isIntegrationTest) {
    hostPlatform = lib.mkDefault system;
    buildPlatform = lib.mkIf (system == "aarch64-linux") (lib.mkDefault "x86_64-linux");
    overlays = [
    ];
    config = {
      allowUnfree = true;
      cudaSupport = lib.mkDefault config.monorepo.profiles.cuda.enable;
    };
    config.permittedInsecurePackages = [
      "python3.13-ecdsa-0.19.1"
      "olm-3.2.16"
    ];
  };
}
# Nixpkgs:1 ends here
