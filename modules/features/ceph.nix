{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.ceph =
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
      ];

      networking.firewall = {
        allowedTCPPorts = [
          6789
          3300
        ];
        allowedTCPPortRanges = [
          {
            from = 6800;
            to = 7300;
          }
        ];
      };

      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/cluster/k3s/docs/examples/STORAGE.md
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/ceph-multi-node.nix
      # https://github.com/NixOS/nixpkgs/pull/494583
      services.ceph = {
        enable = true;
        global = {
          fsid = (builtins.readFile ./cephfsid.crt);
          monHost = "192.168.1.14,192.168.1.12,192.168.1.16";
          monInitialMembers = "stitan";
          publicNetwork = "192.168.1.0/24";
          clusterNetwork = "192.168.1.0/24";
        };
      };

      # nfs
      services.rpcbind.enable = true;
      # Rook
    };
}
