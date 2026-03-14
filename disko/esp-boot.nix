# [[file:../../config/nix.org::*ESP Boot Partition][ESP Boot Partition:1]]
{
  type = "EF00";
  content = {
    type = "filesystem";
    format = "vfat";
    mountpoint = "/boot";
    mountOptions = [ "umask=0077" ];
  };
}
# ESP Boot Partition:1 ends here
