{
  self,
  inputs,
  ...
}:
{
  # Built with nixos-raspberrypi's nixosSystem (vendor kernel, own nixpkgs).
  flake.nixosConfigurations.rpi5a = inputs.nixos-raspberrypi.lib.nixosSystem {
    specialArgs = { inherit (inputs) nixos-raspberrypi; };
    modules = [
      self.nixosModules.rpi5aConfig
    ];
  };

  flake.nixosModules.rpi5aConfig =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        self.nixosModules.profile-minimal-rpi
        self.nixosModules.rpi5aDisko
        self.nixosModules.tv
        self.nixosModules.k3s
        self.nixosModules.k3s-rpi5a-server
        self.nixosModules.tailscale
        self.nixosModules.rpi5aDesktop
      ];

      networking = {
        hostName = "rpi5a";
        networkmanager.enable = true;
        interfaces.eth0 = {
          useDHCP = true;
          wakeOnLan.enable = true;
        };
        interfaces.wlan0 = {
          useDHCP = true;
          wakeOnLan.enable = true;
        };
        # defaultGateway = "192.168.1.254";
      };

      users.users.rpi5a = {
        shell = pkgs.fish;
        name = "rpi5a";
        isNormalUser = true;
        createHome = true;
        extraGroups = [
          "wheel"
          "audio"
          "video"
          "input"
          "render"
          "networkmanager"
          "systemd-journal"
          "dialout"
          "gpio"
          "i2c"
          "spi"
        ];
      };
    };
}
