{
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
                mountOptions = [ "fmask=0022" "dmask=0022" ];
              };
            };
            lvm = {
              name = "lvm";
              size = "100%";
              content = { type = "lvm_pv"; vg = "vgjupiter"; };
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
          size = "16G";
          content = { type = "swap"; resumeDevice = true; };
        };
        rootfs = {
          size = "384G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            mountOptions = [ "exec" ];
          };
        };
        homefs = {
          size = "64G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/home";
            mountOptions = [ "users" "exec" ];
          };
        };
      };
    };
  };
}