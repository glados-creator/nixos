{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.jupiter = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.jupiterConfig
    ];
  };

  flake.nixosModules.jupiterConfig =

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
        self.nixosModules.jupiterNvidia580

        self.nixosModules.k3s
        self.nixosModules.k3sGpu
        self.nixosModules.tailscale
        self.nixosModules.rdp
        self.nixosModules.VR

        self.nixosModules.jupiterCeph
        self.nixosModules.gladosDesktop
        self.nixosModules.gladosHome
      ];

      networking = {
        hostName = "jupiter";
        interfaces.enp5s0 = {
          useDHCP = false;
          wakeOnLan.enable = true;
          ipv4.addresses = [
            {
              address = "192.168.1.16";
              prefixLength = 24;
            }
            {
              address = "172.16.0.16";
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

      services.logind.settings.Login = {
        HandlePowerKey = "hibernate";
        IdleAction = "hibernate";
        IdleActionSec = "30min";
      };

      users.users.glados = {
        shell = pkgs.fish;
        name = "glados";
        isNormalUser = true;
        createHome = true;
        extraGroups = [
          "wheel"
          "audio"
          "video"
          "input"
          "render"
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
