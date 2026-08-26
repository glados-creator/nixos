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
        self.nixosModules.rdp

        self.nixosModules.gladosDesktop
        self.nixosModules.gladosHome
      ];

      networking = {
        hostName = "pluto";
        networkmanager.enable = true;
        interfaces.enp5s0 = {
          useDHCP = true; # TODO : change interface name to real
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
        ];
      };
    };
}
