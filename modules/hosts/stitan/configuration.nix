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
        self.nixosModules.sunshine
        # self.nixosModules.wivrn

        self.nixosModules.jupiterCeph
        self.nixosModules.stitanDesktop
        self.nixosModules.stitanHome
      ];

      networking = {
        hostName = "stitan";
        # Enable bridge support
        bridges = {
          br0 = {
            interfaces = [ "eno1" ]; # enslave eno1 to the bridge
          };
        };
        # Configure the bridge interface itself
        interfaces.br0 = {
          ipv4.addresses = [
            {
              address = "192.168.1.22";
              prefixLength = 24;
            }
            # Add more static IPs if needed, e.g.:
            # { address = "192.168.1.60"; prefixLength = 24; }
          ];
          ipv4.routes = [
            {
              address = "0.0.0.0";
              prefixLength = 0;
              via = "192.168.1.254";
            }
          ];
        };

        # Global default gateway and DNS
        defaultGateway = "192.168.1.254";
        nameservers = [
          "192.168.1.1"
          "1.1.1.1"
          "8.8.8.8"
          "192.168.1.254" # router
        ];

        # eno1 is now a bridge port – no IP config here
        interfaces.eno1 = {
          useDHCP = false;
          wakeOnLan.enable = true;
          # No ipv4.addresses
        };

        # Optional: keep NetworkManager for other interfaces (Wi-Fi, VPNs)
        networkmanager.enable = true;
        # Ensure NetworkManager does not manage our bridge or physical interface
        networkmanager.unmanaged = [
          "interface-name:br0"
          "interface-name:eno1"
        ];

        firewall.enable = true; # adjust firewall rules as needed
        dhcpcd.enable = false; # we use static config + NetworkManager
      };

      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_18;

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
        ];
      };
    };
}
