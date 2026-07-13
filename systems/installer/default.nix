# [[file:../../../config/nix.org::*ISO Default Profile][ISO Default Profile:1]]
{ pkgs, lib, modulesPath, disko, monorepoSelf ? null, self, testSystem ? null, ... }:
let
  commits = {
    diskoCommitHash = disko.rev or "dirty";
    monorepoCommitHash = if monorepoSelf != null then (monorepoSelf.rev or "dirty") else (self.rev or "dirty");
    monorepoUrl = "https://github.com/ret2pop/monorepo";
  };
  testSystemStr = if testSystem != null then testSystem else "";
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

TEST_SYSTEM="${testSystemStr}"

if [ -n "$TEST_SYSTEM" ]; then
  echo "=== AUTOMATED TEST MODE ==="
  echo "Target system: $TEST_SYSTEM"
  SYSTEM="$TEST_SYSTEM"
  
  echo "testpass" > /tmp/secret.key
else
  # INTERACTIVE MODE
  ping -q -c1 google.com &>/dev/null && echo "online! Proceeding with the installation..." || nmtui || true

  if [ ! -d "$HOME/monorepo/" ]; then
    git clone ${commits.monorepoUrl} --recurse-submodules
    cd "$HOME/monorepo"
    git checkout "${commits.monorepoCommitHash}"
    cd "$HOME"
  fi

  gum style --border normal --margin "1" --padding "1 2" "Enter a password for the encrypted disk. If you're not installing a profile with an encrypted disk, you can leave this blank."
  echo "$(gum input --password)" > /tmp/secret.key

  if [ -n "''${1:-}" ]; then
    SYSTEM="$1"
  else
    gum style --border normal --margin "1" --padding "1 2" "Choose a system to install or select \`New\` in order to create a new system."
    SYSTEM="$( { find "$HOME/monorepo/nix/systems" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | grep -v -E 'installer'; echo "New"; } | gum choose )"

    if [[ "$SYSTEM" == "New" ]]; then
      gum style --border normal --margin "1" --padding "1 2" "Choose a system name"
      SYSTEM="$(gum input --placeholder "system name")"
    fi
  fi

  if [ ! -d "$HOME/monorepo/nix/systems/$SYSTEM" ]; then
    mkdir -p "$HOME/monorepo/nix/systems/$SYSTEM"
    cp "$HOME/monorepo/nix/systems/continuity/home.nix" "$HOME/monorepo/nix/systems/$SYSTEM/home.nix"
    cat > "$HOME/monorepo/nix/systems/$SYSTEM/default.nix" <<EOF
{ ... }:
{
  imports = [
    ../common.nix
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

    sed -i "/hostnames = \[/,/];/ s/];/  \"$SYSTEM\"\n    ];/" "$HOME/monorepo/nix/flake.nix"
  fi
fi

# Target the submodule directly so Flake evaluation sees the untracked/modified files
cd "$HOME/monorepo/nix" && git add . && cd "$HOME"

# Query the configured drive directly from the flake
ORIGINAL_DRIVE=$(nix --extra-experimental-features 'nix-command flakes' eval --raw "$HOME/monorepo/nix#nixosConfigurations.$SYSTEM.config.monorepo.vars.drive")

# Evaluate the Disko spec to a file
nix --extra-experimental-features 'nix-command flakes' eval "$HOME/monorepo/nix#evalDisko.$SYSTEM" > "$HOME/drive.nix"

if [ -n "$TEST_SYSTEM" ]; then
  # Shim the original target drive with the VM's blank block device
  echo "Test Mode: Shimming drive $ORIGINAL_DRIVE to /dev/vdb..."
  sed -i "s|$ORIGINAL_DRIVE|/dev/vdb|g" "$HOME/drive.nix"
else
  # Interactive mode confirmation
  gum style --border normal --margin "1" --padding "1 2" "Formatting the drive ($ORIGINAL_DRIVE) is destructive!"
  if gum confirm "Are you sure you want to continue?"; then
      echo "Proceeding..."
  else
      echo "Aborting."
      exit 1
  fi
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
sudo chown -R $(stat -c '%u:%g' /mnt/home/$target_user) "/mnt/home/$target_user/monorepo"

if [ -n "$TEST_SYSTEM" ]; then
  echo "Test installation complete. Powering off safely..."
else
  echo "rebooting..."; sleep 3; reboot
fi
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
