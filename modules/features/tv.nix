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
      environment.systemPackages = with pkgs; [
        libcec
        v4l-utils # cec-ctl
      ];
    };
}
