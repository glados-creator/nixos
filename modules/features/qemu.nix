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

          boot.extraModprobeConfig = ''
            options kvm_intel nested=1
            options kvm_amd nested=1
          '';

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
          systemd.tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];
          systemd.sockets = lib.genAttrs [
            "virtqemud" "virtnetworkd" "virtstoraged" "virtnodedevd" "virtlogd"
          ] (_: { wantedBy = [ "sockets.target" ]; });
          systemd.services.virtnetworkd.path = [ pkgs.nftables pkgs.dnsmasq ];
          systemd.services.libvirtd.path = [ pkgs.nftables pkgs.dnsmasq ]; # monolithic mode
          boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

          environment.systemPackages = [ pkgs.virt-manager ];
        }
      )
    ];
  };
}
