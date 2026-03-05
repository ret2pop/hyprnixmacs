{
  ESP = {
    type = "EF00";
    size = "500M";
    priority = 1;
    content = import ./esp-boot.nix;
  };
  root = {
    size = "100%";
    priority = 2;
    content = {
      type = "filesystem";
      format = "ext4";
      mountpoint = "/";
    };
  };
}
