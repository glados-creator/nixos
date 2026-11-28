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
              # allowedBridges = [ "br0" ];
              qemu = {
                package = pkgs.qemu_kvm;
                swtpm.enable = true;
              };
            };
            spiceUSBRedirection.enable = true;
          };
          # disable monolithic deamon
          # 1. Disable the monolithic daemon and its socket
          systemd.services.libvirtd.enable = lib.mkForce false;
          systemd.sockets.libvirtd.enable = lib.mkForce false;

          # 2. Enable the modular daemon sockets (flat assignments merge safely in NixOS)
          systemd.sockets.virtqemud.wantedBy = [ "sockets.target" ];
          systemd.sockets.virtnetworkd.wantedBy = [ "sockets.target" ];
          systemd.sockets.virtstoraged.wantedBy = [ "sockets.target" ];
          systemd.sockets.virtnodedevd.wantedBy = [ "sockets.target" ];
          systemd.sockets.virtlogd.wantedBy = [ "sockets.target" ];

          systemd.tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];
          systemd.services.virtnetworkd.path = with pkgs; [
            nftables
            dnsmasq
            iproute2
            iptables # certains chemins de code l'appellent encore
            bridge-utils
          ];
          systemd.services.libvirtd.path = with pkgs; [
            nftables
            dnsmasq
            iproute2
            iptables # certains chemins de code l'appellent encore
            bridge-utils
          ]; # monolithic mode
          # boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
          # environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system?socket=/run/libvirt/libvirt-sock";

          environment.systemPackages = [ pkgs.virt-manager ];
        }
      )
    ];
  };
}
