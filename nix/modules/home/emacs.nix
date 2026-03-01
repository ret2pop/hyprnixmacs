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

      extraPackages = epkgs: [
        epkgs.agda2-mode
        epkgs.all-the-icons
        epkgs.auctex
        epkgs.catppuccin-theme
        epkgs.company
        epkgs.company-solidity
        epkgs.counsel
        epkgs.centaur-tabs
        epkgs.dashboard
        epkgs.doom-themes
        epkgs.doom-modeline
        epkgs.elfeed
        epkgs.elfeed-org
        epkgs.elfeed-tube
        epkgs.elfeed-tube-mpv
        epkgs.elpher
        epkgs.ement
        epkgs.emmet-mode
        epkgs.emms
        epkgs.enwc
        epkgs.evil
        epkgs.evil-collection
        epkgs.evil-commentary
        epkgs.evil-org
        epkgs.f
        epkgs.flycheck
        epkgs.general
        epkgs.gptel
        epkgs.gruvbox-theme
        epkgs.haskell-mode
        epkgs.htmlize
        epkgs.idris-mode
        epkgs.irony-eldoc
        epkgs.ivy
        epkgs.ivy-pass
        epkgs.kiwix
        epkgs.latex-preview-pane
        epkgs.lsp-ivy
        epkgs.lsp-mode
        epkgs.lsp-haskell
        epkgs.lyrics-fetcher
        epkgs.mastodon
        epkgs.magit
        epkgs.magit-delta
        epkgs.mu4e
        epkgs.minuet
        epkgs.nix-mode
        epkgs.org-fragtog
        epkgs.org-journal
        epkgs.org-roam
        epkgs.org-roam-ui
        epkgs.org-superstar
        epkgs.page-break-lines
        epkgs.password-store
        epkgs.pdf-tools
        epkgs.pinentry
        epkgs.platformio-mode
        epkgs.projectile
        epkgs.rustic
        epkgs.scad-mode
        epkgs.simple-httpd
        epkgs.solidity-flycheck
        epkgs.solidity-mode
        epkgs.sudo-edit
        epkgs.telega
        epkgs.treemacs
        epkgs.treemacs-evil
        epkgs.treemacs-magit
        epkgs.treemacs-projectile
        epkgs.treesit-auto
        epkgs.typescript-mode
        epkgs.unicode-fonts
        epkgs.use-package
        epkgs.vterm
        epkgs.wgrep
        epkgs.web-mode
        epkgs.websocket
        epkgs.which-key
        epkgs.writegood-mode
        epkgs.writeroom-mode
        epkgs.yaml-mode
        epkgs.yasnippet
        epkgs.yasnippet-snippets
      ];
    };
}
