# [[file:../../../config/nix.org::*QuteBrowser][QuteBrowser:1]]
{ pkgs, lib, config, catppuccin-qutebrowser, ... }:
{
  programs.qutebrowser = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    package = pkgs.qutebrowser.overrideAttrs (old: {
      qtWrapperArgs = (old.qtWrapperArgs or []) ++ [
        "--set" "__EGL_VENDOR_LIBRARY_FILENAMES" "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json"
        "--set" "GBM_BACKEND" "nvidia-drm"
        "--set" "__GLX_VENDOR_LIBRARY_NAME" "nvidia"
        "--set" "QT_QPA_PLATFORM" "wayland"
      ];
    });
    
    enableDefaultBindings = true;
    searchEngines = {
      DEFAULT = "https://search.marginalia.nu/search?query={}";
      g = "https://www.google.com/search?hl=en&amp;q={}";
      w = "https://en.wikipedia.org/wiki/Special:Search?search={}&amp;go=Go&amp;ns0=1";
      aw = "https://wiki.archlinux.org/?search={}";
      nw = "https://wiki.nixos.org/index.php?search={}";
      npk = "https://search.nixos.org/packages?channel=unstable&query={}";
    };
    
    settings = {
      # This is the magic combination for Qtile + Wayland + Qutebrowser
      qt.args = [
        "enable-features=UseOzonePlatform"
        "ozone-platform=wayland"
        "disable-gpu"
        "disable-software-rasterizer"
        "disable-gpu-sandbox"
      ];
      
      # Force Qt to draw the UI in software mode so it doesn't look for OpenGL
      qt.force_software_rendering = "qt-quick"; 

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

c.content.blocking.hosts.lists.append('https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social-only/hosts')
c.content.blocking.hosts.lists.append('https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social-only/hosts')
c.content.blocking.hosts.lists.append('https://raw.githubusercontent.com/gieljnssns/Social-media-Blocklists/refs/heads/master/adguard-youtube.txt')
c.content.blocking.hosts.lists.append('${../../data/youtube-blocklist}')
'';
  };
}
# QuteBrowser:1 ends here
