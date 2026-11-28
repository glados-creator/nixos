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
          systemd.services.virtnetworkd.path = [ 
              nftables
  dnsmasq
  iproute2
  iptables      # certains chemins de code l'appellent encore
  bridge-utils
           ];
          systemd.services.libvirtd.path = [   nftables
  dnsmasq
  iproute2
  iptables      # certains chemins de code l'appellent encore
  bridge-utils ]; # monolithic mode
          # boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
          environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system?socket=/run/libvirt/libvirt-sock";

          environment.systemPackages = [ pkgs.virt-manager ];
        }
      )
    ];
  };
}
