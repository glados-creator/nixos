{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.pi-base =
    { pkgs, lib, ... }:
    let
      rpi = inputs.nixos-raspberrypi;
    in
    {
      imports = with rpi.nixosModules; [
        usb-gadget-ethernet # Configures USB Gadget/Ethernet - Ethernet emulation over USB
        # RPi5:
        # raspberry-pi-5.page-size-16k # Optional memory optimization: use 16k pages instead of default 64k for jemalloc, saves memory, reduces fragmentation. May fix any issues caused by the memory page size discrepancy. May cause lots of rebuilds. (only for systems running default rpi5 (bcm2712) kernel with 16k memory page)
        # use one of following for the "PrimaryGPU" configuration:
        raspberry-pi-5.display-vc4 # "regular" display connected
        # raspberry-pi-5.display-rp1 # for RP1-connected (DPI/composite/MIPI DSI) display
        raspberry-pi-5.bluetooth

        # Required: Add necessary overlays with kernel, firmware, vendor packages
        rpi.lib.inject-overlays

        # Binary cache with prebuilt packages for the currently locked `nixpkgs`,
        # see `devshells/nix-build-to-cachix.nix` for a list
        trusted-nix-caches

        # Optional: All RPi and RPi-optimised packages to be available in `pkgs.rpi`
        nixpkgs-rpi

        # Optional: add overlays with optimised packages into the global scope
        # provides: ffmpeg_{4,6,7}, kodi, libcamera, vlc, etc.
        # This overlay may cause lots of rebuilds (however many
        #  packages should be available from the binary cache)
        rpi.lib.inject-overlays-global
      ];

      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      boot.loader.raspberry-pi.bootloader = "kernel";
      # Ensure NVMe is available in initrd (the module usually adds this, but good to verify)
      # boot.initrd.availableKernelModules = [ "nvme" ];
      nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
      boot.initrd.availableKernelModules = [
        "nvme"
        "dm_mod"
      ];
      boot.initrd.services.lvm.enable = true; # or boot.initrd.systemd + lvm, matching your setup

      hardware.raspberry-pi.config = {
        all = {
          base-dt-params = {
            cooling_fan = {
              enable = true;
              value = "on";
            };
          };
        };
      };

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

      environment.systemPackages = [
        pkgs.util-linux
        pkgs.coreutils
      ];

      boot.kernelParams = [
        "cgroup_enable=cpuset"
        "cgroup_memory=1"
        "cgroup_enable=memory"
        "systemd.unified_cgroup_hierarchy=1"
      ];
    };
}
