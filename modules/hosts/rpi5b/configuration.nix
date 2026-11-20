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
      # TODO : system modules
      imports = [
        self.nixosModules.profile-minimal-rpi
        self.nixosModules.rpi5Disko
        self.nixosModules.tv
        self.nixosModules.k3s
        self.nixosModules.k3s-rpi5b-server
        self.nixosModules.tailscale
        self.nixosModules.rpi5bDesktop
        # the module exported by this host's hardware-configuration.nix (fileSystems etc.)
        # self.nixosModules.rpi5bHardware
      ];

      # networking wake on lan

      # TODO : user groups
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
