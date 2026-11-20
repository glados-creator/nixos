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
      boot.loader.raspberry-pi.bootloader = "kernel";
      # Ensure NVMe is available in initrd (the module usually adds this, but good to verify)
      # boot.initrd.availableKernelModules = [ "nvme" ];
      nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
      boot.initrd.availableKernelModules = [ "nvme" "dm_mod" ];
      boot.initrd.services.lvm.enable = true;   # or boot.initrd.systemd + lvm, matching your setup

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

      environment.systemPackages = [ pkgs.util-linux  pkgs.coreutils ];
    };
}
