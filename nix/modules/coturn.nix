{ lib, config, ... }:
{
  services.coturn = {
    enable = false;
    use-auth-secret = true;
    listening-ips = [ "0.0.0.0" ];
    cert = "/var/lib/acme/matrix.${config.monorepo.vars.orgHost}/fullchain.pem";
    static-auth-secret-file = "/run/secrets/coturn_secret";
  };
}
