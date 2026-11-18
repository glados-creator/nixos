{
  self,
  inputs,
  ...
}:
{
  # Nix / system plumbing shared by EVERY machine (x86 and Pi).
  # Kernel lives in kernel.nix, packages in install.nix.
  flake.nixosModules.base =
    {
      config,
      pkgs,
      lib,
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
      # fix download buffer (mkDefault: the Pi profile lowers it)
      nix.settings.download-buffer-size = lib.mkDefault 6442450944; # 6GB in bytes
      # auto updates
      system.autoUpgrade.enable = true;
      # nix garbage collector
      nix.gc.automatic = true;
      # compact duplicate config files
      nix.settings.auto-optimise-store = true;
      # nix.settings.auto-allocate-uids = true;
      # nix.settings.allow-import-from-derivation = true; # nixos impure mode
      # nix.settings.pure-eval = false;  # sorry nixos
      # enable zram
      zramSwap.enable = true;
      boot = {
        kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
        kernelParams = [
          "systemd.log_level=info" # debug
          "systemd.log_target=console"
        ];
        # clean /tmp
        tmp.cleanOnBoot = true;
        tmp.useTmpfs = true;
        tmp.tmpfsSize = lib.mkDefault "8G";
        # nfs
        supportedFilesystems = [
          "nfs"
          "ext4"
          # "xfs"
        ];
        # boot.initrd.availableKernelModules	Stage 1 (initrd) for root
        # boot.initrd.kernelModules	Stage 1 (initrd) for booting
        # boot.kernelModules	Stage 2 (main system)
        initrd.availableKernelModules = [
          "nvme"
          "dm_mod" # device map
          "dm-snapshot"
          "ahci" # sata controler
          "sd_mod" # scsi / sata driver
        ];
      };
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
