{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.base =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      # nix version
      system.stateVersion = "26.05";
      # nix flake
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      # nix allow proprietary pkgs
      nixpkgs.config.allowUnfree = true;
      # fix download buffer
      nix.settings.download-buffer-size = 2147483648; # 2GB in bytes
      # auto updates
      system.autoUpgrade.enable = true;
      # nix garbage collector
      nix.gc.automatic = true;
      # compact duplicate config files
      nix.settings.auto-optimise-store = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot = {
        kernelParams = [
          "systemd.log_level=info" # debug
          "systemd.log_target=console"
        ];
        # Boot kernel parameters
        # kernelParams = amd vs intel
        # bleuthooth motherducker
        extraModulePackages = with config.boot.kernelPackages; [
          rtl8821cu
        ];
        # --- Kernel modules (VFIO + Wacom / HID) ---
        kernelModules = [
          "kvm"
          # "vfio_pci"
          "vfio"
          "vfio_iommu_type1"
          # "vfio_virqfd"

          # Wacom / tablet support
          "wacom"
          "hid"
          "uhid"
          "usbhid"
          "hid-generic"

          "8821cu" # bleutooth
          "hid_xpadneo" # xbox controller

          "ceph"
          "rbd" # ceph
          "xfs"
          "overlay"
          "fuse"
        ];
        # nfs
        supportedFilesystems = [
          "nfs"
          "ext4"
          "xfs"
        ];
      };
      # enable zram
      zramSwap.enable = true;
      # clean /tmp
      boot.tmp.cleanOnBoot = true;
      # network
      systemd.services.NetworkManager-wait-online.enable = false; # disables the 1 minute delay
      networking = {
        networkmanager.enable = true;
        firewall.enable = true;
        dhcpcd.enable = false; # not needed with NetworkManager
      };
    };
}
