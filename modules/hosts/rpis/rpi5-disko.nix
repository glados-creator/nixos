{
  self,
  inputs,
  ...
}:
{
  # Shared disk layout for rpi5a (512 GB NVMe):
  #   1G FAT firmware | 8G swap | 48G LVM (root) | rest raw (ceph OSD)
  flake.nixosModules.rpi5Disko =
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
              swap = {
                priority = 2;
                size = "8G";
                content.type = "swap";
              };
              lvm = {
                priority = 3;
                size = "48G";
                content = {
                  type = "lvm_pv";
                  vg = "vgrpi5";
                };
              };
              # everything left over, untouched: hand it to Rook-Ceph as a raw device
              ceph = {
                priority = 4;
                size = "100%";
              };
            };
          };
        };

        lvm_vg.vgrpi5 = {
          type = "lvm_vg";
          lvs.rootfs = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
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
