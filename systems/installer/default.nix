# [[file:../../../config/nix.org::*ISO Default Profile][ISO Default Profile:1]]
{ pkgs, lib, modulesPath, disko, self, testHostname ? null, targetDevice ? "/dev/sda", ... }:
let
  targetSystemName = if testHostname != null then testHostname else "";
  bundledNix = self;
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];
  
  networking = {
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ ];
    };
    wireless.enable = lib.mkForce false;
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

  users.users = {
    root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICts6+MQiMwpA+DfFQxjIN214Jn0pCw/2BDvOzPhR/H2 preston@continuity-dell"
    ];

    nixos = {
      packages = with pkgs; [
        gitFull
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
TARGET_SYSTEM="${targetSystemName}"

if [ -n "$TARGET_SYSTEM" ]; then
  echo ">>> TEST MODE DETECTED. Target system: $TARGET_SYSTEM"
else
  ping -q -c1 google.com &>/dev/null && echo "online! Proceeding with the installation..." || nmtui
fi

# ---------------------------------------------------------
# 1. STAGE FILES
# ---------------------------------------------------------

if [ ! -d "$HOME/nixmacs/" ]; then
  echo "Staging nixmacs (self) strictly for evaluation..."
  cp -rT ${bundledNix} "$HOME/nixmacs"
  chmod -R u+w "$HOME/nixmacs"

  cd "$HOME/nixmacs"
  git init -q
  git config user.email "ci@nixos.local" && git config user.name "NixOS CI"
  git add . && git commit -q -m "CI: Temporary mock for evaluation"
  cd "$HOME"
fi

# ---------------------------------------------------------
# 2. EVALUATE & FORMAT
# ---------------------------------------------------------

if [ -n "$TARGET_SYSTEM" ]; then
  echo -n "FakeExtremelySecurePassword3820$" > /tmp/secret.key
  SYSTEM="$TARGET_SYSTEM"
else
  gum style --border normal --margin "1" --padding "1 2" "Enter a password for the encrypted disk. Leave blank if not using encryption."
  echo -n "$(gum input --password)" > /tmp/secret.key
  
  gum style --border normal --margin "1" --padding "1 2" "Choose a system to install:"
  SYSTEM="$(gum choose $(find "$HOME/nixmacs/systems" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | grep -v -E 'installer'))"
fi

nix --extra-experimental-features 'nix-command flakes' eval "path:$HOME/nixmacs#evalDisko.$SYSTEM" > "$HOME/drive.nix"

if [ -n "$TARGET_SYSTEM" ]; then
  echo ">>> TEST MODE: Hot-swapping target bare-metal drive to VM virtual drive (/dev/vdb)..."
  sed -i "s|${targetDevice}|/dev/vdb|g" "$HOME/drive.nix"
fi

if [ -z "$TARGET_SYSTEM" ]; then
  gum style --border normal --margin "1" --padding "1 2" "Formatting the drive is destructive!"
  if gum confirm "Are you sure you want to continue?"; then
      echo "Proceeding..."
  else
      echo "Aborting."
      exit 1
  fi
fi

sudo ${disko.packages.${pkgs.system}.disko}/bin/disko --mode destroy,format,mount --yes-wipe-all-disks "$HOME/drive.nix"

cd /mnt

if [ -n "$TARGET_SYSTEM" ]; then
  echo ">>> TEST MODE: Executing dry-run of nix build..."
  nix --extra-experimental-features 'nix-command flakes' build "path:$HOME/nixmacs#nixosConfigurations.$SYSTEM.config.system.build.toplevel" --dry-run
  echo ">>> TEST MODE: Dry-run successful! System verified. Exiting safely."
  exit 0
fi

sudo nixos-install --flake "path:$HOME/nixmacs#$SYSTEM"
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
# ISO Default Profile:1 ends here
