{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.jupiterCeph =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      # fileSystems."/var/lib/ceph/osd/ceph-3" = {
      #   device = "/dev/disk/by-id/eb7dd9e2-6ac2-492f-96e7-d842b9b63f12"; # sda 2T
      #   fsType = "xfs";
      # };
      #
      # fileSystems."/var/lib/ceph/osd/ceph-4" = {
      #   device = "/dev/disk/by-id/4a6d4da6-dc84-475e-86ca-a861f8f5e068"; # sdb 1T
      #   fsType = "xfs";
      # };
      #
      # fileSystems."/var/lib/ceph/osd/ceph-5" = {
      #   device = "/dev/disk/by-id/5b740ad2-c7d6-4c50-a395-d18e89313519"; # sdc 2T
      #   fsType = "xfs";
      # };
      #
      # fileSystems."/var/lib/ceph/osd/ceph-6" = {
      #   device = "/dev/disk/by-id/5dc69193-402e-4de2-b9e5-70112cf69fba"; # sdd 2T
      #   fsType = "xfs";
      # };

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

      # nfs
      services.rpcbind.enable = true;
      # Rook

      services.ceph = {
        enable = true;
        global = {
          fsid = (builtins.readFile ../../features/cephfsid.crt); # uuidgen
          # monHost = "192.168.1.14";
          # monInitialMembers = "stitan";
          publicNetwork = "192.168.1.0/24";
          clusterNetwork = "192.168.1.0/24";
        };
        mon = {
          enable = false;
          # daemons = [
          #   "jupiter"
          # ];
        };
        mgr = {
          enable = false;
          # daemons = [
          #   "jupiter"
          # ];
        };
        mds = {
          enable = false;
          # daemons = [
          #   "jupiter"
          # ];
        };
        # osd = {
        #     enable = true;
        #     daemons = [
        #         "3" # sda 2T
        #         "4" # sdb 1T
        #         "5" # sdc 2T
        #         "6" # sdd 2T
        #     ];
        # };
      };
    };
}
