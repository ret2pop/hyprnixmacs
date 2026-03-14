# [[file:../../config/nix.org::*Icecast][Icecast:1]]
{ lib, ... }:
{
  services.icecast = {
    enable = lib.mkDefault false;
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
}
# Icecast:1 ends here
