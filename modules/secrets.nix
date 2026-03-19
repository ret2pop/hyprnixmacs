# [[file:../../config/nix.org::*Secrets][Secrets:1]]
{ config, ... }:
{
  sops = {
    defaultSopsFile = if config.monorepo.profiles.server.enable
                      then ../secrets/vps_secrets.yaml
                      else ../secrets/secrets.yaml;


    templates = if config.monorepo.profiles.server.enable then {
      "matterbridge" = {
        owner = "matterbridge";
        content = ''
  [irc.myirc]
  Server="127.0.0.1:6667"
  Nick="bridge"
  RemoteNickFormat="[{PROTOCOL}] <{NICK}> "
  UseTLS=false

  [telegram.mytelegram]
  Token="${config.sops.placeholder.telegram_token}"
  RemoteNickFormat="<({PROTOCOL}){NICK}> "
  MessageFormat="HTMLNick :"
  QuoteFormat="{MESSAGE} (re @{QUOTENICK}: {QUOTEMESSAGE})"
  QuoteLengthLimit=46
  IgnoreMessages="^/"

  [discord.mydiscord]
  Token="${config.sops.placeholder.discord_token}"
  Server="Null Identity"
  AutoWebHooks=true
  RemoteNickFormat="[{PROTOCOL}] <{NICK}> "
  PreserveThreading=true

  [[gateway]]
  name="gateway1"
  enable=true

  [[gateway.inout]]
  account="irc.myirc"
  channel="#nullring"

  [[gateway.inout]]
  account="discord.mydiscord"
  channel="ID:996282946879242262"

  [[gateway.inout]]
  account="telegram.mytelegram"
  channel="-5290629325"
  '';
      };
    } else {};

    age = {
      keyFile = "/home/${config.monorepo.vars.userName}/.config/sops/age/keys.txt";
    };

    secrets = if config.monorepo.profiles.desktop.enable then {
      mail = {
        format = "yaml";
      };
      cloudflare-dns = {
        format = "yaml";
      };
      digikey = {
        format = "yaml";
      };
      dn42 = {
        format = "yaml";
      };
    } else (if config.monorepo.profiles.server.enable then {
      znc = {
        format = "yaml";
      };

      znc_password_salt = {
        format = "yaml";
      };

      znc_password_hash = {
        format = "yaml";
      };

      matrix_bridge = {
        format = "yaml";
      };

      mail_password = {
        format = "yaml";
        owner = "maddy";
      };

      mail_monorepo_password_pi = {
        format = "yaml";
        owner = "public-inbox";
      };

      mautrix_env = {
        format = "yaml";
      };

      telegram_token = {
        format = "yaml";
      };

      discord_token = {
        format = "yaml";
      };

      mpd_password = {
        format = "yaml";
        owner = "nginx";
      };
    } else {});
  };
}
# Secrets:1 ends here
