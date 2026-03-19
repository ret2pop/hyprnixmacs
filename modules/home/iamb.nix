# [[file:../../../config/nix.org::*iamb][iamb:1]]
{ super, config, ... }:
{
  programs.iamb = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    settings = {
      default_profile = "personal";
      profiles.personal = {
        user_id = "${super.monorepo.vars.internetName}@matrix.${super.monorepo.vars.orgHost}";
      };
      image_preview.protocol = {
        type = "kitty";
        size = {
          height = 10;
          width = 66;
        };
      };
    };
  };
}
# iamb:1 ends here
