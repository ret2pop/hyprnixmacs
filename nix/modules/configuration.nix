{ config, pkgs, lib, ... }:
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
in
{
  imports = [
    ./cgit.nix
    ./public_inbox.nix
    ./matterbridge.nix
    ./mautrix.nix
    ./xserver.nix
    ./ssh.nix
    ./pipewire.nix
    ./tor.nix
    ./kubo.nix
    ./nvidia.nix
    ./cuda.nix
    ./nginx.nix
    ./secrets.nix
    ./git-daemon.nix
    ./ollama.nix
    ./i2pd.nix
    ./conduit.nix
    ./bitcoin.nix
    ./murmur.nix
    ./ngircd.nix
    ./znc.nix
    ./docker.nix
    ./impermanence.nix
    ./coturn.nix
    ./maddy.nix
    ./ntfy-sh.nix
    ./fail2ban.nix
  ];

  environment.etc."wpa_supplicant.conf".text = ''
country=CA
'';

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
  	  systemd-boot.enable = lib.mkForce ((! config.monorepo.profiles.grub.enable) && (! config.monorepo.profiles.secureBoot.enable));
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
  	  # "debugfs=off"
  	  "page_alloc.shuffle=1"
  	  "slab_nomerge"
  	  # "page_poison=1"

  	  # madaidan
  	  "pti=on"
  	  "randomize_kstack_offset=on"
  	  "vsyscall=none"
  	  # "lockdown=confidentiality"

  	  # cpu
  	  "spectre_v2=on"
  	  "spec_store_bypass_disable=on"
  	  "tsx=off"
  	  "l1tf=full,force"
  	  "kvm.nx_huge_pages=force"

  	  # hardened
  	  "extra_latent_entropy"

  	  # mineral
  	  # "init_on_alloc=1"
  	  # "random.trust_bootloader=off"
  	  # "init_on_free=1"
  	  "quiet"
  	  # "loglevel=0"
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

    kernel.sysctl = {
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
      # "net.ipv4.conf.all.accept_redirects" = false;
      # "net.ipv4.conf.all.secure_redirects" = false;
      # "net.ipv4.conf.default.accept_redirects" = false;
      # "net.ipv4.conf.default.secure_redirects" = false;
      # "net.ipv6.conf.all.accept_redirects" = false;
      # "net.ipv6.conf.default.accept_redirects" = false;
    };
  };

  networking = {
    nameservers = [ "8.8.8.8" "1.1.1.1"];
    dhcpcd.enable = (! config.monorepo.profiles.server.enable);
    networkmanager = {
  	  enable = true;
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
    cpu.intel.updateMicrocode = true;
    graphics.enable = ! config.monorepo.profiles.ttyonly.enable;

    bluetooth = {
      enable = lib.mkDefault (! config.monorepo.profiles.ttyonly.enable);
      powerOnBoot = lib.mkDefault (! config.monorepo.profiles.ttyonly.enable);
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
    # usbguard.enable = true;
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
    light.enable = true;
    ssh.enableAskPassword = false;
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config = {
      allowUnfree = true;
      cudaSupport = lib.mkDefault config.monorepo.profiles.cuda.enable;
    };
  };

  security = {
    acme = {
      acceptTerms = true;
      defaults.email = "ret2pop@gmail.com";
    };
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = with pkgs; [
        apparmor-profiles
      ];
      # policies = {
      #   firefox.path = "${pkgs.apparmor-profiles}/share/apparmor/extra-profiles/firefox";
      # };
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
      enable = true;
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
  environment.systemPackages = with pkgs; [
    restic
    sbctl
    gitFull
    git-lfs
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
  ];

  users.groups = lib.genAttrs userGroups (name: lib.mkDefault {});

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

  nixpkgs.config.permittedInsecurePackages = [
    "python3.13-ecdsa-0.19.1"
    "olm-3.2.16"
  ];

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
