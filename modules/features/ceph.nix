{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.Ceph =
    { config, pkgs, lib, ... }:
    let
      kver = config.boot.kernelPackages.kernel.modDirVersion;
      kmods = "/run/booted-system/kernel-modules/lib/modules/${kver}";
    in
    {
      boot.kernelModules = [ "rbd" "ceph" "libceph" ];

      systemd.tmpfiles.rules = [
        "C+ /lib/modules/${kver} - - - - ${config.system.modulesTree}/lib/modules/${kver}"
      ];

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
