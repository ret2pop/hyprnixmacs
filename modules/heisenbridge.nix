{ lib, config, ... }:
{
  services.heisenbridge = {
    enable = true;
    registrationUrl = "http://localhost:6167";
    owner = "@ret2pop:matrix.nullring.xyz";
    homeserver = "http://localhost:6167";
  };
}
