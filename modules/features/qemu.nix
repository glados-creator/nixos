{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.qemu =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      programs.virt-manager.enable = true;

      # KVM + VFIO. vfio_pci is needed to actually bind devices
      boot.kernelModules = [
        "kvm"
        "vfio"
        "vfio_iommu_type1"
        "vfio_pci"
        "iommu=pt"
        "amd_iommu=on"
        "intel_iommu=on"
      ];

      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.qemu_kvm; # optimized KVM build
            swtpm.enable = true; # TPM 2.0 for Windows 11 guests
          };
        };
        spiceUSBRedirection.enable = true;
      };

      environment.systemPackages = with pkgs; [
        virt-manager
        qemu_kvm
      ];
    };
}
