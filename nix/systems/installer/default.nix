{ pkgs, config, ... }:
let
  commits = ./commits.nix;
in
{
  imports = [
    ../../modules/default.nix
  ];

  monorepo.profiles.home.enable = false;
  monorepo.vars.userName = "nixos";

  users.extraUsers.root.password = "nixos";
  users.users = {
    "${config.monorepo.vars.userName}" = {
      packages = with pkgs; [
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
if [ ! -d "$HOME/toughnix/" ]; then
  git clone https://git.nullring.xyz/monorepo.git
  cd monorepo
  git checkout "${commits.monorepoCommitHash}"
fi
vim "$HOME/monorepo/nix/modules/default.nix"
vim "$HOME/monorepo/nix/modules/vars.nix"
sudo nix --experimental-features "nix-command flakes" run "github:nix-community/disko/${commits.diskoCommitHash}" -- --mode destroy,format,mount "$HOME/monorepo/nix/systems/desktop/sda-simple.nix"
cd /mnt
sudo nixos-install --flake $HOME/monorepo/nix#continuity
sudo cp $HOME/monorepo "/mnt/home/$(ls /mnt/home/)/"
echo "rebooting..."; sleep 3; reboot
'')
      ];
    };
  };

  systemd = {
    services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };
}
