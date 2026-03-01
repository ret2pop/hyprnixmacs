{ config, ... }:
{
  sops = {
    defaultSopsFile = if config.monorepo.profiles.server.enable
                      then ../secrets/vps_secrets.yaml
                      else ../secrets/secrets.yaml;


    templates = if config.monorepo.profiles.server.enable then {
      "public-inbox-netrc" = {
        owner = "public-inbox";
        group = "public-inbox";
        mode = "0400";
        content = (builtins.concatStringsSep "\n" (builtins.map (x: "machine mail.${config.monorepo.vars.orgHost} login ${x}@${config.monorepo.vars.orgHost} password ${config.sops.placeholder."mail_monorepo_password_pi"}") config.monorepo.vars.projects)) + ''
machine mail.${config.monorepo.vars.orgHost} login discussion@${config.monorepo.vars.orgHost} password ${config.sops.placeholder."mail_monorepo_password_pi"}'';
      };
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

    secrets = if ! config.monorepo.profiles.server.enable then {
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
    } else {
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
      livekit_secret = {
        format = "yaml";
        mode = "0444";
      };
      livekit = {
        format = "yaml";
      };
      mail_password = {
        format = "yaml";
        owner = "maddy";
      };

      mail_monorepo_password = {
        format = "yaml";
        owner = "maddy";
      };

      mail_monorepo_password_pi = {
        format = "yaml";
        owner = "public-inbox";
      };

      conduit_secrets = {
        format = "yaml";
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
      ntfy = {
        format = "yaml";
        owner = "ntfy-sh";
      };
    };
  };
}
