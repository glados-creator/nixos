{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.tailscale =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      # or zerotierone
      services.tailscale = {
        enable = true;
        extraUpFlags = [ "--accept-dns=false" ];
      };
    };
}
