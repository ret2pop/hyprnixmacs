# [[file:../../config/nix.org::*Gitolite][Gitolite:1]]
{ lib, config, ... }:
{
  services.gitolite = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    description = "My Gitolite User";
    adminPubkey = config.monorepo.vars.sshKey;
  };
}
# Gitolite:1 ends here
