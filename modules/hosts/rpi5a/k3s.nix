{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.k3s-rpi5a-server =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      services.k3s = {
        enable = true;
        role = lib.mkForce "server";
        serverAddr = lib.mkForce ""; # "https://${controlPlaneIP}:6443";
        # token = lib.mkForce null; # clusterToken;
        # tokenFile = lib.mkForce null;
        # nodeName = config.networking.hostName;
        extraFlags = [
          "--cluster-init"
        ];
      };

    };
}
