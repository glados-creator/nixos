{
  self,
  inputs,
  ...
}:
{
  # Shared disk layout for jupiter (512 GB NVMe):
  #   1G FAT firmware | 16G swap | 384GG LVM (root) | 64G home
  # TODO : redo
  flake.nixosModules.astraDisko =
    { lib, ... }:
    {
      imports = [ inputs.disko.nixosModules.disko ];
      disko.devices = {
        disk = {
          main = {
            type = "disk";
            device = "/dev/nvme0n1";
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
            device = "/dev/sda";
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
            device = "/dev/sdb";
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
            device = "/dev/sdc";
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
            device = "/dev/sdd";
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
