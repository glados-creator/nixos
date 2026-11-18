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
        self.nixosModules.profile-full
        self.nixosModules.jupiterDisko
        self.nixosModules.jupiterNvidia580

        self.nixosModules.k3sGpu
        self.nixosModules.podman
        self.nixosModules.qemu
        self.nixosModules.printing
        self.nixosModules.shell
        self.nixosModules.tailscale
        self.nixosModules.rdp
        # self.nixosModules.VR

        self.nixosModules.JupiterGladosDesktop
        self.nixosModules.JupiterGladosHome
        self.nixosModules.JupiterGuestDesktop
        self.nixosModules.JupiterGuestHome
      ];

      networking = {
        hostName = "jupiter";
        networkmanager.enable = true;
        interfaces.enp5s0 = {
          useDHCP = true;
          wakeOnLan.enable = true;
        };
        # defaultGateway = "192.168.1.254";
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
          "pipewire"
          "networkmanager"
          "systemd-journal"
          "podman"
          "kvm"
          "libvirtd"
          "ceph"
        ];
      };
    };
}
