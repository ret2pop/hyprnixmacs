{
  boot = {
    size = "1M";
    type = "EF02";
  };
  root = {
    label = "disk-main-root"; 
    size = "100%";
    content = {
      type = "filesystem";
      format = "ext4";
      mountpoint = "/";
    };
  };
}
