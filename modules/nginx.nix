{ pkgs, config, lib, monorepoSelf ? null, ... }:
{
  services.nginx = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    user = "nginx";
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedBrotliSettings = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = false;
    virtualHosts = {
      "${config.monorepo.vars.remoteHost}" = lib.mkIf (monorepoSelf != null) {
        serverName = "${config.monorepo.vars.remoteHost}";
        serverAliases = [ "${config.monorepo.vars.internetName}.${config.monorepo.vars.orgHost}" ];
        root = "${monorepoSelf.packages.${pkgs.system}.website}";
        addSSL = true;
        enableACME = true;
        locations."/" = {
          extraConfig = ''
      add_header Cache-Control "no-cache, must-revalidate";
      expires off;
    '';
        };
        locations."~* \\.(?:woff2|ttf|otf|eot|woff|ico|css|js|gif|jpe?g|png|svg|mp3|mp4|iso|webmanifest)$" = {
          extraConfig = ''
      add_header Cache-Control "public, max-age=31536000, immutable";
      access_log off;
    '';
        };
      };

      # the port comes from ssh tunnelling
      "music.${config.monorepo.vars.remoteHost}" = lib.mkIf config.monorepo.profiles.server.enable {
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
    };
  };

  networking.firewall.allowedTCPPorts = lib.mkIf config.services.nginx.enable [ 80 443 ];

  networking.domains.subDomains = lib.mkIf config.services.nginx.enable {
    "${config.monorepo.vars.remoteHost}" = {};
    "${config.monorepo.vars.orgHost}" = {};
    "${config.monorepo.vars.internetName}.${config.monorepo.vars.orgHost}" = {};
  };
}
