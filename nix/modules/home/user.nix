{ lib, config, pkgs, ... }:
{
  home = {
    activation.startup-files = lib.hm.dag.entryAfter [ "installPackages" ] ''
    if [ ! -d "/home/${config.monorepo.vars.userName}/email/${config.monorepo.vars.internetName}/" ]; then
      mkdir -p /home/${config.monorepo.vars.userName}/email/${config.monorepo.vars.internetName}/
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
      # kiwix kiwix-tools
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
      # octaveFull
      vesktop grim swww vim telegram-desktop qwen-code fluffychat jami

      # Sound/media
      pavucontrol alsa-utils imagemagick ffmpeg helvum

      # Net
      curl rsync git iamb ungoogled-chromium

      # Tor
      torsocks tor-browser

      # For transfering secrets onto new system
      magic-wormhole stow

      # fonts
      nerd-fonts.iosevka noto-fonts noto-fonts-cjk-sans noto-fonts-emoji fira-code font-awesome_6 victor-mono
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
nixos-rebuild --sudo --ask-sudo-password --target-host "$1" switch --flake $HOME/monorepo/nix#spontaneity
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
  fonts.fontconfig.enable = true;
}
