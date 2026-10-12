{
  self,
  inputs,
  ...
}:
{
  # Built with nixos-raspberrypi's nixosSystem (vendor kernel, own nixpkgs).
  flake.nixosConfigurations.rpi5a = inputs.nixos-raspberrypi.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
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
        self.nixosModules.rpi5Disko
        self.nixosModules.CommunCeph
        self.nixosModules.k3s
        self.nixosModules.k3s-crio
        self.nixosModules.tailscale
        # the module exported by this host's hardware-configuration.nix (fileSystems etc.)
        # self.nixosModules.rpi5aHardware
      ];

      networking.hostName = "rpi5a";

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
