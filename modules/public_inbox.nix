{ lib, config, ... }:
{
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
      watch = [ "imaps://${name}${config.monorepo.vars.orgHost}@mail.${config.monorepo.vars.orgHost}/INBOX" ];
      coderepo = [ "${name}" ];
    }) // {
      "discussion" = {
        description = "Main Nullring Discussion Mailing List";
        address = [ "discussion@${config.monorepo.vars.orgHost}" ];
        inboxdir = "/var/lib/public-inbox/discuss";
        url = "https://list.${config.monorepo.vars.orgHost}/discussion";
        watch = [ "imaps://discussion%40${config.monorepo.vars.orgHost}@mail.${config.monorepo.vars.orgHost}/INBOX" ];
      };
    };
  };
}
