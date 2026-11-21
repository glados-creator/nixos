{
  self,
  inputs,
  ...
}:
{
  # Shared disk layout for jupiter (512 GB NVMe):
  #   1G FAT firmware | 16G swap | 384GG LVM (root) | 64G home
  flake.nixosModules.jupiterDisko =
    { lib, ... }:
    {
      imports = [ inputs.disko.nixosModules.disko ];
      disko.devices = {
        disk = {
          main = {
            type = "disk";
            device = "/dev/disk/by-id/nvme-Patriot_M.2_P300_512GB_P300WCBA24090647503";
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
                    vg = "vgjupiter";
                  };
                };
              };
            };
          };

          sda = {
            type = "disk";
            device = "/dev/disk/by-id/ata-WDC_WDS200T2B0A-00SM50_204223801686";
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

          sdb = {
            type = "disk";
            device = "/dev/disk/by-id/ata-GIGABYTE_GP-GSTFS31100TNTD_SN202308906817";
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

          sdc = {
            type = "disk";
            device = "/dev/disk/by-id/ata-TPH00402000GB_0_HLTEV024";
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

          sdd = {
            type = "disk";
            device = "/dev/disk/by-id/ata-WDC_WD20EZRX-00SPEB0_WD-WCC4E3CK662F";
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

        lvm_vg.vgjupiter = {
          type = "lvm_vg";
          lvs = {
            swap = {
              priority = 1;
              size = "16G";
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
                mountOptions = [ "exec" ];
              };
            };
            homefs = {
              priority = 2;
              size = "64G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
                mountOptions = [
                  "users"
                  "exec"
                ];
              };
            };
          };
        };
      };
    };
}
