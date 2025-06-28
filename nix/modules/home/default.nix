{ lib, config, pkgs, ... }:
{
  imports = [
    ../vars.nix
    ./fcitx.nix
    ./secrets.nix
    ./emacs.nix
    ./firefox.nix
    ./git.nix
    ./hyprland.nix
    ./mpv.nix
    ./yt-dlp.nix
    ./wofi.nix
    ./kitty.nix
    ./waybar.nix
    ./zsh.nix
    ./mbsync.nix
    ./msmtp.nix
    ./gammastep.nix
    ./mpd.nix
    ./mako.nix
    ./user.nix
  ];

  options = {
    monorepo.profiles = {
	    enable = lib.mkEnableOption "Enables home manager desktop configuration";
	    # Programs
      graphics.enable = lib.mkEnableOption "Enables graphical programs for user";
	    lang-c.enable = lib.mkEnableOption "Enables C language support";
	    lang-sh.enable = lib.mkEnableOption "Enables sh language support";
	    lang-rust.enable = lib.mkEnableOption "Enables Rust language support";
	    lang-python.enable = lib.mkEnableOption "Enables python language support";
	    lang-sol.enable = lib.mkEnableOption "Enables solidity language support";
	    lang-openscad.enable = lib.mkEnableOption "Enables openscad language support";
	    lang-js.enable = lib.mkEnableOption "Enables javascript language support";
	    lang-nix.enable = lib.mkEnableOption "Enables nix language support";
	    lang-coq.enable = lib.mkEnableOption "Enables coq language support";
	    lang-haskell.enable = lib.mkEnableOption "Enables haskell language support";

	    crypto.enable = lib.mkEnableOption "Enables various cryptocurrency wallets";
	    art.enable = lib.mkEnableOption "Enables various art programs";
	    music.enable = lib.mkEnableOption "Enables mpd";
	    workstation.enable = lib.mkEnableOption "Enables workstation packages (music production and others)";
	    cuda.enable = lib.mkEnableOption "Enables CUDA user package builds";
	    hyprland.enable = lib.mkEnableOption "Enables hyprland";

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

  config = {
    home.packages = (if config.monorepo.profiles.email.enable then [ pkgs.mu ] else [])
					          ++
					          (if config.monorepo.profiles.lang-c.enable then (with pkgs; [
						          autobuild
						          clang
						          gdb
						          gnumake
						          bear
						          clang-tools
					          ]) else [])
                    ++
                    (if config.monorepo.profiles.workstation.enable then (with pkgs; [
                      mumble
                    ]) else [])
                    ++
					          (if config.monorepo.profiles.lang-js.enable then (with pkgs; [
						          nodejs
						          bun
						          yarn
						          typescript
                      typescript-language-server
						          vscode-langservers-extracted
					          ]) else [])
					          ++
					          (if config.monorepo.profiles.lang-rust.enable then (with pkgs; [
						          cargo
						          rust-analyzer
						          rustfmt
					          ]) else [])
					          ++
					          (if config.monorepo.profiles.lang-python.enable then (with pkgs; [
                      poetry
						          python3
						          python312Packages.jedi
					          ]) else [])
					          ++
					          (if config.monorepo.profiles.lang-sol.enable then (with pkgs; [
						          solc
					          ]) else [])
					          ++
					          (if config.monorepo.profiles.lang-openscad.enable then (with pkgs; [
						          openscad
						          openscad-lsp
					          ]) else [])
					          ++
					          (if config.monorepo.profiles.lang-sh.enable then (with pkgs; [
						          bash-language-server
					          ]) else [])
					          ++
					          (if config.monorepo.profiles.lang-haskell.enable then (with pkgs; [
                      haskell-language-server
                      haskellPackages.hlint
                      ghc
					          ]) else [])
					          ++
					          (if config.monorepo.profiles.lang-coq.enable then (with pkgs; [
						          coq
					          ]) else [])
					          ++
					          (if config.monorepo.profiles.lang-nix.enable then (with pkgs; [
						          nil
						          nixd
						          nixfmt-rfc-style
                      nix-prefetch-scripts
					          ]) else [])
					          ++
					          (if config.monorepo.profiles.crypto.enable then (with pkgs; [
						          bitcoin
						          electrum
						          monero-cli
						          monero-gui
					          ]) else [])
					          ++
					          (if config.monorepo.profiles.art.enable then (with pkgs; [
						          inkscape
						          krita
					          ]) else [])
					          ++
					          (if config.monorepo.profiles.music.enable then (with pkgs; [
						          mpc-cli
						          sox
					          ]) else [])
					          ++
					          (if config.monorepo.profiles.workstation.enable then (with pkgs; [
			                alsa-utils
			                alsa-scarlett-gui
				              ardour
				              audacity
					            blender
                      foxdot
			                fluidsynth
			                qjackctl
			                qsynth
			                qpwgraph
			                imagemagick
                      supercollider
			                inkscape
			                kdePackages.kdenlive
			                kicad
                      murmur
					          ]) else []);

    monorepo.profiles = {
	    enable = lib.mkDefault true;
	    music.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
	    hyprland.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
	    email.enable = lib.mkDefault (true && config.monorepo.profiles.enable);

	    # Programming
      graphics.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
	    lang-c.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
	    lang-rust.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
	    lang-python.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
	    lang-sol.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
	    lang-sh.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
	    lang-openscad.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
	    lang-js.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
	    lang-nix.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
	    lang-coq.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
	    lang-haskell.enable = lib.mkDefault (true && config.monorepo.profiles.enable);

	    crypto.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
	    art.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
	    workstation.enable = lib.mkDefault (true && config.monorepo.profiles.enable);
    };
  };
}
