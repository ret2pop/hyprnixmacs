{ pkgs, lib, config, ... }:
{
  services.ntfy-sh = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    settings = {
      base-url = "https://ntfy.${config.monorepo.vars.remoteHost}";
      listen-http = "127.0.0.1:2586";
      envrionmentFile = "/run/secrets/ntfy";
      auth-file = "/var/lib/ntfy-sh/user.db";
      auth-default-access = "deny-all";
      enable-login = true;
    };
  };
  systemd.services.ntfy-sh = {
    serviceConfig = {
      EnvironmentFile = "/run/secrets/ntfy";
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
}
