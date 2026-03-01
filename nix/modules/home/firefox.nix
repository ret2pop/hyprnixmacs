{ lib, config, pkgs, ... }:
{
  programs.librewolf = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    package = pkgs.librewolf;
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;

        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          tree-style-tab
          firefox-color
          vimium
          privacy-redirect
        ] ++ (lib.optional config.monorepo.profiles.crypto.enable pkgs.nur.repos.rycee.firefox-addons.metamask);

      };
    };
  };
}
