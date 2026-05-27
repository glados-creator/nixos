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

        self.nixosModules.k3s
        self.nixosModules.k3sGpu
        self.nixosModules.ceph
        self.nixosModules.tailscale
        self.nixosModules.rdp
        self.nixosModules.VR

        self.nixosModules.astraCeph
        self.nixosModules.gladosDesktop
        self.nixosModules.gladosHome
      ];

      networking = {
        hostName = "astra";
        interfaces.enp6s0.useDHCP = true;
        interfaces.enp6s0.wakeOnLan.enable = true;
        defaultGateway = "192.168.1.254";
        networkmanager = {
          enable = true;
          insertNameservers = [ "192.168.1.1" ];
          appendNameservers = [ "192.168.1.254" ];
        };
        nameservers = [
          # "192.168.1.1"
          "1.1.1.1"
          # "192.168.1.254" # router
        ];
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
        extraGroups = [
          "wheel"
          "audio"
          "video"
          "input"
          "render"
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
