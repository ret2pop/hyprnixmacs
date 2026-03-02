{ lib, config, ... }:
{
  enable = lib.mkDefault config.monorepo.profiles.server.enable;
  registrationUrl = "localhost";

  settings = {
    homeserver.url = "https://matrix.nullring.xyz";
    homserver.domain = "matrix.nullring.xyz";
  };
}
