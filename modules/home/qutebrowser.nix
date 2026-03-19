# [[file:../../../config/nix.org::*QuteBrowser][QuteBrowser:1]]
{ lib, config, ... }:
{
  programs.qutebrowser = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    enableDefaultBindings = true;
    searchEngines = {
      g = "https://www.google.com/search?hl=en&amp;q={}";
      w = "https://en.wikipedia.org/wiki/Special:Search?search={}&amp;go=Go&amp;ns0=1";
      aw = "https://wiki.archlinux.org/?search={}";
      nw = "https://wiki.nixos.org/index.php?search={}";
    };
    settings = {
      content.blocking.method = "both";
    };
  };
}
# QuteBrowser:1 ends here
