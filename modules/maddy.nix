{ lib, config, options, ... }:
let
  emailServerName = "mail.${config.monorepo.vars.orgHost}";
  serverName = "list.${config.monorepo.vars.orgHost}";
  password_path = "mail_monorepo_password";
in
{
  sops.secrets = lib.mkIf config.services.maddy.enable {
    "${password_path}" = lib.mkIf config.services.maddy.enable {
      format = "yaml";
      owner = "maddy";
    };
  };

  services.maddy = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    openFirewall = true;
    hostname = "${config.monorepo.vars.orgHost}";
    primaryDomain = "mail.${config.monorepo.vars.orgHost}";
    localDomains = [
      "$(primary_domain)"
      "${config.monorepo.vars.orgHost}"
    ];
    tls = {
      loader = "file";
      certificates = [
        {
          keyPath = "/var/lib/acme/mail.${config.monorepo.vars.orgHost}/key.pem";
          certPath = "/var/lib/acme/mail.${config.monorepo.vars.orgHost}/fullchain.pem";
        }
      ];
    };
    config = builtins.replaceStrings [
      "imap tcp://0.0.0.0:143"
      "submission tcp://0.0.0.0:587"
    ] [
      "imap tls://0.0.0.0:993 tcp://0.0.0.0:143"
      "submission tls://0.0.0.0:465 tcp://0.0.0.0:587"
    ] options.services.maddy.config.default;

    ensureAccounts = (builtins.map (x: "${x}@${config.monorepo.vars.orgHost}") config.monorepo.vars.projects) ++ [
      "${config.monorepo.vars.internetName}@${config.monorepo.vars.orgHost}"
      "discussion@${config.monorepo.vars.orgHost}"
    ];
    ensureCredentials = lib.genAttrs config.services.maddy.ensureAccounts (_: {
      passwordFile = "/run/secrets/${password_path}";
    }) // {
      "${config.monorepo.vars.internetName}@${config.monorepo.vars.orgHost}" = {
        passwordFile = "/run/secrets/mail_password";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "C+ /var/lib/public-inbox/style.css 0644 public-inbox public-inbox - ${../data/public-inbox.css}"
  ];
  systemd.services.public-inbox-httpd = if config.monorepo.profiles.server.enable then {
    preStart = ''
    # Copy or link the file. 
    # Using 'cp' is often safer for sandboxed services than linking to the store. Lol.
    cp -f ${../data/public-inbox.css} /var/lib/public-inbox/style.css
    chmod 644 /var/lib/public-inbox/style.css
  '';
    
    serviceConfig = {
      # Allow the service to see the file it just created
      BindPaths = [ 
        "/var/lib/public-inbox" 
        "${config.users.users.git.home}"
      ];
      ReadOnlyPaths = [ "/var/lib/public-inbox/style.css" ];
      # Ensure it can actually write to the directory during preStart
      ReadWritePaths = [ "/var/lib/public-inbox" ];
    };
  } else {};

  systemd.services.public-inbox-watch = if config.monorepo.profiles.server.enable then {
    after = [ "sops-nix.service" ];
    confinement.enable = lib.mkForce false;
    preStart = ''
      mkdir -p /var/lib/public-inbox/.tmp
      chmod 0700 /var/lib/public-inbox/.tmp
      ln -sfn ${config.sops.templates."public-inbox-netrc".path} /var/lib/public-inbox/.netrc
    '';
    environment = {
      PUBLIC_INBOX_FORCE_IPV4 = "1";
      NETRC = config.sops.templates."public-inbox-netrc".path;
      HOME = "/var/lib/public-inbox";
      TMPDIR = "/var/lib/public-inbox/.tmp";
    };

    serviceConfig = {
      RestrictSUIDSGID = lib.mkForce false;
      ReadWritePaths = [ "/var/lib/public-inbox" ];
      RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" "AF_INET" "AF_INET6" ];
      PrivateNetwork = lib.mkForce false;
      SystemCallFilter = lib.mkForce [];
      RootDirectory = lib.mkForce "";

      CapabilityBoundingSet = lib.mkForce [ "~" ];
      UMask = lib.mkForce "0022";
      ProtectSystem = lib.mkForce false;
    };
  } else {};

  services.public-inbox = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    settings = {
      coderepo = lib.genAttrs config.monorepo.vars.projects (name: {
        dir = "${config.users.users.git.home}/${name}.git";
        # works even if no cgit server running here, this is just the default
        cgitUrl = "https://git.${config.monorepo.vars.orgHost}/${name}.git";
      });
      publicinbox.css = ["/var/lib/public-inbox/style.css"];
      publicinbox.wwwlisting = "all";
    };
    http = {
      enable = true;
      port = 9090;
    };
    inboxes = lib.genAttrs config.monorepo.vars.projects (name: {
      description = "discussion of the ${name} project.";
      address = [ "${name}@${config.monorepo.vars.orgHost}" ];
      inboxdir = "/var/lib/public-inbox/${name}";
      url = "https://list.${config.monorepo.vars.orgHost}/${name}";
      watch = [ "imaps://${name}${config.monorepo.vars.orgHost}@${emailServerName}/INBOX" ];
      coderepo = [ "${name}" ];
    }) // {
      "discussion" = {
        description = "Main Nullring Discussion Mailing List";
        address = [ "discussion@${config.monorepo.vars.orgHost}" ];
        inboxdir = "/var/lib/public-inbox/discuss";
        url = "https://${serverName}/discussion";
        watch = [ "imaps://discussion%40${config.monorepo.vars.orgHost}@${emailServerName}/INBOX" ];
      };
    };
  };

  networking.domains.baseDomains."${config.monorepo.vars.orgHost}" = lib.mkIf config.services.maddy.enable {
    mx.data = [
      {
        preference = 10;
        exchange = "${emailServerName}";
      }
    ];
  };

  networking.domains.subDomains = lib.mkIf config.services.maddy.enable {
    "${serverName}" = {};
    "${emailServerName}" = {};
    "_dmarc.${config.monorepo.vars.orgHost}" = {
      txt = {
        data = "v=DMARC1; p=none";
      };
    };
    "default._domainkey.${config.monorepo.vars.orgHost}" = {
      txt = {
        data = "v=DKIM1; k=rsa; p=${config.monorepo.vars.dkimKey}";
      };
    };
  };

  networking.firewall.allowedTCPPorts = lib.mkIf config.services.maddy.enable [
    143
    465
    587
    993
  ];

  services.nginx.virtualHosts."${serverName}" = lib.mkIf config.services.public-inbox.enable {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.public-inbox.http.port}";
      extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
    };
  };

  services.nginx.virtualHosts."${emailServerName}" = lib.mkIf config.services.maddy.enable {
    serverName = "${emailServerName}";
    root = "/var/www/dummy";
    addSSL = true;
    enableACME = true;
  };

}
