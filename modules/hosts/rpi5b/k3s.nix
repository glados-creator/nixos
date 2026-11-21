{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.k3s-rpi5b-server =
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
        # serverAddr = "https://192.168.1.24:6443";
        # tokenFile = "/etc/k3s/token";
        # nodeName = config.networking.hostName;
        extraFlags = [
          "--node-label=server=true"
        ];
      };

    };
}
