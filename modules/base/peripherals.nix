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
      hardware = {
        enableRedistributableFirmware = true;
        enableAllFirmware = true;
        steam-hardware.enable = true;
        inputmodule.enable = true;
        xpad-noone.enable = true; # Xpad driver
        xone.enable = true; # xone driver for Xbox One
        xpadneo.enable = true; # xpadneo driver for Xbox One wireless controllers
      };

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

        # Hardware Information
        pciutils # lspci - list PCI devices (GPU, network, etc.)
        usbutils # lsusb - list USB devices
        dmidecode # DMI/SMBIOS data (motherboard, BIOS info)
        inxi # Comprehensive system info (CPU, GPU, RAM, etc.)[reference:1]
        lshw # Detailed hardware tree
        hwinfo # Another hardware probing tool[reference:3]

        # Monitoring & Health
        lm_sensors # The `sensors` command for temperatures, voltages, fans
        smartmontools # `smartctl` for disk health (SMART data)[reference:5]

        # CPU Frequency Management
        cpupower-gui # GUI for CPU frequency scaling (and `cpupower` CLI)
        cpuinfo
      ];
    };
}
