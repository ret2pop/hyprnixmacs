{ lib, config, ... }:
{
  services.gitolite = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    description = "My Gitolite User";
    adminPubkey = config.monorepo.vars.sshKey;
  };
}
