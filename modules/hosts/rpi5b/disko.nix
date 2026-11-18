{
  self,
  inputs,
  ...
}:
{
  # Shared disk layout for rpi5b (512 GB NVMe):
  #   1G FAT firmware | 56G LVM (8G swap + 48G root) | rest raw (ceph OSD)
  flake.nixosModules.rpi5bDisko =
    { lib, ... }:
    {
      imports = [ inputs.disko.nixosModules.disko ];

      disko.devices = {
        disk.nvme = {
          type = "disk";
          device = "/dev/nvme0n1";
          content = {
            type = "gpt";
            partitions = {
              firmware = {
                priority = 1;
                size = "1G";
                type = "EF00"; # FAT, what the Pi 5 EEPROM boots from
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot/firmware";
                  mountOptions = [ "umask=0077" ];
                  extraArgs = [
                    "-n"
                    "FIRMWARE"
                  ];
                };
              };
              lvm = {
                priority = 2;
                size = "56G";
                content = {
                  type = "lvm_pv";
                  vg = "vgrpi5b";
                };
              };
              # everything left over, untouched: hand it to Rook-Ceph as a raw device
              ceph = {
                priority = 3;
                size = "100%";
              };
            };
          };
        };

        lvm_vg.vgrpi5b = {
          type = "lvm_vg";
          lvs = {
            swap = {
              priority = 1; # created first so rootfs's 100%FREE doesn't eat it
              size = "8G";
              content.type = "swap";
            };
            rootfs = {
              priority = 2;
              size = "100%FREE";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };

      boot.initrd.availableKernelModules = [
        "nvme"
        "dm_mod"
      ];
    };
}
