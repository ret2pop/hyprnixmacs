{ lib, config, pkgs, ... }:
{
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
      octaveFull vesktop grim swww vim 

      # Sound/media
      pavucontrol alsa-utils imagemagick ffmpeg helvum

      # Net
      curl rsync git

      # Tor
      torsocks tor-browser

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
    ];
  };

  services = {
    gpg-agent = {
      pinentryPackage = pkgs.pinentry-emacs;
      enable = true;
      extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
    };
  };

  programs.bash.enable = true;

  gtk = {
    enable = true;
    theme = null;
    iconTheme = null;
  };

  fonts.fontconfig.enable = true;
  nixpkgs.config.cudaSupport = lib.mkDefault config.monorepo.profiles.cuda.enable;
}
