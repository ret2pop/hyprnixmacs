{
  ESP = (import ./esp-boot.nix) // {
    size = "500M";
    priority = 1;
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
