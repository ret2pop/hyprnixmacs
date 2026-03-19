# [[file:../../config/nix.org::*Main Configuration][Main Configuration:1]]
{ config, pkgs, lib, system, ... }:
let
  userGroups = [
    "nginx"
    "git"
    "ircd"
    "ngircd"
    "conduit"
    "livekit"
    "matterbridge"
    "maddy"
    "ntfy-sh"
    "public-inbox"
    "plugdev"
  ];
  allDomains = 
    (lib.attrNames config.networking.domains.baseDomains) ++ 
    (lib.attrNames config.networking.domains.subDomains);

  prodHosts = map (dom: "${config.monorepo.profiles.server.ipv4} ${dom}") allDomains;
  vmHosts = map (dom: "127.0.0.1 ${dom}") allDomains;
in
{
  environment.etc."wpa_supplicant.conf".text = ''
  country=CA
  '';
  systemd.tmpfiles.rules = [
    "d /srv/git 0755 git git -"
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = lib.mkDefault 50;
  };

  # Shim for testing
  virtualisation.vmVariant = {
    sops.validateSopsFiles = false;
    disko.devices = lib.mkForce {};

    virtualisation.forwardPorts = lib.mkIf config.monorepo.profiles.server.enable [
      { from = "host"; host.port = 10443; guest.port = 443; }
      { from = "host"; host.port = 9080; guest.port = 80; }
    ];

    virtualisation.useNixStoreImage = false;

    virtualisation.sharedDirectories.sops-keys = {
      source = "/home/preston/.config/sops/age";
      target = "/home/preston/.config/sops/age";
    };

    networking.extraHosts = lib.mkForce (lib.concatStringsSep "\n" vmHosts);
    networking.defaultGateway = lib.mkForce null;

    networking.interfaces.eth0.useDHCP = lib.mkForce true;

    fileSystems."/" = lib.mkForce {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    systemd.services.sops-nix = {
      unitConfig.RequiresMountsFor = "/home/preston/.config/sops/age";
    };

    security.acme.defaults.server = lib.mkForce "https://127.0.0.1:14000/dir";
  };

  documentation = {
    enable = lib.mkDefault config.monorepo.profiles.documentation.enable;
    man.enable = lib.mkDefault config.monorepo.profiles.documentation.enable;
    dev.enable = lib.mkDefault config.monorepo.profiles.documentation.enable;
  };

  environment = {
    etc = {
      securetty.text = ''
          # /etc/securetty: list of terminals on which root is allowed to login.
          # See securetty(5) and login(1).
        '';
    };
  };


  systemd.network.enable = lib.mkDefault config.monorepo.profiles.server.enable;
  systemd.network.networks."40-${config.monorepo.profiles.server.interface}" = lib.mkIf config.monorepo.profiles.server.enable {
    matchConfig.Name = "${config.monorepo.profiles.server.interface}";
    networkConfig = {
      IPv6AcceptRA = true;
      IPv6PrivacyExtensions = false;
    };
    ipv6AcceptRAConfig = {
      UseAutonomousPrefix = false;
    };
  };

  systemd = {
    services.NetworkManager-wait-online.enable = false;
    coredump.enable = false;
    network.config.networkConfig.IPv6PrivacyExtensions = "kernel";
    tmpfiles.settings = {
      "restrictetcnixos"."/etc/nixos/*".Z = {
        mode = "0000";
        user = "root";
        group = "root";
      };
    };
  };


  boot = {
    supportedFilesystems = {
      btrfs = true;
      ext4 = true;
    };

    extraModprobeConfig = ''
    options snd-usb-audio vid=0x1235 pid=0x8200 device_setup=1
    options rtw88_core disable_lps_deep=y power_save=0 disable_aspm_l1ss=y
    options rtw88_pci disable_msi=y disable_aspm=y
    options rtw_core disable_lps_deep=y
    options rtw_pci disable_msi=y disable_aspm=y
    options rtw89_core disable_ps_mode=y
    options rtw89_pci disable_aspm_l1=y disable_aspm_l1ss=y disable_clkreq=y
    options iwlwifi 11n_disable=8 uapsd_disable=1 bt_coex_active=0 disable_11ax=1 power_save=0
    options brcmfmac roamoff=1 feature_disable=0x82000
  '';
    extraModulePackages = [ ];

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "nvme"
        "sd_mod"
        "ehci_pci"
        "rtsx_pci_sdmmc"
        "usbhid"
      ];

      kernelModules = [ ];
    };

    lanzaboote = {
      enable = config.monorepo.profiles.secureBoot.enable;
      pkiBundle = "/var/lib/sbctl";
    };

    loader = {
      systemd-boot.enable = lib.mkForce
        (((! config.monorepo.profiles.grub.enable) &&
          (! config.monorepo.profiles.secureBoot.enable)) && (system != "aarch64-linux"));
      efi.canTouchEfiVariables = lib.mkForce (! config.monorepo.profiles.grub.enable);
    };

    kernelModules = [
      "snd-seq"
      "snd-rawmidi"
      "xhci_hcd"
      "kvm_intel"
      "af_packet"
      "ccm"
      "ctr"
      "cmac"
      "arc4"
      "ecb"
      "michael_mic"
      "gcm"
      "sha256"
      "sha384"
    ];

    kernelParams = [
      "cfg80211.reg_alpha2=CA"
      "usbcore.autosuspend=-1"
      "pcie_aspm=off"
      "pci=noaer"
      "page_alloc.shuffle=1"
      "slab_nomerge"

      # madaidan
      "pti=on"
      "randomize_kstack_offset=on"
      "vsyscall=none"

      # cpu
      "spectre_v2=on"
      "spec_store_bypass_disable=on"
      "tsx=off"
      "l1tf=full,force"
      "kvm.nx_huge_pages=force"

      # hardened
      "extra_latent_entropy"

      # mineral
      "quiet"
    ];

    blacklistedKernelModules = [
      "netrom"
      "rose"

      "adfs"
      "affs"
      "bfs"
      "befs"
      "cramfs"
      "efs"
      "erofs"
      "exofs"
      "freevxfs"
      "f2fs"
      "hfs"
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "ntfs"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
      "ufs"
    ];

    kernel.sysctl = if config.monorepo.profiles.server.enable then {
      "net.ipv6.conf.${config.monorepo.profiles.server.interface}.autoconf" = 0;
      "net.ipv6.conf.${config.monorepo.profiles.server.interface}.accept_ra" = 1; 
    } else {
      "kernel.ftrace_enabled" = false;
      "net.core.bpf_jit_enable" = false;
      "kernel.kptr_restrict" = 2;

      # madaidan
      "kernel.smtcontrol" = "on";
      "vm.swappiness" = 1;
      "vm.unprivileged_userfaultfd" = 0;
      "dev.tty.ldisc_autoload" = 0;
      "kernel.kexec_load_disabled" = 1;
      "kernel.sysrq" = 4;
      "kernel.perf_event_paranoid" = 3;

      # net
      "net.ipv4.ip_forward" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = true;
    };
  };

  networking = {
    interfaces = lib.mkIf config.monorepo.profiles.server.enable {
      "${config.monorepo.profiles.server.interface}" = {
        ipv4.addresses = [
          {
            address = config.monorepo.profiles.server.ipv4;
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = config.monorepo.profiles.server.ipv6;
            prefixLength = 64;
          }
        ];
        useDHCP = lib.mkForce false;
      };
    };

    defaultGateway = lib.mkIf config.monorepo.profiles.server.enable config.monorepo.profiles.server.gateway;
    useDHCP = false;
    tempAddresses = lib.mkIf config.monorepo.profiles.server.enable "disabled";
    extraHosts = lib.mkIf config.monorepo.profiles.server.enable (lib.concatStringsSep "\n" prodHosts);

    domains = lib.mkIf config.monorepo.profiles.server.enable {
      enable = true;
      baseDomains = {
        "${config.monorepo.vars.remoteHost}" = {
          a.data = config.monorepo.profiles.server.ipv4;
          aaaa.data = config.monorepo.profiles.server.ipv6;
        };
        "${config.monorepo.vars.orgHost}" = {
          a.data = config.monorepo.profiles.server.ipv4;
          aaaa.data = config.monorepo.profiles.server.ipv6;
          txt = {
            data = "v=spf1 ip4:${config.monorepo.profiles.server.ipv4} ip6:${config.monorepo.profiles.server.ipv6} -all";
          };
        };
      };
    };


    nameservers = [ "8.8.8.8" "1.1.1.1"];
    dhcpcd.enable = (! config.monorepo.profiles.server.enable);
    networkmanager = {
      enable = lib.mkForce (! config.monorepo.profiles.server.enable); # rpis need network
      wifi = {
        powersave = false;
      };
      ensureProfiles = {
        profiles = {
          home-wifi = {
            connection = {
              id = "TELUS6572";
              permissions = "";
              type = "wifi";
            };
            ipv4 = {
              dns-search = "";
              method = "auto";
            };
            ipv6 = {
              addr-gen-mode = "stable-privacy";
              dns-search = "";
              method = "auto";
            };
            wifi = {
              mac-address-blacklist = "";
              mode = "infrastructure";
              ssid = "TELUS6572";
            };
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
              # when someone actually steals my internet then I will be concerned.
              # This password only matters if you actually show up to my house in real life.
              # That would perhaps allow for some nasty networking related shenanigans.
              # I guess we'll cross that bridge when I get there.
              psk = "b4xnrv6cG6GX";
            };
          };
        };
      };
    };
    firewall = {
      allowedTCPPorts = [ 22 11434 ];
      allowedUDPPorts = [ ];
    };
  };

  hardware = {
    wirelessRegulatoryDatabase = true;
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = lib.mkDefault (system == "x86_64-linux");
    graphics.enable = ! config.monorepo.profiles.ttyonly.enable;

    bluetooth = {
      enable = lib.mkDefault config.monorepo.profiles.desktop.enable;
      powerOnBoot = lib.mkDefault config.monorepo.profiles.desktop.enable;
    };
  };

  services = {
    pulseaudio.enable = ! config.monorepo.profiles.pipewire.enable;
    chrony = {
      enable = true;
      enableNTS = true;
      servers = [ "time.cloudflare.com" "ptbtime1.ptb.de" "ptbtime2.ptb.de" ];
    };

    jitterentropy-rngd.enable = true;
    resolved.settings.Resolve.DNSSEC = true;
    usbguard.enable = false;
    dbus.apparmor = "enabled";

    # Misc.
    udev = {
      extraRules = '''';
      packages = if config.monorepo.profiles.workstation.enable then with pkgs; [ 
        platformio-core
        platformio-core.udev
        openocd
      ] else [];
    };

    printing.enable = lib.mkDefault config.monorepo.profiles.workstation.enable;
    udisks2.enable = (! config.monorepo.profiles.ttyonly.enable);
  };

  programs = {
    nix-ld.enable = true;
    zsh.enable = true;
    ssh.enableAskPassword = false;
  };

  security = {
    acme = {
      acceptTerms = true;
      defaults.email = "${config.monorepo.vars.internetName}@gmail.com";
    };
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = with pkgs; [
        apparmor-profiles
      ];
    };

    pam.loginLimits = [
      { domain = "*"; item = "nofile"; type = "-"; value = "32768"; }
      { domain = "*"; item = "memlock"; type = "-"; value = "32768"; }
    ];
    rtkit.enable = true;

    lockKernelModules = true;
    protectKernelImage = true;

    allowSimultaneousMultithreading = true;
    forcePageTableIsolation = true;

    tpm2 = {
      enable = system != "aarch64-linux";
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };

    auditd.enable = true;
    audit.enable = true;
    chromiumSuidSandbox.enable = (! config.monorepo.profiles.ttyonly.enable);
    sudo.enable = true;
  };

  xdg.portal = {
    enable = (! config.monorepo.profiles.ttyonly.enable);
    wlr.enable = (! config.monorepo.profiles.ttyonly.enable);
    extraPortals = with pkgs; if (! config.monorepo.profiles.ttyonly.enable) then [
      xdg-desktop-portal-gtk
      xdg-desktop-portal
      xdg-desktop-portal-hyprland
    ] else [];
    config.common.default = "*";
  };

  environment.etc."gitconfig".text = ''
    [init]
    defaultBranch = main
    '';
  environment.extraInit = ''
    umask 0022
    '';
  environment.systemPackages = with pkgs;  [
    restic
    sbctl
    gitFull
    git-lfs-transfer
    vim
    curl
    nmap
    exiftool
    (writeShellScriptBin "new-repo"
      ''
    #!/bin/bash
    cd ${config.users.users.git.home}
    git init --bare "$1"
    vim "$1/description"
    chown -R git:git "$1"
    ''
    )
  ] ++ (if system != "aarch64-linux" then [ git-lfs ] else []);

  users.groups = lib.genAttrs userGroups (_: lib.mkDefault {});

  users.users = lib.genAttrs userGroups (name: {
    isSystemUser = lib.mkDefault true;
    group = "${name}";
    extraGroups = [ "acme" "nginx" ];
  }) // {
    conduit = {
      isSystemUser = lib.mkDefault true;
      group = "conduit";
      extraGroups = [];
    };
    matterbridge = {
      isSystemUser = lib.mkDefault true;
      group = "matterbridge";
      extraGroups = [];
    };

    public-inbox = {
      isSystemUser = lib.mkDefault true;
      group = "public-inbox";

      extraGroups = [ "acme" "nginx" "git" ];
    };

    ircd = {
      isSystemUser = lib.mkDefault true;
      group = "ircd";
      home = "/home/ircd";
    };
    
    nginx = {
      group = "nginx";
      isSystemUser = lib.mkDefault true;
      extraGroups = [ "acme" ];
    };

    root.openssh.authorizedKeys.keys = [
      config.monorepo.vars.sshKey
    ];

    git = {
      isSystemUser = true;
      home = "/srv/git";
      shell = "/bin/sh";
      group = "git";
      openssh.authorizedKeys.keys = [
        config.monorepo.vars.sshKey
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIEF+mcL9nDkzVhCYyYWCIrP+b6oRiiaV509jywbD0Vq nix-on-droid@localhost"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCedJm0yYB0qLah/Y7PqLVgNh6qp+yujssGtuR05KbZLzSnsLUjUMObMyjFB9xTKrSGDqyoMkNe2l5VXMBJ9wBKLbzqMWbkakAWOj7EC/qZ6dFWA075mniwAuWKY/Q8QYohAJbbeU4j0ObWrltd4ar2Ac9vsVyftYF5efg8PEqVdOxzrBn5taY1zCCRjee5ISeRDIovnBbq7x86jsx5VnXTjMN9FZCI2qmz992Sg/PPXpXat+O1YQlG0eBHEny2Ug9gaAYnGOVr6kZKE4lrjz47nrXVXO6lJsNXmuzTVnEgo30DAA3dV4fws/M5ptM5Pgg2qe94HyHWhhmtXOekWmGtP3YxpVe3M/SPl31UL570ZDuuCcpJTsbe90ZyXC3CiSJkLKbmFkfOgZ6DI2LT8KSp09/2NCtZYriLN/nXObn6gQzByGMxVyKNx2hh8ENt9hzTCAk5lYDK3g3wS8eLCY3EH/caEqT9mLZEZeRHtAhtfozo1VJL7sSZ0Zm7wiIxHylwOshh1sYI1gb1MgMqNnrr1t8+8UK+Q0NERQW3yiphG36HXWy/DdCG0EF+N850KbgH1FFur+m+3hZCZCFVp3tGCcOC+bxWMBT3+9yC6LARi5cFjLQaWLsNO5xEs4vqX3+s3QjJ0pAYDkgtoeY2Fbh+imN+JasWn/cSy5p3UdE4ZQ== andrei@kiss"
      ];
    };
    "${config.monorepo.vars.userName}" = {
      openssh.authorizedKeys.keys = [
        config.monorepo.vars.sshKey
      ];

      linger = true;
      initialPassword = "${config.monorepo.vars.userName}";
      isNormalUser = true;
      description = config.monorepo.vars.fullName;
      extraGroups = [ "networkmanager" "wheel" "video" "docker" "jackaudio" "tss" "dialout" "docker" "plugdev" ];
      shell = pkgs.zsh;
      packages = [];
    };
  };

  nix = {
    settings = {
      keep-outputs = true;
      keep-derivations = true;
      auto-optimise-store = true;
      max-jobs = 4; 
      cores = 0;
      substituters = [
        "https://cache.nixos-cuda.org"
      ];
      trusted-public-keys = [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];
      experimental-features = "nix-command flakes ca-derivations";
      trusted-users = [ "@wheel" ];
    };
    gc.automatic = true;
  };
  time.timeZone = config.monorepo.vars.timeZone;
  i18n.defaultLocale = "en_CA.UTF-8";
  system.stateVersion = "24.11";
}
# Main Configuration:1 ends here
