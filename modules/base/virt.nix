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
      stdenv,
      ...
    }:
    {
      programs.virt-manager.enable = true;
      # virt-manager qemu kvm docker podman
      virtualisation = {
        libvirtd.enable = true;
        libvirtd.qemu = {
          package = pkgs.qemu_kvm; # optimized KVM build
          swtpm.enable = true; # TPM 2.0 for Windows 11 guests
        };
        spiceUSBRedirection.enable = true;
        containerd.enable = true;
        docker.enable = false;
        podman = {
          enable = true;

          # Create a `docker` alias for podman, to use it as a drop-in replacement
          dockerCompat = true;

          # Required for containers under podman-compose to be able to talk to each other.
          defaultNetwork.settings.dns_enabled = true;
        };
        containers.enable = true;
        containers.containersConf.cniPlugins = [
          pkgs.cni-plugins
          pkgs.dnsname-cni
        ];

        cri-o.enable = true;
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
