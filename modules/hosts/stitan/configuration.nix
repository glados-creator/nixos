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
      imports = [
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.nix-ld.nixosModules.nix-ld

        self.nixosModules.base
        self.nixosModules.bootsb
        self.nixosModules.stitanNvidia390

        self.nixosModules.CommunCeph
        self.nixosModules.k3s
        self.nixosModules.k3sserver
        self.nixosModules.k3sGpu
        self.nixosModules.tailscale
        self.nixosModules.rdp

        self.nixosModules.stitanCeph
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

      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_18;
      # services.qemuGuest.enable = true;

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
          "docker"
          "kvm"
          "libvirtd"
          "ceph"
        ];
      };
    };
}
