{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.pi-base =
    { pkgs, lib, ... }:
    {
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      boot.loader.raspberryPi.bootloader = "kernel"; # Use direct kernel boot
      # Ensure NVMe is available in initrd (the module usually adds this, but good to verify)
      # boot.initrd.availableKernelModules = [ "nvme" ];

      users.groups = {
        gpio = { };
        i2c = { };
        spi = { };
      };

      # user.glados
      # extraGroups = [  "dialout" "gpio" "i2c" "spi" ];

      services.udev.extraRules = ''
        SUBSYSTEM=="gpio", KERNEL=="gpiochip*", GROUP="gpio", MODE="0660"
        SUBSYSTEM=="i2c-dev", GROUP="i2c", MODE="0660"
        SUBSYSTEM=="spidev", GROUP="spi", MODE="0660"
      '';
    };
}
