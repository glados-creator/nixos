{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.k3sserver =
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
        serverAddr = lib.mkForce "" ; # "https://${controlPlaneIP}:6443";
        token = lib.mkForce "" ; # clusterToken;
        nodeName = config.networking.hostName;
        extraFlags = [
          "--cluster-init"
          "--node-label=server=true"
          # "--node-label=agent=true"
        ];
      };
      
    };
}
