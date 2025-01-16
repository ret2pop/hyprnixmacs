{ lib, config, pkgs, ... }:
{
  imports = [
    ./configuration.nix
  ];

  options = {
    monorepo = {
      vars = import ./vars.nix;

      profiles = {
        documentation.enable = lib.mkEnableOption "Enables documentation on system.";
        secureBoot.enable = lib.mkEnableOption "Enables secure boot. See sbctl.";
        pipewire.enable = lib.mkEnableOption "Enables pipewire low latency audio setup";
        tor.enable = lib.mkEnableOption "Enables tor along with torsocks";


        home = {
          enable = lib.mkEnableOption "Enables home manager desktop configuration";
          # Programs
          lang-c.enable = lib.mkEnableOption "Enables C language support";
          lang-shell.enable = lib.mkEnableOption "Enables sh language support";
          lang-rust.enable = lib.mkEnableOption "Enables Rust language support";
          lang-python.enable = lib.mkEnableOption "Enables python language support";
          lang-sol.enable = lib.mkEnableOption "Enables solidity language support";
          lang-openscad.enable = lib.mkEnableOption "Enables openscad language support";
          lang-js.enable = lib.mkEnableOption "Enables javascript language support";
          lang-nix.enable = lib.mkEnableOption "Enables nix language support";

          crypto.enable = lib.mkEnableOption "Enables various cryptocurrency wallets";
          art.enable = lib.mkEnableOption "Enables various art programs";
          music.enable = lib.mkEnableOption "Enables mpd";

          hyprland = {
            enable = lib.mkEnableOption "Enables hyprland";
            monitors = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [
                "HDMI-A-1"
                "eDP-1"
                "DP-2"
                "DP-3"
                "LVDS-1"
              ];
              example = [];
              description = "Hyprland monitors";
            };
          };
          email = {
            email = lib.mkOption {
              type = lib.types.str;
              default = "ret2pop@gmail.com";
              example = "john@example.com";
              description = "Email address and imaps/smtps account";
            };
            imapsServer = lib.mkOption {
              type = lib.types.str;
              default = "imap.gmail.com";
              example = "imap.example.com";
              description = "imaps server address";
            };
            smtpsServer = lib.mkOption {
              type = lib.types.str;
              default = "smtp.gmail.com";
              example = "smtp.example.com";
              description = "smtp server address";
            };
            enable = lib.mkEnableOption "Enables email";
          };
        };
      };
    };
  };

  config = {
    environment.systemPackages = lib.mkIf config.monorepo.profiles.documentation.enable (with pkgs; [
      linux-manual
      man-pages
      man-pages-posix
    ]);

    home-manager.users."${config.monorepo.vars.userName}".home.packages = lib.flatten [
      (lib.mkIf config.monorepo.home.email.enable [ pkgs.mu ])
      (lib.mkIf config.monorepo.home.lang-c.enable (with pkgs; [
        autobuild
        clang
        gdb
        gnumake
        bear
        clang-tools
      ]))

      (lib.mkIf config.monorepo.home.lang-js.enable (with pkgs; [
        nodejs
        bun
        yarn
        typescript
        vscode-langservers-extracted
      ]))

      (lib.mkIf config.monorepo.home.lang-rust.enable (with pkgs; [
        cargo
        rust-analyzer
        rustfmt
      ]))

      (lib.mkIf config.monorepo.home.lang-python.enable (with pkgs; [
        poetry
        python3
        python312Packages.jedi
      ]))

      (lib.mkIf config.monorepo.home.lang-sol.enable (with pkgs; [
        solc
      ]))

      (lib.mkIf config.monorepo.home.lang-openscad.enable (with pkgs; [
        openscad
        openscad-lsp
      ]))

      (lib.mkIf config.monorepo.home.lang-sh.enable (with pkgs; [
        bash-language-server
      ]))

      (lib.mkIf config.monorepo.home.lang-nix.enable (with pkgs; [
        nil
        nixd
        nixfmt-rfc-style
      ]))

      (lib.mkIf config.monorepo.home.crypto.enable (with pkgs; [
        bitcoin
        electrum
        monero-cli
        monero-gui
      ]))

      (lib.mkIf config.monorepo.home.art.enable (with pkgs; [
        inkscape
        krita
      ]))

      (lib.mkIf config.monorepo.home.music.enable (with pkgs; [
        mpc-cli
        sox
      ]))

      (lib.mkIf config.monorepo.tor.enable (with pkgs; [
        tor-browser
        torsocks
      ]))

      (lib.mkIf config.monorepo.pipewire.enable (with pkgs; [
        helvum
      ]))
    ];

    monorepo = {
      profiles = {
        documentation.enable = lib.mkDefault true;
        pipewire.enable = lib.mkDefault true;
        tor.enable = lib.mkDefault true;
        home = {
          enable = lib.mkDefault true;
          music.enable = lib.mkDefault config.monorepo.profiles.pipewire.enable;
          hyprland.enable = lib.mkDefault true;
          email.enable = lib.mkDefault true;

          # Programming
          lang-c.enable = lib.mkDefault true;
          lang-rust.enable = lib.mkDefault true;
          lang-python.enable = lib.mkDefault true;
          lang-sol.enable = lib.mkDefault true;
          lang-sh.enable = lib.mkDefault true;
          lang-openscad.enable = lib.mkDefault true;
          lang-js.enable = lib.mkDefault true;
          lang-nix.enable = lib.mkDefault true;

          crypto.enable = lib.mkDefault true;
          art.enable = lib.mkDefault true;
        };
      };
    };
  };
}
