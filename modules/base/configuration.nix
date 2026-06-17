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
        # "auto-allocate-uids"
      ];
      # nix allow proprietary pkgs
      nixpkgs.config.allowUnfree = true;
      # fix download buffer
      nix.settings.download-buffer-size = 10737418240; # 10GB in bytes
      # auto updates
      system.autoUpgrade.enable = true;
      # nix garbage collector
      nix.gc.automatic = true;
      # compact duplicate config files
      nix.settings.auto-optimise-store = true;
      # nix.settings.auto-allocate-uids = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot = {
        kernelParams = [
          "systemd.log_level=info" # debug
          "systemd.log_target=console"
        ];
        # Boot kernel parameters
        # kernelParams = amd vs intel
        # --- Kernel modules (VFIO + Wacom / HID) ---
        kernelModules = [
            "kvm"
            "vfio"
            "vfio_iommu_type1"
            # Wacom / tablet
            "wacom"
            "hid"
            "uhid"
            "usbhid"
            "hid-generic"
            "hid_xpadneo"
            "ceph"
            "rbd"
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
      hardware.enableRedistributableFirmware = true;
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
      networking.nftables.enable = true;
    };
}
