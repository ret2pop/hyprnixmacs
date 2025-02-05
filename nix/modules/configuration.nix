{ config, pkgs, lib, ... }:
{
  imports = [
    ./xserver.nix
    ./ssh.nix
    ./pipewire.nix
    ./tor.nix
    ./kubo.nix
    ./nvidia.nix
    ./cuda.nix
    ./nginx.nix
    ./git-daemon.nix
    ./postfix.nix
    ./dovecot.nix
    ./ollama.nix
    ./i2pd.nix
  ];

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
    coredump.enable = false;
    network.config.networkConfig.IPv6PrivacyExtensions = "kernel";
    tmpfiles.settings = {
	    "restricthome"."/home/*".Z.mode = "~0700";

	    "restrictetcnixos"."/etc/nixos/*".Z = {
	      mode = "0000";
	      user = "root";
	      group = "root";
	    };
    };
  };


  boot = {
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
	    pkiBundle = "/etc/secureboot";
    };

    loader = {
	    systemd-boot.enable = lib.mkForce (! config.monorepo.profiles.grub.enable);
	    efi.canTouchEfiVariables = lib.mkDefault (! config.monorepo.profiles.grub.enable);
    };

    kernelModules = [
	    "snd-seq"
	    "snd-rawmidi"
	    "xhci_hcd"
	    "kvm_intel"
    ];

    kernelParams = [
	    "debugfs=off"
	    "page_alloc.shuffle=1"
	    "slab_nomerge"
	    "page_poison=1"

	    # madaidan
	    "pti=on"
	    "randomize_kstack_offset=on"
	    "vsyscall=none"
	    "module.sig_enforce=1"
	    "lockdown=confidentiality"

	    # cpu
	    "spectre_v2=on"
	    "spec_store_bypass_disable=on"
	    "tsx=off"
	    "tsx_async_abort=full,nosmt"
	    "mds=full,nosmt"
	    "l1tf=full,force"
	    "nosmt=force"
	    "kvm.nx_huge_pages=force"

	    # hardened
	    "extra_latent_entropy"

	    # mineral
	    "init_on_alloc=1"
	    "random.trust_cpu=off"
	    "random.trust_bootloader=off"
	    "intel_iommu=on"
	    "amd_iommu=force_isolation"
	    "iommu=force"
	    "iommu.strict=1"
	    "init_on_free=1"
	    "quiet"
	    "loglevel=0"
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
	    "vm.swappiness" = 1;
	    "vm.unprivileged_userfaultfd" = 0;
	    "dev.tty.ldisc_autoload" = 0;
	    "kernel.kexec_load_disabled" = 1;
	    "kernel.sysrq" = 4;
	    "kernel.perf_event_paranoid" = 3;

	    # net
	    "net.ipv4.icmp_echo_ignore_broadcasts" = true;

	    "net.ipv4.conf.all.accept_redirects" = false;
	    "net.ipv4.conf.all.secure_redirects" = false;
	    "net.ipv4.conf.default.accept_redirects" = false;
	    "net.ipv4.conf.default.secure_redirects" = false;
	    "net.ipv6.conf.all.accept_redirects" = false;
	    "net.ipv6.conf.default.accept_redirects" = false;
    };
  };

  networking = {
    useDHCP = lib.mkDefault true;
    hostName = config.monorepo.vars.hostName;
    networkmanager = {
	    enable = true;
    };
    firewall = {
	    allowedTCPPorts = [ 22 11434 ];
	    allowedUDPPorts = [ ];
    };
  };

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    graphics.enable = ! config.monorepo.profiles.ttyonly.enable;
    pulseaudio.enable = ! config.monorepo.profiles.pipewire.enable;

    bluetooth = {
	    enable = true;
	    powerOnBoot = true;
    };
  };

  services = {
    chrony = {
	    enable = true;
	    enableNTS = true;
	    servers = [ "time.cloudflare.com" "ptbtime1.ptb.de" "ptbtime2.ptb.de" ];
    };

    jitterentropy-rngd.enable = true;
    resolved.dnssec = true;
    # usbguard.enable = true;
    usbguard.enable = false;
    dbus.apparmor = "enabled";

    kanata.enable = true;

    # Misc.
    udev = {
	    extraRules = '''';
	    packages = with pkgs; [ 
	      platformio-core
	      platformio-core.udev
	      openocd
	    ];
    };

    printing.enable = true;
    udisks2.enable = true;
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
    apparmor = {
	    enable = true;
	    killUnconfinedConfinables = true;
    };

    pam.loginLimits = [
	    { domain = "*"; item = "nofile"; type = "-"; value = "32768"; }
	    { domain = "*"; item = "memlock"; type = "-"; value = "32768"; }
    ];
    rtkit.enable = true;

    lockKernelModules = true;
    protectKernelImage = true;
    allowSimultaneousMultithreading = false;
    forcePageTableIsolation = true;

    tpm2 = {
	    enable = true;
	    pkcs11.enable = true;
	    tctiEnvironment.enable = true;
    };

    auditd.enable = true;
    audit.enable = true;
    chromiumSuidSandbox.enable = true;
    sudo.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
	    xdg-desktop-portal-gtk
	    xdg-desktop-portal
	    xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
  };

  environment.systemPackages = with pkgs; [
    restic
    sbctl
    git
    vim
    curl
  ];

  users.users = {
    root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICts6+MQiMwpA+DfFQxjIN214Jn0pCw/2BDvOzPhR/H2 preston@continuity-dell"
    ];

    git = {
	    isSystemUser = true;
	    home = "/srv/git";
	    shell = "${pkgs.git}/bin/git-shell";
    };
    "${config.monorepo.vars.userName}" = {
	    initialPassword = "${config.monorepo.vars.userName}";
	    isNormalUser = true;
	    description = config.monorepo.vars.fullName;
	    extraGroups = [ "networkmanager" "wheel" "video" "docker" "jackaudio" "tss" "dialout" ];
	    shell = pkgs.zsh;
	    packages = [];
    };
  };

  nix.settings.experimental-features = "nix-command flakes";
  time.timeZone = config.monorepo.vars.timeZone;
  i18n.defaultLocale = "en_CA.UTF-8";
  system.stateVersion = "24.11";
}
