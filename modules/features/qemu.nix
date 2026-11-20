{ self, inputs, ... }:
{
  flake.nixosModules.qemu = {
    key = "nixosModules.qemu";
    imports = [
      (
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          programs.virt-manager.enable = true;

          boot.kernelModules = [
            "kvm"
            "vfio"
            "vfio_iommu_type1"
            "vfio_pci"
            "kvm-amd"
            "kvm-intel"
          ];
          boot.kernelParams = [
            "iommu=pt"
            "amd_iommu=on"
            "intel_iommu=on"
          ];

          virtualisation = {
            libvirtd = {
              enable = true;
              qemu = {
                package = pkgs.qemu_kvm;
                swtpm.enable = true;
              };
            };
            spiceUSBRedirection.enable = true;
          };

          environment.systemPackages = [ pkgs.virt-manager ];
        }
      )
    ];
  };
}
