{ lib, config, pkgs, ... }:
{
  enable = lib.mkDefault config.monorepo.profiles.home.enable;
  policies = {
    EnableTrackingProtection = true;
    OfferToSaveLogins = false;
  };
  package = pkgs.firefox-wayland;
  profiles = {
    default = {
      id = 0;
      name = "default";
      isDefault = true;

      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        tree-style-tab
        firefox-color
        vimium
      ]
      ++ (lib.optional
        config.monorepo.profiles.home.crypto.enable pkgs.nur.repos.rycee.firefox-addons.metamask);

      settings = {
        media = {
          memory_cache_max_size = 65536;
          cache_readahead_limit = 7200;
          cache_resume_threshold = 3600;
          peerconnection.ice = {
            proxy_only_if_behind_proxy = true;
            default_address_only = true;
          };
        };

        gfx = {
          content.skia-font-cache-size = 20;
          canvas.accelerated = {
            cache-items = 4096;
            cache-size = 512;
          };
        };

        network = {
          http = {
            max-connections = 1800;
            max-persistent-connections-per-server = 10;
            max-urgent-start-excessive-connections-per-host = 5;
            referer.XOriginTrimmingPolicy = 2;
          };

          buffer.cache = {
            size = 262144;
            count = 128;
          };

          dns = {
            max_high_priority_threads = 8;
            disablePrefetch = true;
          };

          pacing.requests.enabled = false;
          dnsCacheExpiration = 3600;
          ssl_tokens_cache_capacity = 10240;
          prefetch-next = false;
          predictor.enabled = false;
          cookie.sameSite.noneRequiresSecure = true;
          IDN_show_punycode = true;
          auth.subresource-http-auth-allow = 1;
          captive-portal-service.enabled = false;
          connectivity-service.enabled = false;
        };

        browser = {
          download = {
            always_ask_before_handling_new_types = true;
            manager.addToRecentDocs = false;
            open_pdf_attachments_inline = true;
            start_downloads_in_tmp_dir = true;
          };

          urlbar = {
            suggest.quicksuggest.sponsored = false;
            suggest.quicksuggest.nonsponsored = false;
            suggest.calculator = true;
            update2.engineAliasRefresh = true;
            unitConversion.enabled = true;
            trending.featureGate = false;
          };

          search = {
            separatePrivateDefault.ui.enabled = true;
            suggest.enabled = false;
          };

          newtabpage.activity-stream = {
            feeds = {
              topsites = false;
              section.topstories = false;
              telemetry = false;
            };
            asrouter.userprefs.cfr = {
              addons = false;
              features = false;
            };
            telemetry = false;
          };

          privatebrowsing = {
            vpnpromourl = "";
            forceMediaMemoryCache = true;
          };

          display = {
            focus_ring_on_anything = true;
            focus_ring_style = 0;
            focus_ring_width = 0;
          };

          cache.jsbc_compression_level = 3;
          helperApps.deleteTempFileOnExit = true;
          uitour.enabled = false;
          sessionstore.interval = 60000;
          formfill.enable = false;
          xul.error_pages.expert_bad_cert = true;
          contentblocking.category = "strict";
          ping-centre.telemetry = false;
          discovery.enabled = false;
          shell.checkDefaultBrowser = false;
          preferences.moreFromMozilla = false;
          tabs.tabmanager.enabled = false;
          aboutConfig.showWarning = false;
          aboutwelcome.enabled = false;
          bookmarks.openInTabClosesMenu = false;
          menu.showViewImageInfo = true;
          compactmode.show = true;
          safebrowsing.downloads.remote.enabled = false;
          tabs.crashReporting.sendReport = false;
          crashReports.unsubmittedCheck.autoSubmit2 = false;
          privateWindowSeparation.enabled = false;
        };

        security = {
          mixed_content = {
            block_display_content = true;
            upgrade_display_content = true;
          };
          insecure_connection_text = {
            enabled = true;
            pbmode.enabled = true;
          };
          OCSP.enabled = 0;
          remote_settings.crlite_filters.enabled = true;
          pki.crlite_mode = 2;
          ssl.treat_unsafe_negotiation_as_broken = true;
          tls.enable_0rtt_data = false;
        };

        toolkit = {
          telemetry = {
            unified = false;
            enabled = false;
            server = "data:,";
            archive.enabled = false;
            newProfilePing.enabled = false;
            shutdownPingSender.enabled = false;
            updatePing.enabled = false;
            bhrPing.enabled = false;
            firstShutdownPing.enabled = false;
            coverage.opt-out = true;
          };
          coverage = {
            opt-out = true;
            endpoint.base = "";
          };
          legacyUserProfileCustomizations.stylesheets = true;
        };

        dom = {
          security = {
            https_first = true;
            https_first_schemeless = true;
            sanitizer.enabled = true;
          };
          enable_web_task_scheduling = true;
        };

        layout = {
          css = {
            grid-template-masonry-value.enabled = true;
            has-selector.enabled = true;
            prefers-color-scheme.content-override = 2;
          };
          word_select.eat_space_to_next_word = false;
        };

        urlclassifier = {
          trackingSkipURLs = "*.reddit.com, *.twitter.com, *.twimg.com, *.tiktok.com";
          features.socialtracking.skipURLs = "*.instagram.com, *.twitter.com, *.twimg.com";
        };

        privacy = {
          globalprivacycontrol.enabled = true;
          history.custom = true;
          userContext.ui.enabled = true;
        };

        full-screen-api = {
          transition-duration = {
            enter = "0 0";
            leave = "0 0";
          };
          warning = {
            delay = -1;
            timeout = 0;
          };
        };

        permissions.default = {
          desktop-notification = 2;
          geo = 2;
        };

        signon = {
          formlessCapture.enabled = false;
          privateBrowsingCapture.enabled = false;
        };

        datareporting = {
          policy.dataSubmissionEnabled = false;
          healthreport.uploadEnabled = false;
        };

        extensions = {
          pocket.enabled = false;
          getAddons.showPane = false;
          htmlaboutaddons.recommendations.enabled = false;
          postDownloadThirdPartyPrompt = false;
        };

        app = {
          shield.optoutstudies.enabled = false;
          normandy.enabled = false;
          normandy.api_url = "";
        };

        image.mem.decode_bytes_at_a_time = 32768;
        editor.truncate_user_pastes = false;
        pdfjs.enableScripting = false;
        geo.provider.network.url = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
        permissions.manager.defaultsUrl = "";
        webchannel.allowObject.urlWhitelist = "";
        breakpad.reportURL = "";
        captivedetect.canonicalURL = "";
        cookiebanners.service.mode = 1;
        findbar.highlightAll = true;
        content.notify.interval = 100000;
      };
    };
  };
}
