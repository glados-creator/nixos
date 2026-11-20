{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.tv =
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
