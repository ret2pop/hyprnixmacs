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

cd "$HOME"

ping -q -c1 google.com &>/dev/null && echo "online! Proceeding with the installation..." || nmtui

if [ ! -d "$HOME/monorepo/" ]; then
  git clone ${commits.monorepoUrl}
  cd "$HOME/monorepo"
  git checkout "${commits.monorepoCommitHash}"
  cd "$HOME"
fi

gum style --border normal --margin "1" --padding "1 2" "Enter a password for the encrypted disk. If you're not installing a profile with an encrypted disk, you can leave this blank."
echo "$(gum input --password)" > /tmp/secret.key

gum style --border normal --margin "1" --padding "1 2" "Choose a system to install or select \`new\` in order to create a new system."

SYSTEM="$(gum choose $(find "$HOME/monorepo/nix/systems" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | grep -v -E 'installer'; printf "New"))"

if [[ "$SYSTEM" == "New" ]]; then
  gum style --border normal --margin "1" --padding "1 2" "Choose a system name"
  SYSTEM="$(gum input --placeholder "system name")"

  gum style --border normal --margin "1" --padding "1 2" "Select a drive file or create a new drive file."
  DRIVE="$(gum choose $(find "$HOME/monorepo/nix/disko" -mindepth 1 -maxdepth 1 -type f -printf "%f\n"; printf "New"))"

  if [[ "$DRIVE" == "New" ]]; then
    gum style --border normal --margin "1" --padding "1 2" "Choose a name to call your drive file."
    DRIVE="$(gum input --placeholder "drive file name (ex: partition_scheme.nix)")"
  fi
fi


if [ ! -d "$HOME/monorepo/nix/systems/$SYSTEM" ]; then
  mkdir -p "$HOME/monorepo/nix/systems/$SYSTEM"
  cp "$HOME/monorepo/nix/systems/continuity/home.nix" "$HOME/monorepo/nix/systems/$SYSTEM/home.nix"
  cat > "$HOME/monorepo/nix/systems/$SYSTEM/default.nix" <<EOF
{ ... }:
{
  imports = [
    ../includes.nix
    ../../disko/$DRIVE
  ];
  # CHANGEME
  config.monorepo.vars.drive = "/dev/sda";
}
EOF

  gum style --border normal --margin "1" --padding "1 2" "Edit the system default.nix with options."
  gum input --placeholder "Press Enter to continue" >/dev/null
  vim "$HOME/monorepo/nix/systems/$SYSTEM/default.nix"

  gum style --border normal --margin "1" --padding "1 2" "Edit the home default.nix with options."
  gum input --placeholder "Press Enter to continue" >/dev/null
  vim "$HOME/monorepo/nix/systems/$SYSTEM/home.nix"

  sed -i "/hostnames = \[/,/];/ s/];/  \"$1\"\n    ];/" "$HOME/monorepo/nix/flake.nix"

  if [ ! -f "$HOME/monorepo/nix/disko/$DRIVE" ]; then
    cp "$HOME/monorepo/nix/disko/drive-simple.nix" "$HOME/monorepo/nix/disko/$DRIVE"
    gum style --border normal --margin "1" --padding "1 2" "Edit the drive file with your preferred partitioning scheme."
    gum input --placeholder "Press Enter to continue" >/dev/null
    vim "$HOME/monorepo/nix/disko/$DRIVE"
  fi
  cd "$HOME/monorepo" && git add . && cd "$HOME"
fi

nix --extra-experimental-features 'nix-command flakes' eval "$HOME/monorepo/nix#evalDisko.$SYSTEM" > "$HOME/drive.nix"

gum style --border normal --margin "1" --padding "1 2" "Formatting the drive is destructive!"
if gum confirm "Are you sure you want to continue?"; then
    echo "Proceeding..."
else
    echo "Aborting."
    exit 1
fi

sudo nix --experimental-features "nix-command flakes" run "github:nix-community/disko/${commits.diskoCommitHash}" -- --mode destroy,format,mount "$HOME/drive.nix"

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
