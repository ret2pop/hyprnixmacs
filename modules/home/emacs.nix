{ lib, config, pkgs, super, ... }:
{
  programs.emacs = 
    {
      enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
      package = pkgs.emacs-pgtk;
      extraConfig = ''
(setq debug-on-error t)
(setq system-email "${super.monorepo.vars.email}")
(setq system-username "${super.monorepo.vars.internetName}")
(setq system-fullname "${super.monorepo.vars.fullName}")
(setq system-gpgkey "${super.monorepo.vars.gpgKey}")
(load "${pkgs.writeText "init.el" (builtins.readFile ../../init.el)}")
'';

      extraPackages = import ./emacs-packages.nix;
    };
}
