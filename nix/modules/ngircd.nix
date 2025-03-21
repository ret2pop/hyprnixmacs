{ lib, config, ... }:
{
  services.ngircd = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    config = ''
[Global]
	Name = nullring.xyz
	Info = NullRing IRC Instance
  Listen = 0.0.0.0
  MotdFile = /etc/motd.txt
	Network = NullRing
	Ports = 6667
[Options]
	PAM = no
[SSL]
	CertFile = /var/lib/acme/nullring.xyz/fullchain.pem
	CipherList = HIGH:!aNULL:@STRENGTH:!SSLv3
	KeyFile = /var/lib/acme/nullring.xyz/key.pem
	Ports = 6697
'';
  };
  environment.etc."motd.txt" = {
    source = ../data/motd.txt;
    mode = "644";
    user = "ngircd";
    group = "ngircd";
  };
}
