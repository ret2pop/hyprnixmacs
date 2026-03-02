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
      pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 512;
          "default.clock.min-quantum" = 512;
          "default.clock.max-quantum" = 1024;
        };
        pipewire-pulse."92-low-latency" = {
          "context.properties" = [
            {
              name = "libpipewire-module-protocol-pulse";
              args = { };
            }
          ];
          "pulse.properties" = {
            "pulse.min.req" = "32/48000";
            "pulse.default.req" = "32/48000";
            "pulse.max.req" = "32/48000";
            "pulse.min.quantum" = "32/48000";
            "pulse.max.quantum" = "32/48000";
          };
          "stream.properties" = {
            "node.latency" = "32/48000";
            "resample.quality" = 1;
          };
        };
      };
    };
  };
}
