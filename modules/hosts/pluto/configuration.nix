{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.pluto = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.plutoConfig
    ];
  };

  flake.nixosModules.plutoConfig =

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
        self.nixosModules.plutoamdgpu

        self.nixosModules.tailscale
        self.nixosModules.sunshine
        
        self.nixosModules.gladosDesktop
        self.nixosModules.gladosHome
      ];

      networking = {
        hostName = "pluto";
        interfaces.enp5s0.useDHCP = true;
        interfaces.enp5s0.wakeOnLan.enable = true;
        defaultGateway = "192.168.1.254";
        nameservers = [
          "192.168.1.1"
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
