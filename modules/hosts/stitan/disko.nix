{
  self,
  inputs,
  ...
}:
{
  # Shared disk layout for jupiter (512 GB NVMe):
  #   1G FAT firmware | 24G swap | 250G LVM (root) | 64G home
  flake.nixosModules.stitanDisko =
    { lib, ... }:
    {
      imports = [ inputs.disko.nixosModules.disko ];

      disko.devices = {
        disk.main = {
          type = "disk";
          device = "/dev/disk/by-id/ata-ST500DM002-1BD142_Z6EBYTAM";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                name = "boot";
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "fmask=0022"
                    "dmask=0022"
                  ];
                };
              };
              lvm = {
                name = "lvm";
                size = "100%";
                content = {
                  type = "lvm_pv";
                  vg = "vgstitan";
                };
              };
            };
          };
        };

        lvm_vg.vgstitan = {
          type = "lvm_vg";
          lvs = {
            swap = {
              priority = 1;
              size = "24G";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
            rootfs = {
              priority = 3;
              size = "100%FREE";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            homefs = {
              priority = 2;
              size = "64G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
              };
            };
          };
        };

        disk.data = {
          type = "disk";
          device = "/dev/disk/by-id/ata-ST8000DM004-2U9188_ZR15PPH9";
          content = {
            type = "gpt";
            partitions = {
              data = {
                name = "data";
                size = "100%";
              };
            };
          };
        };
      };
    };
}
