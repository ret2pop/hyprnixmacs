# [[file:../../config/nix.org::*Virtual Machine][Virtual Machine:1]]
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
# Virtual Machine:1 ends here
