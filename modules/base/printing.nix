{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.printing =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      # enable printing cups
      services.printing = {
        enable = true;
        openFirewall = true;
      };
      # hp deskjet 36xx -> hplip
      # canon pixma 29xx -> gutenprint
      services.printing.drivers = with pkgs; [
        hplip
        gutenprint
      ];

      hardware.sane = {
        # scanners
        enable = true;
        openFirewall = true;
      };
      environment.systemPackages = with pkgs; [
        sane-airscan # scanner
        xsane # scanner
      ];
    };
}
