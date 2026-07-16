# [[file:../../../config/nix.org::*Default Home Profile][Default Home Profile:1]]
{ lib, config, pkgs, sops-nix, super, ... }:
let
  dirContents = builtins.readDir ./.;
  files = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" && name != "emacs-packages.nix") dirContents;

  profilesSchema = {
    graphics = {
      desc = "Enables graphical programs for user";
      pkgs = [];
      default = (! super.monorepo.profiles.ttyonly.enable) && config.monorepo.profiles.enable;
    };
    hyprland = {
      desc = "Enables hyprland";
      pkgs = [];
      default = config.monorepo.profiles.graphics.enable;
    };
    lang-c = {
      desc = "Enables C language support";
      pkgs = with pkgs; [ autobuild clang gdb gnumake bear clang-tools autotools-language-server ];
      default = config.monorepo.profiles.enable;
    };
    lang-sh = {
      desc = "Enables sh language support";
      pkgs = with pkgs; [ bash-language-server ];
      default = config.monorepo.profiles.enable;
    };
    lang-rust = {
      desc = "Enables Rust language support";
      pkgs = with pkgs; [ cargo rust-analyzer rustfmt ];
      default = config.monorepo.profiles.enable;
    };
    lang-python = {
      desc = "Enables python language support";
      pkgs = with pkgs; [ poetry python3 semgrep ty ruff python314Packages.debugpy ];
      default = config.monorepo.profiles.enable;
    };
    lang-sol = {
      desc = "Enables solidity language support";
      pkgs = with pkgs; [ solc ];
      default = config.monorepo.profiles.enable;
    };
    lang-openscad = {
      desc = "Enables openscad language support";
      pkgs = with pkgs; [ openscad openscad-lsp ];
      default = config.monorepo.profiles.enable;
    };
    lang-js = {
      desc = "Enables javascript language support";
      pkgs = with pkgs; [ nodejs bun yarn typescript typescript-language-server vscode-langservers-extracted ];
      default = config.monorepo.profiles.enable;
    };
    lang-nix = {
      desc = "Enables nix language support";
      pkgs = with pkgs; [ nil nixd nixfmt-rfc-style nix-prefetch-scripts ];
      default = config.monorepo.profiles.enable;
    };
    lang-idris = {
      desc = "Enables idris language support";
      pkgs = with pkgs; [ idris idris2Packages.idris2Lsp ];
      default = config.monorepo.profiles.enable;
    };
    lang-agda = {
      desc = "Enables agda language support";
      pkgs = with pkgs; [ agda ];
      default = config.monorepo.profiles.enable;
    };
    lang-coq = {
      desc = "Enables coq language support";
      pkgs = with pkgs; [ coq ];
      default = config.monorepo.profiles.enable;
    };
    lang-lean = {
      desc = "Enables lean language support";
      pkgs = with pkgs; [ elan ];
      default = config.monorepo.profiles.enable;
    };
    lang-haskell = {
      desc = "Enables haskell language support";
      pkgs = with pkgs; [ haskell-language-server haskellPackages.hlint ghc ];
      default = config.monorepo.profiles.enable;
    };
    lang-scheme = {
      desc = "Enables scheme language support";
      pkgs = with pkgs; [ chez ];
      default = config.monorepo.profiles.enable;
    };

    lang-data = {
      desc = "Enables markup languages support";
      pkgs = with pkgs; [ yaml-language-server ];
      default = config.monorepo.profiles.enable;
    };

    crypto = {
      desc = "Enables various cryptocurrency wallets";
      pkgs = with pkgs; [ bitcoin monero-cli monero-gui ];
      default = config.monorepo.profiles.enable;
    };

    art = {
      desc = "Enables various art programs";
      pkgs = with pkgs; [ inkscape krita ];
      default = config.monorepo.profiles.enable;
    };

    music = {
      desc = "Enables mpd";
      pkgs = with pkgs; [ mpc sox ];
      default = config.monorepo.profiles.enable;
    };

    workstation = {
      desc = "Enables workstation packages (music production and others)";
      pkgs = with pkgs; [ mumble alsa-utils alsa-scarlett-gui ardour audacity blender foxdot fluidsynth qjackctl qsynth qpwgraph imagemagick supercollider inkscape kdePackages.kdenlive ]; 
      default = super.monorepo.profiles.workstation.enable;
    };

    cuda = {
      desc = "Enables CUDA user package builds";
      pkgs = [];
      default = super.monorepo.profiles.cuda.enable;
    };

    email = {
      desc = "Enables email";
      pkgs = [ pkgs.mu ];
      default = config.monorepo.profiles.enable;
    };

    agent = {
      desc = "AI agents";
      pkgs = with pkgs; [];
      default = config.monorepo.profiles.enable;
    };
  };

in
{
  imports = [
    sops-nix.homeManagerModules.sops
  ] ++ lib.mapAttrsToList (name: _: ./. + "/${name}") files;

  options = {
    monorepo.profiles = {
      enable = lib.mkEnableOption "Enables home manager desktop configuration";
    } // lib.mapAttrs (_: cfg: {
      enable = lib.mkEnableOption cfg.desc;
    }) profilesSchema;
  };

  config = {
    monorepo.profiles = {
      enable = lib.mkDefault super.monorepo.profiles.home.enable;
    } // lib.mapAttrs (_: cfg: {
      enable = lib.mkDefault cfg.default;
    }) profilesSchema;

    home.packages = lib.concatLists (
      lib.mapAttrsToList (_: cfg:
        if config.monorepo.profiles.${name}.enable then cfg.pkgs else []
      ) profilesSchema
    );
  };
}
# Default Home Profile:1 ends here
