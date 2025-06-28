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
    if [ ! -d /home/${config.monorepo.vars.userName}/org ]; then
      mkdir -p /home/${config.monorepo.vars.userName}/org
    fi
    if [ ! -d /home/${config.monorepo.vars.userName}/src ]; then
      mkdir -p /home/${config.monorepo.vars.userName}/src
    fi
    touch /home/${config.monorepo.vars.userName}/org/agenda.org
    touch /home/${config.monorepo.vars.userName}/org/notes.org
    '';

    enableNixpkgsReleaseCheck = false;
    username = config.monorepo.vars.userName;
    homeDirectory = "/home/${config.monorepo.vars.userName}";
    stateVersion = "24.11";

    packages = with pkgs; (if config.monorepo.profiles.graphics.enable then [
      # wikipedia
      kiwix kiwix-tools

      # passwords
      age sops

      # formatting
      ghostscript texliveFull pandoc

      # Emacs Deps
      graphviz jq

      # Apps
      octaveFull
      vesktop grim swww vim 

      # Sound/media
      pavucontrol alsa-utils imagemagick ffmpeg helvum

      # Net
      curl rsync git iamb

      # Tor
      torsocks tor-browser

      # fonts
      nerd-fonts.iosevka noto-fonts noto-fonts-cjk-sans noto-fonts-emoji fira-code font-awesome_6
      (aspellWithDicts
        (dicts: with dicts; [ en en-computers en-science ]))

      # Misc.
      pinentry
      x11_ssh_askpass
      xdg-utils
      acpilight
      pfetch
      libnotify
      htop
      (writeShellScriptBin "remote-build"
        ''
#!/bin/bash
cd ~/monorepo/nix
nixos-rebuild --use-remote-sudo --target-host "$1" switch --flake .#spontaneity
''
      )
      (writeShellScriptBin "install-vps"
        ''
#!/bin/bash
nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./systems/spontaneity/hardware-configuration.nix --flake .#spontaneity --target-host "$1"
        '')
    ] else [
      pfetch

      # net
      curl
      torsocks
      rsync
    ]);
  };

  services = {
    gpg-agent = {
      pinentry.package = pkgs.pinentry-emacs;
      enable = true;
      extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
    };
  };

  programs.bash.enable = true;

  gtk = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    theme = null;
    iconTheme = null;
  };

  fonts.fontconfig.enable = true;
  nixpkgs.config.cudaSupport = lib.mkDefault config.monorepo.profiles.cuda.enable;
}
