# [[file:../../../config/nix.org::*QuteBrowser][QuteBrowser:1]]
{ lib, config, catppuccin-qutebrowser, ... }:
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
      fonts.default_family = "Lora";
      fonts.default_size = "12pt";

      # Command/completion UI
      fonts.statusbar = "12pt Lora";
      fonts.completion.entry = "12pt Lora";
      fonts.completion.category = "bold 12pt Lora";
      fonts.prompts = "12pt Lora";

      # Tabs
      fonts.tabs.selected = "12pt Lora";
      fonts.tabs.unselected = "12pt Lora";

      # Hints
      fonts.hints = "bold 12pt Lora";
    };
    extraConfig = (builtins.readFile "${catppuccin-qutebrowser}/setup.py") +
''
config.load_autoconfig()
setup(c, "mocha", True)
'';
  };
}
# QuteBrowser:1 ends here
