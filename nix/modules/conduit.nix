{ config, lib, ... }:
{
  services.matrix-conduit = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    secretFile = "/run/secrets/conduit_secrets";
    settings.global = {
      server_name = "matrix.${config.monorepo.vars.orgHost}";
      trusted_servers = [
        "matrix.org"
        "nixos.org"
        "conduit.rs"
      ];
      address = "0.0.0.0";
      port = 6167;
      allow_registration = false;
    };
  };
  services.lk-jwt-service = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    port = 6495;
    livekitUrl = "wss://livekit.nullring.xyz";
    keyFile = "/run/secrets/livekit_secret";
  };
  services.livekit = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    keyFile = "/run/secrets/livekit_secret";
    settings = {
      port = 7880;
      turn = {
        enabled = true;
        domain = "livekit.${config.monorepo.vars.orgHost}";
        cert_file = "/var/lib/acme/livekit.${config.monorepo.vars.orgHost}/fullchain.pem";
        key_file = "/var/lib/acme/livekit.${config.monorepo.vars.orgHost}/key.pem";
        tls_port = 5349;
        udp_port = 3478;
      };

      rtc = {
        use_external_ip = true;
        tcp_port = 7881;
        udp_port = 7882;
        port_range_start = 50000;
        port_range_end = 60000;
      };
    };
  };
}
