{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.Ceph =

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
    };
}
