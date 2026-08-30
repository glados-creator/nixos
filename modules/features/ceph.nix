{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.CommunCeph =

    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        ceph
        ceph-csi
        libceph
        ceph-client
      ];

      networking.firewall = {
        allowedTCPPorts = [
          6789
          3300
        ];
        allowedTCPPortRanges = [
          {
            from = 6800;
            to = 9283;
          }
        ];
      };

      # nfs
      services.rpcbind.enable = true;
      # Rook

      services.ceph = {
        enable = true;
        global = {
          fsid = (builtins.readFile ./cephfsid.crt); # uuidgen
          monHost = "192.168.1.14";
          monInitialMembers = "stitan";
          publicNetwork = "192.168.1.0/24";
          clusterNetwork = "192.168.1.0/24";
        };
      };
    };
}
