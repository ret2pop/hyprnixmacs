# [[file:../../../config/nix.org::*User][User:1]]
{ lib, config, pkgs, super, ... }:
{
  home = {
    activation.startup-files = lib.hm.dag.entryAfter [ "installPackages" ] ''
      if [ ! -d "/home/${super.monorepo.vars.userName}/email/${super.monorepo.vars.internetName}/" ]; then
        mkdir -p /home/${super.monorepo.vars.userName}/email/${super.monorepo.vars.internetName}/
      fi

      if [ ! -d "/home/${super.monorepo.vars.userName}/music" ]; then
        mkdir -p /home/${super.monorepo.vars.userName}/music
      fi

      if [ ! -d /home/${super.monorepo.vars.userName}/org ]; then
        mkdir -p /home/${super.monorepo.vars.userName}/org
      fi

      if [ ! -d /home/${super.monorepo.vars.userName}/src ]; then
        mkdir -p /home/${super.monorepo.vars.userName}/src
      fi

      touch /home/${super.monorepo.vars.userName}/org/agenda.org
      touch /home/${super.monorepo.vars.userName}/org/notes.org
      '';

    enableNixpkgsReleaseCheck = false;
    username = super.monorepo.vars.userName;
    homeDirectory = "/home/${super.monorepo.vars.userName}";
    stateVersion = "24.11";

    packages = with pkgs; (if config.monorepo.profiles.graphics.enable then [
      # wikipedia
      # kiwix kiwix-tools
      gnupg
      unzip
      mupdf
      zathura

      fzf
      # passwords
      age sops

      # formatting
      ghostscript texliveFull pandoc

      # Emacs Deps
      graphviz jq

      # Apps
      octaveFull
      grim swww vim element-desktop signal-desktop signal-cli thunderbird jami imv slurp

      # Sound/media
      pavucontrol alsa-utils imagemagick ffmpeg helvum pulseaudio

      # Net
      curl rsync gitFull ungoogled-chromium devd

      # Tor
      torsocks tor-browser

      # For transfering secrets onto new system
      stow

      # fonts
      nerd-fonts.iosevka noto-fonts noto-fonts-cjk-sans noto-fonts-color-emoji fira-code font-awesome_6 victor-mono
      nerd-fonts.symbols-only emacs-all-the-icons-fonts lora

      aspell
      aspellDicts.en-computers
      aspellDicts.en
      aspellDicts.en-science

      # Misc.
      pinentry-gnome3
      x11_ssh_askpass
      xdg-utils
      acpilight
      pfetch
      libnotify
      htop
      minify
      python3Packages.adblock

      (pkgs.writeShellScriptBin "help"
        ''
  #!/usr/bin/env sh
  # Portable, colored, nicely aligned alias list

  # Generate uncolored alias pairs
  aliases=$(cat <<'EOF'
  ${let aliases = config.programs.zsh.shellAliases;
    in lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value:
      "${name} -> ${value}"
    ) aliases)}
  EOF
                               )

  # Align and color using awk
  echo "$aliases" | awk '
  BEGIN {
      GREEN="\033[0;32m";
      YELLOW="\033[0;33m";
      RESET="\033[0m";
      maxlen=0;
                 }
  {
      # Split line on " -> "
      split($0, parts, / -> /);
      name[NR]=parts[1];
      cmd[NR]=parts[2];
      if(length(parts[1])>maxlen) maxlen=length(parts[1]);
  }
  END {
      for(i=1;i<=NR;i++) {
          # printf with fixed width for alias name
          printf "%s%-*s%s -> %s%s%s\n", GREEN, maxlen, name[i], RESET, YELLOW, cmd[i], RESET;
          }
  }'
  '')

      (writeShellScriptBin "remote-build"
        ''
  #!/bin/bash
  nixos-rebuild --sudo --ask-sudo-password --target-host "$1" switch --flake $HOME/monorepo#spontaneity
  ''
      )
      (writeShellScriptBin "install-vps"
        ''
  #!/bin/bash
  nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config $HOME/monorepo/nix/systems/spontaneity/hardware-configuration.nix --flake $HOME/monorepo/nix#spontaneity --target-host "$1"
          '')
      (writeShellScriptBin "secrets"
        ''
  #!/bin/bash
  cd "$HOME/secrets"
  git pull # repo is over LAN
  stow */ # manage secrets with gnu stow
  cd "$HOME"
          '')
      (writeShellScriptBin "spontaneity-ci"
        ''
  #!/bin/bash
  nixos-rebuild build-vm --flake $HOME/monorepo/nix#spontaneity && QEMU_OPTS="-serial stdio" ./result/bin/run-spontaneity-vm 2>&1 | tee vm-boot.log'')
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
xdg.mimeApps = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    defaultApplications = {
      "x-scheme-handler/mailto" = "emacsclient-mail.desktop";
      "text/html" = "org.qutebrowser.qutebrowser.desktop";
      "text/xml" = "org.qutebrowser.qutebrowser.desktop";
      "application/xhtml+xml" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/about" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/unknown" = "org.qutebrowser.qutebrowser.desktop";
    };
  };

  programs.bash.enable = true;
  fonts.fontconfig.enable = true;
}
# User:1 ends here
