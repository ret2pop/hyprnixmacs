{ pkgs, config, ... }:
let
  commits = import ./commits.nix;
in
{
  users.extraUsers.root.password = "nixos";
  users.extraUsers.nixos.password = "nixos";
  users.users = {
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
ping -q -c1 google.com &>/dev/null && echo "online! Proceeding with the installation..." || nmtui
cd
if [ ! -d "$HOME/monorepo/" ]; then
  git clone --recurse-submodules https://git.nullring.xyz/monorepo.git
  cd monorepo
  git checkout "${commits.monorepoCommitHash}"
fi
vim "$HOME/monorepo/nix/systems/continuity/default.nix"
sudo nix --experimental-features "nix-command flakes" run "github:nix-community/disko/${commits.diskoCommitHash}" -- --mode destroy,format,mount "$HOME/monorepo/nix/modules/sda-simple.nix"
cd /mnt
sudo nixos-install --flake $HOME/monorepo/nix#continuity
sudo cp $HOME/monorepo "/mnt/home/$(ls /mnt/home/)/"
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
