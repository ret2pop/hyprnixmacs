let
  # I'm ret2pop! What's your name?
  internetName = "ret2pop";
in
{
  # Name of spontaneity box
  remoteHost = "${internetName}.net";

  # Your internet name
  internetName = internetName;

  # Name of your organization
  orgHost = "nullring.xyz";

  # Hostnames of my systems
  hostnames = [
    "affinity"
    "continuity"
    "spontaneity"
    "installer"
  ];
}
