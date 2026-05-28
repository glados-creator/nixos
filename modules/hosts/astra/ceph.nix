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
        mon = {
          enable = true;
          daemons = [
            "astra"
          ];
        };
        mgr = {
          enable = true;
          daemons = [
            "astra"
          ];
        };
        mds = {
          enable = true;
          daemons = [
            "astra"
          ];
        };
        # osd = {
        #   enable = true;
        #   daemons = [
        #     "0" # sda 500G
        #     "1" # sdc 500G
        #     "2" # sdd 500G
        #   ];
        # };
      };
    };
}
