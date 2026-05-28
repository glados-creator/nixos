{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.sunshine =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        sunshine # GameStream server
        moonlight-qt # GameStream client
      ];

      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = true;
      };
    };
}
