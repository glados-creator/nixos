{
  self,
  inputs,
  ...
}:
{
  # Pi-specific bits only. Everything generic (ssh, NetworkManager, zram,
  # stateVersion, core packages) now comes from base/config/network/install
  # via profile-minimal-rpi. Host definitions live in modules/hosts/rpis/*.
  flake.nixosModules.pi-base =
    { pkgs, lib, ... }:
    {
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      users.groups = {
        gpio = { };
        i2c = { };
        spi = { };
      };

      # user
      # "dialout"
      # "gpio"
      # "i2c"
      # "spi"

      services.udev.extraRules = ''
        SUBSYSTEM=="gpio", KERNEL=="gpiochip*", GROUP="gpio", MODE="0660"
        SUBSYSTEM=="i2c-dev", GROUP="i2c", MODE="0660"
        SUBSYSTEM=="spidev", GROUP="spi", MODE="0660"
      '';
    };
}
