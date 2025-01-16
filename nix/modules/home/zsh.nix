{ lib, config, pkgs, ... }:
{
  enable = lib.mkDefault config.monorepo.profiles.home.enable;
  initExtra = ''
    umask 0077
    export EXTRA_CCFLAGS="-I/usr/include"
    source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
    export QT_QPA_PLATFORM="wayland"
    '';

  localVariables = {
    EDITOR = "emacsclient --create-frame --alternate-editor=vim";
    INPUT_METHOD = "fcitx";
    QT_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    XIM_SERVERS = "fcitx";
    WXSUPPRESS_SIZER_FLAGS_CHECK = "1";
  };

  shellAliases = {
    c = "clear";
    g = "git";
    v = "vim";
    py = "python3";
    rb = "sudo nixos-rebuild switch --flake .#continuity";
    nfu = "cd ~/monorepo/nix && git add . && git commit -m \"new flake lock\" &&  nix flake update";
    usite
    = "cd ~/monorepo/publish-org-roam-ui && bash local.sh && rm -rf ~/website_html/graph_view; cp -r ~/monorepo/publish-org-roam-ui/out ~/website_html/graph_view && rsync -azvP --chmod=\"Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r\" ~/website_html/ root@${config.vars.remoteHost}:/usr/share/nginx/ret2pop/";
    sai = "eval \"$(ssh-agent -s)\" && ssh-add ~/.ssh/id_ed25519 && ssh-add -l";
    i3 = "exec ${pkgs.i3-gaps}/bin/i3";
  };
  loginExtra = ''
      if [[ "$(tty)" = "/dev/tty1" && -f "$HOME/.monorepo" ]]; then
          exec Hyprland
      fi
      if [[ ! -f "$HOME/.monorepo" ]]; then
        post-install
      fi
    '';
}
