# [[file:../../config/nix.org::*GoToSocial][GoToSocial:1]]
{ lib, config, ... }:
{
  services.gotosocial = {
    enable = lib.mkDefault false;
    setupPostgresqlDB = true;
    settings = {
      application-name = "Nullring GoToSocial Instance";
      host = "gotosocial.${config.monorepo.vars.orgHost}";
      protocol = "https";
      bind-address = "127.0.0.1";
      port = 8080;
    };
  };
}
# GoToSocial:1 ends here
