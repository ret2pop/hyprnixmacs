# [[file:../../../config/nix.org::*Emacs][Emacs:1]]
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
  (setq my-ispell-dictionary "${pkgs.scowl}/share/dict/words.txt")
  (setq my-ispell-args '(
                         "--encoding=iso-8859-1"
                         "--mode=url" 
                         "--data-dir=${pkgs.aspell}/lib/aspell"
                         "--dict-dir=${pkgs.aspellDicts.en}/lib/aspell"))

  (load "${pkgs.writeText "init.el" (builtins.readFile ../../init.el)}")
  '';

      extraPackages = import ./emacs-packages.nix;
    };
}
# Emacs:1 ends here
