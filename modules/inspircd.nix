{ lib, config, ... }:
{
  services.inspircd = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    modules = [ "ssl_openssl" ];
    config = ''
<server name="nullring.xyz"
        description="Nullring IRC Instance"
        network="NullRing">

<admin
       name="Preston Pan"
       nick="prestonp"
       email="ret2pop@gmail.com">

<bind
      address="0.0.0.0"
      port="6697"
      type="clients"
      ssl="openssl">

<module name="ssl_openssl">
<openssl certfile="/var/lib/acme/fullchain.pem" keyfile="/var/lib/acme/key.pem">

<power
       # hash: what hash these passwords are hashed with.
       # Requires the module for selected hash (m_md5.so, m_sha256.so
       # or m_ripemd160.so) be loaded and the password hashing module
       # (m_password_hash.so) loaded.
       # Options here are: "md5", "sha256" and "ripemd160", or one of
       # these prefixed with "hmac-", e.g.: "hmac-sha256".
       # Optional, but recommended. Create hashed passwords with:
       # /mkpasswd <hash> <password>
       #hash="sha256"

       # diepass: Password for opers to use if they need to shutdown (die)
       # a server.
       diepass=""

       # restartpass: Password for opers to use if they need to restart
       # a server.
       restartpass="">

<connect
         # name: Name to use for this connect block. Mainly used for
         # connect class inheriting.
         name="main"

         # allow: What IP addresses/hosts to allow for this block.
         allow="*"

         # maxchans: Maximum number of channels a user in this class
         # be in at one time. This overrides every other maxchans setting.
         #maxchans="30"

         # timeout: How long (in seconds) the server will wait before
         # disconnecting a user if they do not do anything on connect.
         # (Note, this is a client-side thing, if the client does not
         # send /nick, /user or /pass)
         timeout="10"

         # pingfreq: How often (in seconds) the server tries to ping connecting clients.
         pingfreq="120"

         # hardsendq: maximum amount of data allowed in a client's send queue
         # before they are dropped. Keep this value higher than the length of
         # your network's /LIST or /WHO output, or you will have lots of
         # disconnects from sendq overruns!
         # Setting this to "1M" is equivalent to "1048576", "8K" is 8192, etc.
         hardsendq="1M"

         # softsendq: amount of data in a client's send queue before the server
         # begins delaying their commands in order to allow the sendq to drain
         softsendq="8192"

         # recvq: amount of data allowed in a client's queue before they are dropped.
         # Entering "8K" is equivalent to "8192", see above.
         recvq="8K"

         # threshold: This specifies the amount of command penalty a user is allowed to have
         # before being quit or fakelagged due to flood. Normal commands have a penalty of 1,
         # ones such as /OPER have penalties up to 10.
         #
         # If you are not using fakelag, this should be at least 20 to avoid excess flood kills
         # from processing some commands.
         threshold="10"

         # commandrate: This specifies the maximum rate that commands can be processed.
         # If commands are sent more rapidly, the user's penalty will increase and they will
         # either be fakelagged or killed when they reach the threshold
         #
         # Units are millicommands per second, so 1000 means one line per second.
         commandrate="1000"

         # fakelag: Use fakelag instead of killing users for excessive flood
         #
         # Fake lag stops command processing for a user when a flood is detected rather than
         # immediately killing them; their commands are held in the recvq and processed later
         # as the user's command penalty drops. Note that if this is enabled, flooders will
         # quit with "RecvQ exceeded" rather than "Excess Flood".
         fakelag="on"

         # localmax: Maximum local connections per IP.
         
		 localmax="200"

         # globalmax: Maximum global (network-wide) connections per IP.
         
		 globalmax="200"

         # useident: Defines if users in this class must respond to a ident query or not.
         useident="no"

         # limit: How many users are allowed in this class
         limit="5000"

         # modes: Usermodes that are set on users in this block on connect.
         # Enabling this option requires that the m_conn_umodes module be loaded.
         # This entry is highly recommended to use for/with IP Cloaking/masking.
         # For the example to work, this also requires that the m_cloaking
         # module be loaded as well.
         modes="+x">


#-#-#-#-#-#-#-#-#-#-#-#-  CIDR CONFIGURATION   -#-#-#-#-#-#-#-#-#-#-#-
#                                                                     #
# CIDR configuration allows detection of clones and applying of       #
# throttle limits across a CIDR range. (A CIDR range is a group of    #
# IPs, for example, the CIDR range 192.168.1.0-192.168.1.255 may be   #
# represented as 192.168.1.0/24). This means that abuse across an ISP #
# is detected and curtailed much easier. Here is a good chart that    #
# shows how many IPs the different CIDRs correspond to:               #
# http://en.wikipedia.org/wiki/CIDR#Prefix_aggregation                #
#                                                                     #

<cidr
      # ipv4clone: specifies how many bits of an IP address should be
      # looked at for clones. The default only looks for clones on a
      # single IP address of a user. You do not want to set this
      # extremely low. (Values are 0-32).
      ipv4clone="32"

      # ipv6clone: specifies how many bits of an IP address should be
      # looked at for clones. The default only looks for clones on a
      # single IP address of a user. You do not want to set this
      # extremely low. (Values are 0-128).
      ipv6clone="128">

<channels
          # users: Maximum number of channels a user can be in at once.
          users="20"

          # opers: Maximum number of channels an oper can be in at once.
          opers="60">

#-#-#-#-#-#-#-#-#-#-#-#-#-#-# DNS SERVER -#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# If these values are not defined, InspIRCd uses the default DNS resolver
# of your system.

<dns
     # server: DNS server to use to attempt to resolve IP's to hostnames.
     # in most cases, you won't need to change this, as inspircd will
     # automatically detect the nameserver depending on /etc/resolv.conf
     # (or, on Windows, your set nameservers in the registry.)
     # Note that this must be an IP address and not a hostname, because
     # there is no resolver to resolve the name until this is defined!
     #
     # server="127.0.0.1"

     # timeout: seconds to wait to try to resolve DNS/hostname.
     timeout="5">

# An example of using an IPv6 nameserver
#<dns server="::1" timeout="5">

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#  PID FILE  -#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
#                                                                     #
# Define the path to the PID file here. The PID file can be used to   #
# rehash the ircd from the shell or to terminate the ircd from the    #
# shell using shell scripts, perl scripts, etc... and to monitor the  #
# ircd's state via cron jobs. If this is a relative path, it will be  #
# relative to the configuration directory, and if it is not defined,  #
# the default of 'inspircd.pid' is used.                              #
#                                                                     #

#<pid file="/path/to/inspircd.pid">

#-#-#-#-#-#-#-#-#-#-#-#-#- BANLIST LIMITS #-#-#-#-#-#-#-#-#-#-#-#-#-#-#
#                                                                     #
# Use these tags to customise the ban limits on a per channel basis.  #
# The tags are read from top to bottom, and any tag found which       #
# matches the channels name applies the banlimit to that channel.     #
# It is advisable to put an entry with the channel as '*' at the      #
# bottom of the list. If none are specified or no maxbans tag is      #
# matched, the banlist size defaults to 64 entries.                   #
#                                                                     #

<banlist chan="#largechan" limit="128">
<banlist chan="*" limit="69">

#-#-#-#-#-#-#-#-#-#-#-  DISABLED FEATURES  -#-#-#-#-#-#-#-#-#-#-#-#-#-#
#                                                                     #
# This tag is optional, and specifies one or more features which are  #
# not available to non-operators.                                     #
#                                                                     #
# For example you may wish to disable NICK and prevent non-opers from #
# changing their nicknames.                                           #
# Note that any disabled commands take effect only after the user has #
# 'registered' (e.g. after the initial USER/NICK/PASS on connection)  #
# so for example disabling NICK will not cripple your network.        #
#                                                                     #
# You can also define if you want to disable any channelmodes         #
# or usermodes from your users.                                       #
#                                                                     #
# `fakenonexistant' will make the ircd pretend that nonexistant       #
# commands simply don't exist to non-opers ("no such command").       #
#                                                                     #
#<disabled commands="TOPIC MODE" usermodes="" chanmodes="" fakenonexistant="yes">


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-  RTFM LINE  -#-#-#-#-#-#-#-#-#-#-#-#-#-#
#                                                                     #
#   Just remove this... Its here to make you read ALL of the config   #
#   file options ;)                                                   #

#<die value="You should probably edit your config *PROPERLY* and try again.">



#-#-#-#-#-#-#-#-#-#-#-#-#-  SERVER OPTIONS   -#-#-#-#-#-#-#-#-#-#-#-#-#
#                                                                     #
#   Settings to define which features are usable on your server.      #
#                                                                     #

<options
         # prefixquit: What (if anything) users' quit messages
         # should be prefixed with.
         prefixquit="Quit: "

         # suffixquit: What (if anything) users' quit messages
         # should be suffixed with.
         suffixquit=""

         # prefixpart: What (if anything) users' part messages
         # should be prefixed with.
         prefixpart="&quot;"
         # NOTE: Use "\"" instead of "&quot;" if not using <config format="xml">

         # suffixpart: What (if anything) users' part message
         # should be suffixed with.
         suffixpart="&quot;"

         # fixedquit: Set all users' quit messages to this value.
         #fixedquit=""

         # fixedpart: Set all users' part messages in all channels
         # to this value.
         #fixedpart=""

         # syntaxhints: If enabled, if a user fails to send the correct parameters
         # for a command, the ircd will give back some help text of what
         # the correct parameters are.
         syntaxhints="no"

         # cyclehosts: If enabled, when a user gets a host set, it will cycle
         # them in all their channels. If not, it will simply change their host
         # without cycling them.
         cyclehosts="yes"

         # cyclehostsfromuser: If enabled, the source of the mode change for
         # cyclehosts will be the user who cycled. This can look nicer, but
         # triggers anti-takeover mechanisms of some obsolete bots.
         cyclehostsfromuser="no"

         # ircumsgprefix: Use undernet-style message prefixing for NOTICE and
         # PRIVMSG. If enabled, it will add users' prefix to the line, if not,
         # it will just message the user normally.
         ircumsgprefix="no"

         # announcets: If set to yes, when the timestamp on a channel changes, all users
         # in the channel will be sent a NOTICE about it.
         announcets="yes"

         # allowmismatch: Setting this option to yes will allow servers to link even
         # if they don't have the same "optionally common" modules loaded. Setting this to
         # yes may introduce some desyncs and unwanted behaviour.
         allowmismatch="no"

         # defaultbind: Sets the default for <bind> tags without an address. Choices are
         # ipv4 or ipv6; if not specified, IPv6 will be used if your system has support,
         # falling back to IPv4 otherwise.
         defaultbind="auto"

         # hostintopic: If enabled, channels will show the host of the topic setter
         # in the topic. If set to no, it will only show the nick of the topic setter.
         hostintopic="yes"

         # pingwarning: If a server does not respond to a ping within x seconds,
         # it will send a notice to opers with snomask +l informing that the server
         # is about to ping timeout.
         pingwarning="15"

         # serverpingfreq: How often pings are sent between servers (in seconds).
         serverpingfreq="60"

         # defaultmodes: What modes are set on a empty channel when a user
         # joins it and it is unregistered.
         defaultmodes="nt"

         # moronbanner: This is the text that is sent to a user when they are
         # banned from the server.
         moronbanner="You're banned! Email abuse@example.com with the ERROR line below for help."

         # exemptchanops: exemptions for channel access restrictions based on prefix.
         exemptchanops="nonick:v flood:o"

         # invitebypassmodes: This allows /invite to bypass other channel modes.
         # (Such as +k, +j, +l, etc.)
         invitebypassmodes="yes"

         # nosnoticestack: This prevents snotices from 'stacking' and giving you
         # the message saying '(last message repeated X times)'. Defaults to no.
         nosnoticestack="no"

         # welcomenotice: When turned on, this sends a NOTICE to connecting users
         # with the text Welcome to <networkname>! after successful registration.
         # Defaults to yes.
         welcomenotice="yes">


#-#-#-#-#-#-#-#-#-#-#-# PERFORMANCE CONFIGURATION #-#-#-#-#-#-#-#-#-#-#
#                                                                     #

<performance
             # netbuffersize: Size of the buffer used to receive data from clients.
             # The ircd may only read this amount of text in 1 go at any time.
             netbuffersize="10240"

             # somaxconn: The maximum number of connections that may be waiting
             # in the accept queue. This is *NOT* the total maximum number of
             # connections per server. Some systems may only allow this to be up
             # to 5, while others (such as Linux and *BSD) default to 128.
             somaxconn="128"

             # limitsomaxconn: By default, somaxconn (see above) is limited to a
             # safe maximum value in the 2.0 branch for compatibility reasons.
             # This setting can be used to disable this limit, forcing InspIRCd
             # to use the value specified above.
             limitsomaxconn="true"

             # softlimit: This optional feature allows a defined softlimit for
             # connections. If defined, it sets a soft max connections value.
             softlimit="12800"

             # quietbursts: When syncing or splitting from a network, a server
             # can generate a lot of connect and quit messages to opers with
             # +C and +Q snomasks. Setting this to yes squelches those messages,
             # which makes it easier for opers, but degrades the functionality of
             # bots like BOPM during netsplits.
             quietbursts="yes"

             # nouserdns: If enabled, no DNS lookups will be performed on
             # connecting users. This can save a lot of resources on very busy servers.
             nouserdns="no">

#-#-#-#-#-#-#-#-#-#-#-# SECURITY CONFIGURATION  #-#-#-#-#-#-#-#-#-#-#-#
#                                                                     #

<security

          # announceinvites: This option controls which members of the channel
          # receive an announcement when someone is INVITEd. Available values:
          # 'none' - don't send invite announcements
          # 'all' - send invite announcements to all members
          # 'ops' - send invite announcements to ops and higher ranked users
          # 'dynamic' - send invite announcements to halfops (if available) and
          #             higher ranked users. This is the recommended setting.
          announceinvites="dynamic"

          # hidemodes: If enabled, then the listmodes given will be hidden
          # from users below halfop. This is not recommended to be set on +b
          # as it may break some functionality in popular clients such as mIRC.
          hidemodes="eI"

          # hideulines: If this value is set to yes, U-lined servers will
          # be hidden from non-opers in /links and /map.
          hideulines="no"

          # flatlinks: If this value is set to yes, /map and /links will
          # be flattened when shown to non-opers.
          flatlinks="no"

          # hidewhois: When defined, the given text will be used in place
          # of the server a user is on when whoised by a non-oper. Most
          # networks will want to set this to something like "*.netname.net"
          # to conceal the actual server a user is on.
          # Note that enabling this will cause users' idle times to only be
          # shown when the format /WHOIS <nick> <nick> is used.
          hidewhois=""

          # hidebans: If this value is set to yes, when a user is banned ([gkz]lined)
          # only opers will see the ban message when the user is removed
          # from the server.
          hidebans="no"

          # hidekills: If defined, replaces who set a /kill with a custom string.
          hidekills=""

          # hideulinekills: Hide kills from clients of ulined servers from server notices.
          hideulinekills="yes"

          # hidesplits: If enabled, non-opers will not be able to see which
          # servers split in a netsplit, they will only be able to see that one
          # occurred (If their client has netsplit detection).
          hidesplits="no"

          # maxtargets: Maximum number of targets per command.
          # (Commands like /notice, /privmsg, /kick, etc)
          maxtargets="20"

          # customversion: Displays a custom string when a user /version's
          # the ircd. This may be set for security reasons or vanity reasons.
          customversion=""

          # operspywhois: show opers (users/auspex) the +s channels a user is in. Values:
          #  splitmsg  Split with an explanatory message
          #  yes       Split with no explanatory message
          #  no        Do not show
          operspywhois="no"

          # runasuser: If this is set, InspIRCd will attempt to switch
          # to run as this user, which allows binding of ports under 1024.
          # You should NOT set this unless you are starting as root.
          # NOT SUPPORTED/NEEDED UNDER WINDOWS.
          #runasuser=""

          # runasgroup: If this is set, InspIRCd will attempt to switch
          # to run as this group, which allows binding of ports under 1024.
          # You should NOT set this unless you are starting as root.
          # NOT SUPPORTED/NEEDED UNDER WINDOWS.
          #runasgroup=""

          # restrictbannedusers: If this is set to yes, InspIRCd will not allow users
          # banned on a channel to change nickname or message channels they are
          # banned on.
          restrictbannedusers="yes"

          # genericoper: Setting this value to yes makes all opers on this server
          # appear as 'is an IRC operator' in their WHOIS, regardless of their
          # oper type, however oper types are still used internally. This only
          # affects the display in WHOIS.
          genericoper="no"

          # userstats: /stats commands that users can run (opers can run all).
          userstats="Pu">

<limits
        # maxnick: Maximum length of a nickname.
        maxnick="500"

        # maxchan: Maximum length of a channel name.
        maxchan="500"

        # maxmodes: Maximum number of mode changes per line.
        maxmodes="20"

        # maxident: Maximum length of a ident/username.
        maxident="500"

        # maxquit: Maximum length of a quit message.
        maxquit="255"

        # maxtopic: Maximum length of a channel topic.
        maxtopic="307"

        # maxkick: Maximum length of a kick message.
        maxkick="255"

        # maxgecos: Maximum length of a GECOS (realname).
        maxgecos="128"

        # maxaway: Maximum length of an away message.
        maxaway="200">

<log method="file" type="* -USERINPUT -USEROUTPUT" level="default" target="logs/ircd.log">

#-#-#-#-#-#-#-#-#-#-#-#-#-  WHOWAS OPTIONS   -#-#-#-#-#-#-#-#-#-#-#-#-#
#                                                                     #
# This tag lets you define the behaviour of the /whowas command of    #
# your server.                                                        #
#                                                                     #

<whowas
        # groupsize: Maximum entries per nick shown when performing
        # a /whowas nick.
        groupsize="10"

        # maxgroups: Maximum number of nickgroups that can be added to
        # the list so that /whowas does not use a lot of resources on
        # large networks.
        maxgroups="100000"

        # maxkeep: Maximum time a nick is kept in the whowas list
        # before being pruned. Time may be specified in seconds,
        # or in the following format: 1y2w3d4h5m6s. Minimum is
        # 1 hour.
        maxkeep="3d">

<badnick
         # nick: Nick to disallow. Wildcards are supported.
         nick="ChanServ"

         # reason: Reason to display on /nick.
         reason="Reserved For Services">

<badnick nick="NickServ" reason="Reserved For Services">
<badnick nick="OperServ" reason="Reserved For Services">
<badnick nick="MemoServ" reason="Reserved For Services">

<badhost host="root@*" reason="Don't IRC as root!">

<insane
        # hostmasks: Allow bans with insane hostmasks. (over-reaching bans)
        hostmasks="no"

        # ipmasks: Allow bans with insane ipmasks. (over-reaching bans)
        ipmasks="no"

        # nickmasks: Allow bans with insane nickmasks. (over-reaching bans)
        nickmasks="no"

        # trigger: What percentage of users on the network to trigger
        # specifying an insane ban as. The default is 95.5%, which means
        # if you have a 1000 user network, a ban will not be allowed if it
        # will be banning 955 or more users.
        trigger="95.5">
'';
  };
}
