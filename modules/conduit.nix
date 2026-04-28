# [[file:../../config/nix.org::*Conduit][Conduit:1]]
{ config, lib, ... }:
let
  livekitListenPort = 8443;
  # secrets.yaml
  livekit_secret = "livekit_secret";
  conduit_secret = "conduit_secrets";
in
{
  sops.secrets = lib.mkIf config.services.matrix-conduit.enable {
    "${livekit_secret}" = lib.mkIf config.services.livekit.enable {
      format = "yaml";
      mode = "0444";
    };

    "${conduit_secret}" = {
      format = "yaml";
    };
  };

  services.matrix-conduit = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    secretFile = "/run/secrets/${conduit_secret}";
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


  services.livekit = {
    enable = lib.mkDefault (config.services.matrix-conduit.enable || config.services.matrix-synapse.enable);
    keyFile = "/run/secrets/${livekit_secret}";
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
        node_ip = "66.42.84.130";
        tcp_port = 7881;
        udp_port = 7882;
      };
    };
  };

  services.lk-jwt-service = {
    enable = lib.mkDefault config.services.livekit.enable;
    port = 6495;
    livekitUrl = "wss://livekit.${config.monorepo.vars.orgHost}";
    keyFile = "/run/secrets/${livekit_secret}";
  };

  # TODO: split into conduit and livekit
  networking.firewall.allowedTCPPorts = lib.mkIf config.services.matrix-conduit.enable [ 8448 7881 5349 livekitListenPort ];

  # this is fine though
  networking.firewall.allowedUDPPorts = lib.mkIf config.services.livekit.enable [ 7882 3478 ];
  networking.firewall.allowedUDPPortRanges = lib.mkIf config.services.livekit.enable [
    { from = 49152; to = 65535; }
  ];

  networking.domains.subDomains."matrix.${config.monorepo.vars.orgHost}" = lib.mkIf config.services.matrix-conduit.enable {};
  networking.domains.subDomains."livekit.${config.monorepo.vars.orgHost}" = lib.mkIf config.services.livekit.enable {};

  services.nginx.virtualHosts."matrix.${config.monorepo.vars.orgHost}" = lib.mkIf config.services.matrix-conduit.enable {
    enableACME = lib.mkDefault config.monorepo.profiles.server.enable;
    forceSSL = true;
    listen = [
      {
        addr = "0.0.0.0";
        port = 443;
        ssl = true;
      }
      {
        addr = "[::]";
        port = 443;
        ssl = true;
      }
      {
        addr = "0.0.0.0";
        port = 8448;
        ssl = true;
      }
      {
        addr = "[::]";
        port = 8448;
        ssl = true;
      }
    ];
    locations."/_matrix/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.matrix-conduit.settings.global.port}";
      extraConfig = ''
              proxy_set_header Host $host;
              proxy_buffers 32 16k;
              proxy_read_timeout 5m;
            '';
    };

    locations."= /.well-known/matrix/server" = {
      extraConfig = ''
        default_type application/json;
        add_header Content-Type application/json;
        add_header Access-Control-Allow-Origin *;
      '';
      
      return = ''200 '{"m.server": "matrix.${config.monorepo.vars.orgHost}:443"}' ''; 
    };

    locations."/.well-known/matrix/client" = {
      extraConfig = ''
      default_type application/json;
      add_header Access-Control-Allow-Origin *;
    '';

      return = "200 '{\"m.homeserver\": {\"base_url\": \"https://matrix.${config.monorepo.vars.orgHost}\"}, \"org.matrix.msc4143.rtc_foci\": [{\"type\": \"livekit\", \"livekit_service_url\": \"https://matrix.${config.monorepo.vars.orgHost}:${toString livekitListenPort}\"}]}'";
    };

    extraConfig = ''
            merge_slashes off;
          '';
  };


  services.nginx.virtualHosts."matrix.${config.monorepo.vars.orgHost}-livekit" = lib.mkIf config.services.livekit.enable {
    serverName = "matrix.${config.monorepo.vars.orgHost}";
    listen = [
      { 
        addr = "0.0.0.0"; 
        port = livekitListenPort;
        ssl = true; 
      }
      {
        addr = "[::]";
        port = livekitListenPort;
        ssl = true;
      }
    ];
    addSSL = true;
    enableACME = false;
    forceSSL = false;
    useACMEHost = "matrix.${config.monorepo.vars.orgHost}";
    
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.lk-jwt-service.port}"; 
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };

  services.nginx.virtualHosts."livekit.${config.monorepo.vars.orgHost}" = lib.mkIf config.services.livekit.enable {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.livekit.settings.port}";
      proxyWebsockets = true;
      extraConfig = ''
              proxy_read_timeout 3600s;
              proxy_send_timeout 3600s;

              # Standard headers for LiveKit
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";

              # --- CORS CONFIGURATION START ---
              # 1. Allow all origins (including app.element.io)
              add_header 'Access-Control-Allow-Origin' '*' always;
              
              # 2. Allow specific methods (POST is required for /sfu/get)
              add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
              
              # 3. Allow headers (Content-Type is crucial for JSON)
              add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
              
              # 4. Handle the OPTIONS preflight request immediately
              if ($request_method = 'OPTIONS') {
                 add_header 'Access-Control-Allow-Origin' '*' always;
                 add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
                 add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
                 add_header 'Access-Control-Max-Age' 1728000;
                 add_header 'Content-Type' 'text/plain; charset=utf-8';
                 add_header 'Content-Length' 0;
                 return 204;
                  }
              # --- CORS CONFIGURATION END ---
            '';
    };
  };
}
# Conduit:1 ends here
