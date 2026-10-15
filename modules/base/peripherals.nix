{
  self,
  inputs,
  ...
}:
{
  # Desktop hardware: firmware, controllers, tablets, GPU tools. profile-full only.
  flake.nixosModules.peripherals =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      hardware.enableRedistributableFirmware = true;
      hardware.enableAllFirmware = true;
      hardware.steam-hardware.enable = true;
      hardware.inputmodule.enable = true;
      hardware.xpad-noone.enable = true; # Xpad driver
      hardware.xone.enable = true; # xone driver for Xbox One
      hardware.xpadneo.enable = true; # xpadneo driver for Xbox One wireless controllers

      services.libinput.enable = true;

      # Wacom / tablet / HID
      boot.kernelModules = [
        "wacom"
        "hid"
        "uhid"
        "usbhid"
        "hid-generic"
        "hid_xpadneo"
      ];

      environment.systemPackages = with pkgs; [
        libwacom
        mesa
        mesa-demos
        vulkan-tools
      ];
    };
}
