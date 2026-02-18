{ config, lib, ... }:
{
  services.nginx = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    user = "nginx";
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = false;

    gitweb = {
      enable = true;
      virtualHost = "${config.monorepo.vars.orgHost}";
    };

    virtualHosts = {
      "matrix.${config.monorepo.vars.orgHost}" = {
        enableACME = true;
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
          proxyPass = "http://127.0.0.1:6167";
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

          return = "200 '{\"m.homeserver\": {\"base_url\": \"https://matrix.${config.monorepo.vars.orgHost}\"}, \"org.matrix.msc4143.rtc_foci\": [{\"type\": \"livekit\", \"livekit_service_url\": \"https://matrix.${config.monorepo.vars.orgHost}:8443\"}]}'";
        };

        extraConfig = ''
          merge_slashes off;
        '';
      };

      "matrix.${config.monorepo.vars.orgHost}-livekit" = {
        serverName = "matrix.${config.monorepo.vars.orgHost}";
        listen = [
          { 
            addr = "0.0.0.0"; 
            port = 8443; 
            ssl = true; 
          }
          {
            addr = "[::]";
            port = 8443;
            ssl = true;
          }
        ];
        addSSL = true;
        enableACME = false;
        forceSSL = false;
        useACMEHost = "matrix.${config.monorepo.vars.orgHost}";
        
        locations."/" = {
          proxyPass = "http://127.0.0.1:6495"; 
          proxyWebsockets = true;
          extraConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    '';
        };
      };

      "livekit.${config.monorepo.vars.orgHost}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:7880";
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

      "ntfy.${config.monorepo.vars.remoteHost}" = {
        serverName = "ntfy.${config.monorepo.vars.remoteHost}";
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:2586";
          proxyWebsockets = true;
        };
      };

	    "${config.monorepo.vars.remoteHost}" = {
        serverName = "${config.monorepo.vars.remoteHost}";
        serverAliases = [ "${config.monorepo.vars.internetName}.${config.monorepo.vars.orgHost}" ];
	      root = "/var/www/${config.monorepo.vars.internetName}-website/";
	      addSSL = true;
	      enableACME = true;
	    };

      "git.${config.monorepo.vars.orgHost}" = {
        forceSSL = true;
        enableACME = true;
      };
      "list.${config.monorepo.vars.orgHost}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:9090";
          extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
        };
      };

      # the port comes from ssh tunnelling
      "music.${config.monorepo.vars.remoteHost}" = {
        addSSL = true;
        enableACME = true;
        basicAuthFile = config.sops.secrets."mpd_password".path;
        locations."/" = {
          proxyPass = "http://localhost:8000";
          extraConfig = ''
proxy_buffering off;
proxy_http_version 1.1;
proxy_set_header Connection "";
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_read_timeout 36000s;
'';
        };
      };

      "${config.monorepo.vars.orgHost}" = {
        serverName = "${config.monorepo.vars.orgHost}";
        root = "/var/www/nullring/";
        addSSL = true;
        enableACME = true;
      };

      "mail.${config.monorepo.vars.orgHost}" = {
        serverName = "mail.${config.monorepo.vars.orgHost}";
        root = "/var/www/dummy";
        addSSL = true;
        enableACME = true;
      };
    };
  };
}
