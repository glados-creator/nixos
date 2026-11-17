{
  self,
  inputs,
  ...
}:
{
  # was misspelled `bleutooth`; profiles reference `bluetooth`
  flake.nixosModules.bluetooth =
    {
      config,
      pkgs,
      lib,
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
        bluez
        bluez-tools
      ];
    };
}
