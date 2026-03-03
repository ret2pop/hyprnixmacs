{ lib, config, isIntegrationTest, ... }:
{
  nixpkgs = lib.mkIf (! isIntegrationTest) {
    hostPlatform = lib.mkDefault "x86_64-linux";
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
