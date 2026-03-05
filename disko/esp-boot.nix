{
  type = "filesystem";
  format = "vfat";
  mountpoint = "/boot";
  mountOptions = [ "umask=0077" ];
}
