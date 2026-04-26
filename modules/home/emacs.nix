# [[file:../../../config/nix.org::*Emacs][Emacs:1]]
{ lib, config, pkgs, super, self, ... }:
{
  programs.emacs = 
    {
      enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
      package = pkgs.emacs-pgtk;
      extraConfig = ''
        (setq debug-on-error t)
        (setq logo-file "${self}/data/logo.png")
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
      extraPackages = epkgs: 
        let
          # 1. Import the new file and pass it the required arguments
          lean4-mode-pinned = import ../../user-packages/lean4.nix { 
            inherit epkgs; 
            lean4-src = self.inputs.lean4-mode-src; 
          };
          
          # 2. Import your standard packages
          basePackages = import ./emacs-packages.nix epkgs;
        in 
          basePackages ++ [ lean4-mode-pinned ];
    };
}
# Emacs:1 ends here
