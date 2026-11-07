{
  self,
  inputs,
  ...
}:
{
  # Built with nixos-raspberrypi's nixosSystem (vendor kernel, own nixpkgs).
  flake.nixosConfigurations.rpi5b = inputs.nixos-raspberrypi.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
      self.nixosModules.rpi5bConfig
    ];
  };

  flake.nixosModules.rpi5bConfig =
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
        self.nixosModules.tailscale
        # the module exported by this host's hardware-configuration.nix (fileSystems etc.)
        # self.nixosModules.rpi5bHardware
      ];

      networking.hostName = "rpi5b";

      users.users.rpi5b = {
        shell = pkgs.fish;
        name = "rpi5b";
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
