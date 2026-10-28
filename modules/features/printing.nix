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
        cups-filters
        cups-browsed
        hplip # cmd hp-setup
        hplipWithPlugin
        gutenprint # cmd lpstat -p
      ];

      hardware.sane = {
        # scanners
        enable = true;
        openFirewall = true;
        extraBackends = with pkgs; [ sane-airscan ];
        # disable default backend
        # disabledDefaultBackends = [ "escl" ];
      };
      environment.systemPackages = with pkgs; [
        sane-airscan
        xsane # cmd scanimage -L
      ];

      # IPP-over-USB
      services.ipp-usb.enable = true; # ipp-usb status

      # user.glados
      # extraGroups = [ "scanner" "lp" ];
    };
}
