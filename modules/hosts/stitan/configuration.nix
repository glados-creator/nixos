{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.stitan = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.stitanConfig
    ];
  };

  flake.nixosModules.stitanConfig =

    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      # TODO : system modules
      imports = [
        self.nixosModules.profile-minimal
        self.nixosModules.stitanNvidia390
        self.nixosModules.stitanDisko

        self.nixosModules.k3s
        self.nixosModules.k3s-stitan-server
        # self.nixosModules.k3sGpu
        self.nixosModules.tailscale
        self.nixosModules.rdp
        self.nixosModules.slow-disk

        self.nixosModules.stitanDesktop
        self.nixosModules.stitanHome
      ];

      networking = {
        hostName = "stitan";
        networkmanager.enable = true;
        interfaces.eno1 = {
          useDHCP = false;
          wakeOnLan.enable = true;
        };
        # defaultGateway = "192.168.1.254";
      };

      users.users.stitan = {
        name = "stitan";
        shell = pkgs.fish;
        isNormalUser = true;
        createHome = true;
        extraGroups = [
          "wheel"
          "audio"
          "video"
          "input"
          "render"
          "pipewire"
          "networkmanager"
          "systemd-journal"
          "podman"
          "kvm"
          "libvirt" 
          "libvirtd"
          "ceph"
        ];
      };
    };
}
