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
      # TODO : system modules
      imports = [
        self.nixosModules.profile-minimal-rpi
        self.nixosModules.rpi5Disko
        self.nixosModules.k3s
        self.nixosModules.k3s-rpi5a-server
        self.nixosModules.tailscale
        self.nixosModules.rpi5aDesktop
      ];
      # networking wake on lan

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
