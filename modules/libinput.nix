# [[file:../../config/nix.org::*Libinput][Libinput:1]]
{ lib, config, ... }:
{
  services.libinput = {
    enable = lib.mkDefault config.monorepo.profiles.desktop.enable;
    mouse = {
      dev = "/dev/input/by-id/usb-047d_80fd-event-mouse";
      scrollMethod = "button";
      scrollButton = 276;
    };
  };
}
# Libinput:1 ends here
