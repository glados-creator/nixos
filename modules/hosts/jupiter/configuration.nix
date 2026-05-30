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
        self.nixosModules.ceph
        self.nixosModules.tailscale
        self.nixosModules.sunshine
        self.nixosModules.VR

        self.nixosModules.jupiterCeph
        self.nixosModules.gladosDesktop
        self.nixosModules.gladosHome
      ];

      networking = {
        hostName = "jupiter";
        interfaces.enp5s0.useDHCP = true;
        interfaces.enp5s0.wakeOnLan.enable = true;
        defaultGateway = "192.168.1.254";
        nameservers = [
          "192.168.1.24" # rpi5a
          "192.168.1.25"
          "192.168.1.26" # rpi5b
          "192.168.1.27"
          "192.168.1.28" # rpi4a
          "192.168.1.29"
          "192.168.1.30" # rpi4b
          "192.168.1.31"
          "1.1.1.1"
          "8.8.8.8"
          "192.168.1.254" # router
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
        ];
      };
    };
}
