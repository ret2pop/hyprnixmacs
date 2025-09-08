#!/usr/bin/env bash
sed -i "/# add hostnames here/i \  \"$1\"" "$HOME/monorepo/nix/flake.nix"
sed -i "/# add hostnames here/i \  \"$1\"" "$HOME/monorepo/config/nix.org"

mkdir -p "$HOME/monorepo/nix/systems/$1"

cat > "$HOME/monorepo/nix/systems/$1/default.nix" <<EOF
{ ... }:
{
  imports = [
    ../includes.nix
    ../../disko/drive-simple.nix
  ];
  # CHANGEME
  config.monorepo.vars.drive = "/dev/sda";
}
EOF

cp "$HOME/monorepo/nix/systems/continuity/home.nix" "$HOME/monorepo/nix/systems/$1/home.nix"
