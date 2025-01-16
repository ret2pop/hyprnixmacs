{ lib, config, pkgs, ... }:
{
  sops = import ./sops.nix;
  home = {
    activation.startup-files = lib.hm.dag.entryAfter [ "installPackages" ] ''
    if [ ! -d "/home/${config.monorepo.vars.userName}/email/ret2pop/" ]; then
      mkdir -p /home/${config.monorepo.vars.userName}/email/ret2pop/
    fi
    if [ ! -d "/home/${config.monorepo.vars.userName}/music" ]; then
      mkdir -p /home/${config.monorepo.vars.userName}/music
    fi
    if [ ! -d "/home/${config.monorepo.vars.userName}/sounds" ]; then
      mkdir -p /home/${config.monorepo.vars.userName}/sounds
    fi
    touch /home/${config.monorepo.vars.userName}/org/agenda.org
    touch /home/${config.monorepo.vars.userName}/org/notes.org
    touch /home/${config.monorepo.vars.userName}/.monorepo
    '';

    enableNixpkgsReleaseCheck = false;
    username = config.monorepo.vars.userName;
    homeDirectory = "/home/${config.monorepo.vars.userName}";
    stateVersion = "24.11";

    packages = with pkgs; [
      # passwords
      age sops

      # formatting
      ghostscript texliveFull pandoc

      # Emacs Deps
      graphviz jq

      # Apps
      octaveFull vesktop grim swww

      # Sound/media
      pavucontrol alsa-utils imagemagick ffmpeg vim

      # Net
      curl rsync git

      # fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      fira-code
      font-awesome_6
      (aspellWithDicts
        (dicts: with dicts; [ en en-computers en-science ]))
      (nerdfonts.override { fonts = [ "Iosevka" ]; })

      # Misc.
      pinentry
      x11_ssh_askpass
      xdg-utils
      acpilight
      pfetch
      libnotify
      
      # Shell script
      (writeShellScriptBin "post-install" ''
cd $HOME
ping -q -c1 google.com &>/dev/null && echo "online! Proceeding with the post-install..." || nmtui
sudo chown -R "$(whoami)":users ./monorepo

sudo nixos-rebuild switch --flake ./monorepo/nix#continuity
echo "Post install done! Now install your ssh and gpg keys. Log in again."
sleep 3
exit
'')
    ];
  };

  services = {
    mako = import ./mako.nix;
    gpg-agent = {
      pinentryPackage = pkgs.pinentry-emacs;
      enable = true;
      extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
    };
    gammastep = import ./gammastep.nix;
    mpd = import ./mpd.nix;
  };

  programs = {
    mpv = import ./mpv.nix;
    yt-dlp = import ./yt-dlp.nix;
    wofi = import ./wofi.nix;
    kitty = import ./kitty.nix;
    firefox = import ./firefox.nix;
    waybar = import ./waybar.nix;
    zsh = import ./zsh.nix;
    emacs = import ./emacs.nix;
    mbsync = import ./mbsync.nix;
    msmtp = import ./msmtp.nix;
    bash.enable = true;
    git = import ./git.nix;
    home-manager.enable = lib.mkDefault config.monorepo.profiles.home.enable;
  };

  wayland.windowManager.hyprland = import ./hyprland.nix;

  gtk = {
    enable = true;
    theme = null;
    iconTheme = null;
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-chinese-addons
      fcitx5-configtool
      fcitx5-mozc
      fcitx5-rime
    ];
  };

  fonts.fontconfig.enable = true;
  nixpkgs.config.cudaSupport = false;
}
