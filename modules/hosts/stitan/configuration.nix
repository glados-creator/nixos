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

        self.nixosModules.k3s
        self.nixosModules.k3sGpu
        self.nixosModules.ceph
        self.nixosModules.tailscale
        self.nixosModules.rdp

        self.nixosModules.jupiterCeph
        self.nixosModules.stitanDesktop
        self.nixosModules.stitanHome
      ];

      networking = {
        hostName = "astra";
        interfaces.eno1.useDHCP = true;
        interfaces.eno1.wakeOnLan.enable = true;
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

      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_18;
      # services.qemuGuest.enable = true;

      users.users.stitan = {
        name = "stitan";
        shell = pkgs.fish;
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
