{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.virt =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      programs.virt-manager.enable = true;

      # vfio / kvm (moved here from base.nix)
      boot.kernelModules = [
        "kvm"
        "vfio"
        "vfio_iommu_type1"
      ];

      # virt-manager qemu kvm podman
      # NOTE: standalone containerd + cri-o removed from here.
      # k3s now uses CRI-O via modules/features/k3s-crio.nix
      virtualisation = {
        libvirtd.enable = true;
        libvirtd.qemu = {
          package = pkgs.qemu_kvm; # optimized KVM build
          swtpm.enable = true; # TPM 2.0 for Windows 11 guests
        };
        spiceUSBRedirection.enable = true;
        docker.enable = false;
        podman = {
          enable = true;

          # Create a `docker` alias for podman, to use it as a drop-in replacement
          dockerCompat = true;

          # Required for containers under podman-compose to be able to talk to each other.
          defaultNetwork.settings.dns_enabled = true;
        };
        containers.enable = true;
        containers.containersConf.cniPlugins = with pkgs; [
          cni-plugins
          dnsname-cni
          calico-cni-plugin
          multus-cni
          linkerd
        ];
      };
      environment.systemPackages = with pkgs; [
        # virt
        virt-manager
        qemu_kvm
        podman
        podman-compose
        podman-desktop
        podman-tui
        devpod
        devpod-desktop
        devenv
      ];
    };
}
