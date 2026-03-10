{ pkgs, lib, config, ... }:
let
  serverName = "${config.monorepo.vars.ntfyUrl}";
  port = 2586;
  ntfySecret = config.monorepo.vars.ntfySecret;
in
{
  sops.secrets."${ntfySecret}" = lib.mkIf config.services.ntfy-sh.enable {
    format = "yaml";
    owner = "ntfy-sh";
    sopsFile = ../secrets/common_secrets.yaml;
  };

  services.ntfy-sh = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    settings = {
      base-url = "https://${serverName}";
      listen-http = "127.0.0.1:${toString port}";
      envrionmentFile = "/run/secrets/${ntfySecret}";
      auth-file = "/var/lib/ntfy-sh/user.db";
      auth-default-access = "deny-all";
      enable-login = true;
    };
  };

  services.nginx.enable = config.services.ntfy-sh.enable;

  systemd.services.ntfy-sh = lib.mkIf config.services.ntfy-sh.enable {
    serviceConfig = {
      EnvironmentFile = "/run/secrets/${ntfySecret}";
    };
    postStart = lib.mkForce ''
      # 1. Wait for the server to initialize the database
      echo "Waiting for ntfy auth database to appear..."
      TIMEOUT=30
      while [ ! -f /var/lib/ntfy-sh/user.db ]; do
        sleep 1
        TIMEOUT=$((TIMEOUT-1))
        if [ $TIMEOUT -le 0 ]; then
          echo "Timed out waiting for database creation!"
          exit 1
        fi
      done
      
      echo "Database found. Configuring admin user..."

      # 2. Define the username
      ADMIN_USER="ret2pop"

      # 3. Check if user exists, create if missing
      # We pipe the password twice because 'ntfy user add' asks for confirmation
      if ! ${pkgs.ntfy-sh}/bin/ntfy user list | grep -q "$ADMIN_USER"; then
        echo "Creating admin user $ADMIN_USER..."
        printf "$ADMIN_PASSWORD\n$ADMIN_PASSWORD" | \
          ${pkgs.ntfy-sh}/bin/ntfy user add --role=admin "$ADMIN_USER"
        echo "User created."
      else
        echo "Admin user already exists."
      fi
    '';
  };

  networking.domains.subDomains."${serverName}" = lib.mkIf config.services.ntfy-sh.enable {};
  services.nginx.virtualHosts."${serverName}" = lib.mkIf config.services.ntfy-sh.enable {
    serverName = "${serverName}";
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
      extraConfig = ''
proxy_buffering off;
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
'';
    };
  };
}
