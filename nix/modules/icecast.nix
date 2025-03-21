{ lib, config, ... }:
{
  services.icecast = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    listen.address = "0.0.0.0";
    extraConfig = ''
<mount type="default">
  <public>0</public>
  <intro>/stream.m3u</intro>
  <max-listener-duration>3600</max-listener-duration>
  <authentication type="url">
    <option name="mount_add" value="http://auth.example.org/stream_start.php"/>
  </authentication>
  <http-headers>
    <header name="foo" value="bar" />
  </http-headers>
</mount>
'';
  };
  admin.password = "changeme";
}
