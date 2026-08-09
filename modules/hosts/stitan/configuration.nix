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

        # self.nixosModules.k3s
        self.nixosModules.k3sserver
        self.nixosModules.k3sGpu
        self.nixosModules.tailscale
        self.nixosModules.rdp

        self.nixosModules.jupiterCeph
        self.nixosModules.stitanDesktop
        self.nixosModules.stitanHome
      ];

      networking = {
        hostName = "stitan";
        interfaces.eno1 = {
          useDHCP = false;
          wakeOnLan.enable = true;
          ipv4.addresses = [
            {
              address = "192.168.1.14";
              prefixLength = 24;
            }
            {
              address = "172.16.0.14";
              prefixLength = 24;
            }
          ];
          # ipv4.routes = [
          #   {
          #     address = "0.0.0.0";
          #     prefixLength = 0;
          #     via = "172.16.0.1";
          #     metric = 200;
          #   }
          # ];
        };
        defaultGateway = "192.168.1.254";

        nameservers = [
          # "172.16.0.3"
          # "192.168.0.3"
          "1.1.1.1"
          "192.168.1.254"
        ];

        # Turn off NetworkManager – it would fight with manual config
        networkmanager.enable = false;
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
          # "networkmanager"
          "systemd-journal"
          "docker"
          "kvm"
          "libvirtd"
          "ceph"
        ];
      };
    };
}
