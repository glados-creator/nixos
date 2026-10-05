{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.bleutooth =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      # bleutooth motherducker
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;
      hardware.usb-modeswitch.enable = true;
      services.udev.packages = with pkgs; [ usb-modeswitch ];
      services.blueman.enable = true;

      services.udev.extraRules = ''
        # Run usb-modeswitch when your specific device is detected
        ATTR{idVendor}=="0bda", ATTR{idProduct}=="1a2b", RUN+="${lib.getExe pkgs.usb-modeswitch} -K -v 0bda -p 1a2b"
      '';
      environment.systemPackages = with pkgs; [
        usb-modeswitch
        blueman # bluetooth
        bluetui
      ];
    };
}
