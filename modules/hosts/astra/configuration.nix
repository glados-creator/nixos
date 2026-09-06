{
  self,
  inputs,
  #     nixpkgs,
  #     home-manager,
  #     lanzaboote,
  #     nix-ld,
  ...
}:
{
  flake.nixosConfigurations.astra = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.astraConfig
    ];
  };

  flake.nixosModules.astraConfig =
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
        self.nixosModules.nvidia-latest

        self.nixosModules.CommunCeph
        self.nixosModules.k3s
        self.nixosModules.k3sGpu
        self.nixosModules.tailscale
        self.nixosModules.rdp
        self.nixosModules.VR

        self.nixosModules.gladosDesktop
        self.nixosModules.gladosHome
      ];

      networking = {
        hostName = "astra";
        networkmanager.enable = true;
        interfaces.enp6s0 = {
          useDHCP = false;
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
          "docker"
          "kvm"
          "libvirtd"
          "ceph"
        ];
      };
    };
}
