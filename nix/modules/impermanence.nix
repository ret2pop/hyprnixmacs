{ lib, config, ... }:
{
  assertions = [
    {
      assertion = (! config.monorepo.profiles.impermanence.enable && (! (config.monorepo.vars.fileSystem == "btrfs")));
      message = "Impermanence requires btrfs filesystem.";
    }
  ];

  boot.initrd.postResumeCommands = (if config.monorepo.profiles.impermanence.enable then lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/root_vg/root /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '' else "");
  
  environment.persistence."/persistent" = {
    enable = config.monorepo.profiles.impermanence.enable;
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
      "/etc/matterbridge.toml"
      { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];
    users."${config.monorepo.vars.userName}" = {
      directories = [
        "Downloads"
        "music"
        "Pictures"
        "Documents"
        "Videos"
        "Monero"
        "org"
        "monorepo"
        "soundfont"
        "website_html"
        "ardour"
        "audacity"
        "img"
        "email"
        "projects"
        "secrets"

        ".emacs.d"
        ".elfeed"
        ".electrum"
        ".mozilla"
        ".bitmonero"
        ".config"
        { directory = ".gnupg"; mode = "0700"; }
        { directory = ".ssh"; mode = "0700"; }
        { directory = ".local/share/keyrings"; mode = "0700"; }
        ".local/share/direnv"
      ];
      files = [
        ".emacs"
      ];
    };
  };
}
