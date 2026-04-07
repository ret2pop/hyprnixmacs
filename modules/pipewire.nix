# [[file:../../config/nix.org::*Pipewire][Pipewire:1]]
{ lib, config, ... }:
{
  services.pipewire = {
    enable = lib.mkDefault config.monorepo.profiles.pipewire.enable;
    alsa = {
      enable = lib.mkDefault config.monorepo.profiles.pipewire.enable;
      support32Bit = true;
    };
    pulse.enable = lib.mkDefault config.monorepo.profiles.pipewire.enable;
    jack.enable = lib.mkDefault config.monorepo.profiles.pipewire.enable;
    wireplumber.enable = lib.mkDefault config.monorepo.profiles.pipewire.enable;

    extraConfig = {
      pipewire."92-clock" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [ 48000 ];

          "default.clock.quantum" = 2048;
          "default.clock.min-quantum" = 1024;
          "default.clock.max-quantum" = 4096;

          "default.clock.quantum-limit" = 8192;
        };
      };

      pipewire-pulse."92-obs-very-stable" = {
        "pulse.properties" = {
          "pulse.min.req" = "1024/48000";
          "pulse.default.req" = "2048/48000";
          "pulse.max.req" = "4096/48000";

          "pulse.min.quantum" = "512/48000";
          "pulse.max.quantum" = "4096/48000";
        };

        "stream.properties" = {
          "node.latency" = "2048/48000";
          "node.max-latency" = "4096/48000";
          "resample.quality" = 10;
        };
      };
    };
  };
}
# Pipewire:1 ends here
