# [[file:../../config/nix.org::*AutoUpdater][AutoUpdater:1]]
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.monorepo.profiles.workstation.enable {
    systemd.timers.monorepo-flake-updater = {
      description = "Timer for Automated Monorepo Flake Updates";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };

    systemd.services.monorepo-flake-updater = {
      description = "Automated Flake Update, Check, and Patch for Monorepo";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        User = "${config.monorepo.vars.userName}";
      };
      environment = {
        HOME = "/home/${config.monorepo.vars.userName}";
      };

      path = with pkgs; [ git nix coreutils curl ];
      script = ''
  # Exit immediately if any command fails
  set -euo pipefail

  API_URL="https://channels.nixos.org/nixos-unstable/git-revision"
  if ! curl --silent --head --location --fail "$API_URL" > /dev/null; then
    echo "No internet or NixOS API is down. Aborting."
    exit 0
  fi

  LATEST_REV=$(curl --silent --location "$API_URL")
  STATE_FILE="$HOME/.local/state/monorepo-updater-rev"
  
  mkdir -p "$(dirname "$STATE_FILE")"
  
  if [ ! -f "$STATE_FILE" ]; then
    echo "First run. Initializing baseline hash ($LATEST_REV) and exiting."
    echo "$LATEST_REV" > "$STATE_FILE"
    exit 0
  fi

  if [ "$(cat "$STATE_FILE")" = "$LATEST_REV" ]; then
    echo "Channel has not bumped since last check ($LATEST_REV). Aborting."
    exit 0
  fi

  echo "$LATEST_REV" > "$STATE_FILE"

  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEMP_DIR"' EXIT
  cd "$TEMP_DIR"

  echo "Cloning repository..."
  git clone git://git.nullring.xyz/monorepo.git --recurse-submodules
  
  cd monorepo/nix

  # Create and checkout [date]-bump branch INSIDE the submodule
  DATE=$(date +%Y-%m-%d)
  BRANCH_NAME="''${DATE}-bump"
  git checkout -b "$BRANCH_NAME"

  echo "Running nix flake update..."
  nix flake update --extra-experimental-features "nix-command flakes"

  # If the channel bumped, but flake update didn't change flake.lock, exit
  if git diff --quiet flake.lock; then
    echo "No actual updates to flake.lock. Aborting."
    exit 0
  fi

  nix flake check --extra-experimental-features "nix-command flakes"

  git config user.name "NixOS Updater"
  git config user.email "updater@localhost"
  git add flake.lock
  git commit -m "chore: automated flake update ''${DATE}"

  PATCH_DIR="$HOME/monorepo/nix"
  mkdir -p "$PATCH_DIR"
  PATCH_FILE="$PATCH_DIR/0000-flake-update-''${DATE}.patch"
  
  git format-patch -1 HEAD --stdout > "$PATCH_FILE"
  echo "Successfully checked updates and created patch at $PATCH_FILE"
'';
    };
  };
}
# AutoUpdater:1 ends here
