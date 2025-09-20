{ pkgs, lib, ... }:
{
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      firefox = {
        executable = "${lib.getBin pkgs.firefox-bin}/bin/firefox";
        profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
      };
      emacs = {
        executable = "${lib.getBin pkgs.emacs-pgtk}/bin/emacs";
        profile = "${pkgs.firejail}/etc/firejail/emacs.profile";
      };
      zathura = {
        executable = "${lib.getBin pkgs.zathura}/bin/zathura";
        profile = "${pkgs.firejail}/etc/firejail/zathura.profile";
      };
    };
  };
}
