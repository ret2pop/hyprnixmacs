# [[file:../../../config/nix.org::*ISO Default Profile][ISO Default Profile:1]]
{ pkgs, lib, modulesPath, disko, monorepoSelf ? null, self, testHostname ? null, targetDevice ? "/dev/sda", ... }:
let
  commits = {
    diskoCommitHash = disko.rev or "dirty";
    monorepoCommitHash = if monorepoSelf != null then (monorepoSelf.rev or "dirty") else (self.rev or "dirty");
    monorepoUrl = "https://github.com/ret2pop/monorepo";
  };

  targetSystemName = if testHostname != null then testHostname else "";

  bundledMonorepo = pkgs.fetchgit {
    url = commits.monorepoUrl;
    rev = if commits.monorepoCommitHash != "dirty" then commits.monorepoCommitHash else "HEAD";
    leaveDotGit = true;
    fetchSubmodules = true;
    hash = "sha256-31S+gb9WAky5ymumqf4aoWFHpSKqpgZVCFHHmVIXKLU=";
  };
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

if [ ! -d "$HOME/monorepo/" ]; then
  echo "Staging the bundled monorepo (with git history)..."
  cp -rT ${bundledMonorepo} "$HOME/monorepo"
  chmod -R u+w "$HOME/monorepo"
fi

if [ -n "$TARGET_SYSTEM" ]; then
  echo -n "" > /tmp/secret.key
  SYSTEM="$TARGET_SYSTEM"
else
  gum style --border normal --margin "1" --padding "1 2" "Enter a password for the encrypted disk. Leave blank if not using encryption."
  echo -n "$(gum input --password)" > /tmp/secret.key
  
  gum style --border normal --margin "1" --padding "1 2" "Choose a system to install:"
  SYSTEM="$(gum choose $(find "$HOME/monorepo/nix/systems" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | grep -v -E 'installer'))"
fi

# Evaluate the dynamic disk configuration
nix --extra-experimental-features 'nix-command flakes' eval "path:$HOME/monorepo/nix#evalDisko.$SYSTEM" > "$HOME/drive.nix"

if [ -n "$TARGET_SYSTEM" ]; then
  echo ">>> TEST MODE: Hot-swapping target bare-metal drive to VM virtual drive (/dev/vdb)..."
  # Safely rewrite the dynamic disk path to target the QEMU block device
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

# Format the drive
sudo ${disko.packages.${pkgs.system}.disko}/bin/disko --mode destroy,format,mount --yes-wipe-all-disks "$HOME/drive.nix"

cd /mnt

if [ -n "$TARGET_SYSTEM" ]; then
  echo ">>> TEST MODE: Executing dry-run of nix build to verify build phase..."
  
  # --dry-run forces full evaluation and verifies derivations without doing the heavy I/O file copy
  nix --extra-experimental-features 'nix-command flakes' build "path:$HOME/monorepo/nix#nixosConfigurations.$SYSTEM.config.system.build.toplevel" --dry-run
  
  echo ">>> TEST MODE: Dry-run successful! Aborting early to prevent QEMU I/O core dumps."
  echo ">>> System is completely verified. Exiting test safely."

  exit 0
fi

# --- BARE METAL ONLY BELOW THIS LINE ---
sudo nixos-install --flake "path:$HOME/monorepo/nix#$SYSTEM"

echo "Resolving primary target user..."
TARGET_USER=$(nix eval --extra-experimental-features 'nix-command flakes' "path:$HOME/monorepo/nix#nixosConfigurations.$SYSTEM.config.users.users" --apply 'u: builtins.head (builtins.attrNames (builtins.filterAttrs (n: v: v.isNormalUser) u))' --raw 2>/dev/null || echo "")

if [ -z "$TARGET_USER" ]; then
    echo "Could not resolve a normal user from the flake configuration. Falling back to root."
    TARGET_USER="root"
fi

if [ "$TARGET_USER" == "root" ]; then
    TARGET_HOME="/root"
else
    TARGET_HOME="/home/$TARGET_USER"
fi

echo "Transferring the monorepo to the new system for user: $TARGET_USER..."
sudo cp -r "$HOME/monorepo" "/mnt/home/$TARGET_USER/"
sudo nixos-enter --root /mnt -c "chown -R $TARGET_USER:users /home/$TARGET_USER/monorepo"

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
