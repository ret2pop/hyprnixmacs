{ lib, config, ... }:
{
  services.gotosocial = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
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
