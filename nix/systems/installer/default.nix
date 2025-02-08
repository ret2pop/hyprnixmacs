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
      PasswordAuthentication = true;
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

SYSTEM=continuity
DRIVE=sda

set -euo pipefail
if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR! $(basename "$0") should be run as a regular user"
  exit 1
fi
ping -q -c1 google.com &>/dev/null && echo "online! Proceeding with the installation..." || nmtui
cd
if [ ! -d "$HOME/monorepo/" ]; then
  git clone https://git.nullring.xyz/monorepo.git
  cd monorepo
  git checkout "${commits.monorepoCommitHash}"
fi
vim "$HOME/monorepo/nix/systems/$SYSTEM/default.nix"
sudo nix --experimental-features "nix-command flakes" run "github:nix-community/disko/${commits.diskoCommitHash}" -- --mode destroy,format,mount "$HOME/monorepo/nix/disko/$DRIVE-simple.nix"
cd /mnt
sudo nixos-install --flake "$HOME/monorepo/nix#$SYSTEM"
sudo cp -r $HOME/monorepo "/mnt/home/$(ls /mnt/home/)/"
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
