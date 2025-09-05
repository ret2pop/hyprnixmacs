{ pkgs, config, lib, modulesPath, ... }:
let
  commits = import ./commits.nix;
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  networking = {
    networkmanager = {
      enable = true;
    };
    firewall = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ ];
    };
    wireless.enable = false;
  };
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = null;
      UseDns = true;
      PermitRootLogin = lib.mkForce "prohibit-password";
    };
  };

  users.extraUsers.root.password = "nixos";
  users.extraUsers.nixos.password = "nixos";
  users.users = {
    root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICts6+MQiMwpA+DfFQxjIN214Jn0pCw/2BDvOzPhR/H2 preston@continuity-dell"
    ];
    nixos = {
      packages = with pkgs; [
        git
        curl
        gum
        (writeShellScriptBin "nix_installer"
          ''
#!/usr/bin/env bash

set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR! $(basename "$0") should be run as a regular user"
  exit 1
fi

if [ -z "$SYSTEM" ]; then
    SYSTEM=continuity
fi

if [ -z "$DRIVE" ]; then
    DRIVE=sda-simple
fi

ping -q -c1 google.com &>/dev/null && echo "online! Proceeding with the installation..." || nmtui

cd "$HOME"

if [ ! -d "$HOME/monorepo/" ]; then
  git clone https://git.nullring.xyz/monorepo.git
  cd monorepo
  git checkout "${commits.monorepoCommitHash}"
fi


if [ ! -d "$HOME/monorepo/nix/systems/$SYSTEM" ]; then
  mkdir -p "$HOME/monorepo/nix/systems/$SYSTEM"
  cp "$HOME/monorepo/nix/systems/continuity/home.nix" "$HOME/monorepo/nix/systems/$SYSTEM/home.nix"
  cat > "$HOME/monorepo/nix/systems/$SYSTEM/default.nix" <<EOF
{ ... }:
{
  imports = [
    ../../modules/default.nix
    ../../disko/$DRIVE.nix
    ../home.nix
  ];
}
EOF

  gum style --border normal --margin "1" --padding "1 2" "Edit the system default.nix with options."
  gum input --placeholder "Press Enter to continue" >/dev/null
  vim "$HOME/monorepo/nix/systems/$SYSTEM/default.nix"

  sed -i "/mkConfigs \[/,/\]/ s/^\(\s*\)\]/\1  \"$SYSTEM\"\n\1]/" "$HOME/monorepo/nix/flake.nix"
fi

if [ ! -f "$HOME/monorepo/nix/disko/$DRIVE.nix" ]; then
  cp "$HOME/monorepo/nix/disko/sda-simple.nix" "$HOME/monorepo/nix/disko/$DRIVE.nix"
  gum style --border normal --margin "1" --padding "1 2" "Edit the drive file with your preferred partitioning scheme."
  gum input --placeholder "Press Enter to continue" >/dev/null
  vim "$HOME/monorepo/nix/disko/$DRIVE.nix"
fi

cd "$HOME/monorepo" && git add . && cd "$HOME"

gum style --border normal --margin "1" --padding "1 2" "Formatting the drive is destructive!"
if gum confirm "Are you sure you want to continue?"; then
    echo "Proceeding..."
else
    echo "Aborting."
    exit 1
fi

sudo nix --experimental-features "nix-command flakes" run "github:nix-community/disko/${commits.diskoCommitHash}" -- --mode destroy,format,mount "$HOME/monorepo/nix/disko/$DRIVE.nix"
cd /mnt
sudo nixos-install --flake "$HOME/monorepo/nix#$SYSTEM"

target_user="$(ls /mnt/home | head -n1)"
if [ -z "$target_user" ]; then
    echo "No user directories found in /mnt/home"
    exit 1
fi
sudo cp -r "$HOME/monorepo" "/mnt/home/$target_user/"

echo "rebooting..."; sleep 3; reboot
'')
      ];
    };
  };

  systemd = {
    services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };
}
