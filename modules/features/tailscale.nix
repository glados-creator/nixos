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
      services.tailscale = {
        enable = true;
        extraUpFlags = [ "--accept-dns=false" ];
      };
    };
}
