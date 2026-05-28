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
        # osd = {
        #     enable = true;
        #     daemons = [
        #         "7" # 8 TB /dev/sda
        #     ];
        # };
      };
    };
}
