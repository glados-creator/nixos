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
        self.nixosModules.profile-full
        self.nixosModules.astraHardware # TODO : switch to disko
        self.nixosModules.nvidia-latest

        self.nixosModules.k3sGpu
        self.nixosModules.podman
        self.nixosModules.qemu
        self.nixosModules.printing
        self.nixosModules.shell
        self.nixosModules.tailscale
        self.nixosModules.rdp
        self.nixosModules.VR
        self.nixosModules.waydroid

        self.nixosModules.AstraDesktop
        self.nixosModules.AstraGladosHome
        self.nixosModules.AstraGuestHome
      ];

      boot.kernelModules = [ "nct6775" ];
      boot.kernelParams = [ "acpi_enforce_resources=lax" ];

      networking = {
        hostName = "astra";
        networkmanager.enable = true;
        interfaces.enp6s0 = {
          useDHCP = true;
          wakeOnLan.enable = true;
        };
        # defaultGateway = "192.168.1.254";
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

      users.users.guest = {
        shell = pkgs.fish;
        name = "guest";
        isNormalUser = true;
        createHome = true;
        extraGroups = [
          "audio"
          "video"
          "input"
          "render"
          "pipewire"
        ];
      };
    };
}
