{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.stitanCeph =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      services.ceph = {
        enable = true;
        global = {
          fsid = (builtins.readFile ../../features/cephfsid.crt); # uuidgen
          monHost = "192.168.1.14";
          monInitialMembers = "stitan";
          publicNetwork = "192.168.1.0/24";
          clusterNetwork = "192.168.1.0/24";
        };
        mon = {
          enable = true;
          daemons = [
            "stitan"
          ];
        };
        mgr = {
          enable = true;
          daemons = [
            "stitan"
          ];
        };
        mds = {
          enable = true;
          daemons = [
            "stitan"
          ];
        };
        osd = {
          enable = true;
          daemons = [
            "0" # 8 TB /dev/sdb
          ];
        };
      };
    };
}
