{ lib, config, ... }:
{
  services.pipewire = {
    enable = lib.mkDefault config.monorepo.profiles.pipewire.enable;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    extraConfig.pipewire-pulse."92-low-latency" = {
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
}
