{ lib, config, ... }:
{
  services.mautrix-discord = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    environmentFile = "/run/secrets/mautrix_env";
    settings = {
      bridge = {
        animated_sticker = {
          args = {
            fps = 25;
            height = 320;
            width = 320;
          };
          target = "webp";
        };
        autojoin_thread_on_open = true;
        avatar_proxy_key = "generate";
        backfill = {
          forward_limits = {
            initial = {
              channel = 0;
              dm = 0;
              thread = 0;
            };
            max_guild_members = -1;
            missed = {
              channel = 0;
              dm = 0;
              thread = 0;
            };
          };
        };
        cache_media = "unencrypted";
        channel_name_template = "{{if or (eq .Type 3) (eq .Type 4)}}{{.Name}}{{else}}#{{.Name}}{{end}}";
        command_prefix = "!discord";
        custom_emoji_reactions = true;
        delete_guild_on_leave = true;
        delete_portal_on_channel_delete = false;
        delivery_receipts = false;
        direct_media = {
          allow_proxy = true;
          enabled = false;
          server_key = "generate";
        };
        displayname_template = "{{if .Webhook}}Webhook{{else}}{{or .GlobalName .Username}}{{if .Bot}} (bot){{end}}{{end}}";
        double_puppet_allow_discovery = true;
        double_puppet_server_map = { };
        embed_fields_as_tables = true;
        enable_webhook_avatars = true;
        encryption = {
          allow = false;
          allow_key_sharing = false;
          appservice = false;
          default = false;
          delete_keys = {
            delete_fully_used_on_decrypt = false;
            delete_on_device_delete = false;
            delete_outbound_on_ack = false;
            delete_outdated_inbound = false;
            delete_prev_on_new_session = false;
            dont_store_outbound = false;
            periodically_delete_expired = false;
            ratchet_on_decrypt = false;
          };
          msc4190 = false;
          plaintext_mentions = false;
          require = false;
          rotation = {
            disable_device_change_key_rotation = false;
            enable_custom = false;
            messages = 100;
            milliseconds = 604800000;
          };
          verification_levels = {
            receive = "unverified";
            send = "unverified";
            share = "cross-signed-tofu";
          };
        };
        federate_rooms = true;
        guild_name_template = "{{.Name}}";
        login_shared_secret_map = { };
        management_room_text = {
          additional_help = "";
          welcome = "Hello, I'm a Discord bridge bot.";
          welcome_connected = "Use `help` for help.";
          welcome_unconnected = "Use `help` for help or `login` to log in.";
        };
        message_error_notices = true;
        message_status_events = false;
        mute_channels_on_create = false;
        permissions = {
          "@${config.monorepo.vars.internetName}:matrix.${config.monorepo.vars.orgHost}" = "admin";
          "*" = "user";
        };
        portal_message_buffer = 128;
        prefix_webhook_messages = true;
        private_chat_portal_meta = "default";
        provisioning = {
          debug_endpoints = false;
          prefix = "/_matrix/provision";
          shared_secret = "generate";
        };
        public_address = null;
        resend_bridge_info = false;
        restricted_rooms = false;
        startup_private_channel_create_limit = 5;
        sync_direct_chat_list = false;
        use_discord_cdn_upload = true;
        username_template = "discord_{{.}}";
      };

      appservice = {
        address = "http://localhost:29334";
        hostname = "0.0.0.0";
        port = 29334;
        id = "discord";
        bot = {
          username = "discordbot";
          displayname = "Discord bridge bot";
          avatar = "mxc://maunium.net/nIdEykemnwdisvHbpxflpDlC";
        };
        ephemeral_events = true;
        async_transactions = false;
        database = {
          type = "sqlite3";
          uri = "file:${config.services.mautrix-discord.dataDir}/mautrix-discord.db?_txlock=immediate";
          max_open_conns = 20;
          max_idle_conns = 2;
          max_conn_idle_time = null;
          max_conn_lifetime = null;
        };
        as_token = "$MAUTRIX_DISCORD_APPSERVICE_AS_TOKEN";
        hs_token = "$MAUTRIX_DISCORD_APPSERVICE_HS_TOKEN";
      };

      dataDir = "/var/lib/mautrix-discord";
      homeserver = {
        async_media = false;
        message_send_checkpoint_endpoint = null;
        ping_interval_seconds = 0;
        software = "standard";
        status_endpoint = null;
        websocket = false;
        domain = "matrix.${config.monorepo.vars.orgHost}";
        address = "http://localhost:6167";
      };
    };
  };
}
