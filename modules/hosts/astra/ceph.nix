{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.astraCeph =

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
          enable = false;
          daemons = [
            "stitan"
          ];
        };
        mgr = {
          enable = false;
          daemons = [
            "stitan"
          ];
        };
        mds = {
          enable = false;
          daemons = [
            "stitan"
          ];
        };
        osd = {
          enable = true;
          daemons = [
            "5" # sda 500G
            "6" # sdc 500G
            "7" # sdd 500G
          ];
        };
      };
    };
}
