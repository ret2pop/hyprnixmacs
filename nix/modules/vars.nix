{ lib, ... }:
let
  vars = import ../flakevars.nix;
in
{
  options.monorepo.vars = {
    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/sda";
      example = "/dev/nvme0n1";
      description = "device that NixOS is installed to";
    };

    internetName = lib.mkOption {
      type = lib.types.str;
      default = "${vars.internetName}";
      example = "myinternetname";
      description = "Internet name to be used for internet usernames";
    };

    sshKey = lib.mkOption {
      type = lib.types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICts6+MQiMwpA+DfFQxjIN214Jn0pCw/2BDvOzPhR/H2 preston@continuity-dell";
      example = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICts6+MQiMwpA+DfFQxjIN214Jn0pCw/2BDvOzPhR/H2 preston@continuity-dell";
      description = "Admin public key for managing multiple configurations";
    };

    dkimKey = lib.mkOption {
      type = lib.types.str;
      default = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsC9GpfjvQlldPrHAC7Yt+ZF0aduUIVV4j2+KUkF0j6NsrpOgvU6COWKQSod/B/qyPBLWf+w5P5YiJ9XnOgw6Db/I9C67eusEHnV/cbvokXLQjSBvXee1OEdrT9i+6iUgDeGWP4CrD1DcwvXzAcCI9exy3yALHVlbkyYvi0KAYofs8dVQ3JCwSCMlol71lA6ULJ2zbCIWeSOv9/C6QZ5HOIeeoFLesX6O/YvF4FYxWbSHy244TXYuczQKuayjKgD6e8gIT5WJRQj8IAWOQ2podWw6hSuB3Ig+ekoOfnl5ivJGOMbAzFTj8FtbS4ncyidLU1kIOeuLfiILeDDLlIeYTwIDAQAB";
      example = "string_after_p=";
      description = "dkim key to put in host record for email";
    };

    repoName = lib.mkOption {
      type = lib.types.str;
      default = "monorepo";
      example = "myreponame";
      description = "Name of this repository";
    };

    projects = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "monorepo"
        "nullerbot"
      ];
      example = [
        "project1"
        "project2"
        "project3"
      ];
      description = "Names of repos that will have mailing lists";
    };

    fileSystem = lib.mkOption {
      type = lib.types.str;
      default = "ext4";
      example = "btrfs";
      description = "filesystem to install with disko";
    };

    diskoSpec = lib.mkOption {
      type = lib.types.attrs;
      description = "retains a copy of the disko spec for reflection";
    };

    fullName = lib.mkOption {
      type = lib.types.str;
      default = "Preston Pan";
      example = "John Doe";
      description = "Full Name";
    };

    userName = lib.mkOption {
      type = lib.types.str;
      default = "preston";
      example = "myUser";
      description = "system username";
    };

    gpgKey = lib.mkOption {
      type = lib.types.str;
      default = "AEC273BF75B6F54D81343A1AC1FE6CED393AE6C1";
      example = "1234567890ABCDEF...";
      description = "GPG key fingerprint";
    };

    remoteHost = lib.mkOption {
      type = lib.types.str;
      default = "${vars.remoteHost}";
      example = "example.com";
      description = "Address to push to and pull from for website and git repos";
    };

    orgHost = lib.mkOption {
      type = lib.types.str;
      default = "${vars.orgHost}";
      example = "orgname.org";
      description = "Domain name of your organization, points to same VPS as remoteHost";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "${vars.internetName}@${vars.orgHost}";
      example = "example@example.org";
      description = "Admin email address";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "America/Vancouver";
      example = "America/Chicago";
      description = "Linux timezone";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "HDMI-A-1"
        "eDP-1"
        "DP-2"
        "DP-3"
        "DP-4"
        "LVDS-1"
      ];
      example = [];
      description = "Monitors that waybar will use";
    };
  };
}
