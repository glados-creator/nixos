{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/sda";
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
            content = { type = "lvm_pv"; vg = "vgstitan"; };
          };
        };
      };
    };

    lvm_vg.vgstitan = {
      type = "lvm_vg";
      lvs = {
        swap   = { size = "24G";  content = { type = "swap"; resumeDevice = true; }; };
        rootfs = { size = "250G"; content = { type = "filesystem"; format = "ext4"; mountpoint = "/"; }; };
        homefs = { size = "64G";  content = { type = "filesystem"; format = "ext4"; mountpoint = "/home"; }; };
      };
    };

    disk.data = {
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
  };
}