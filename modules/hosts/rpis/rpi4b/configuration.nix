{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.rpi4b = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.rpi4bConfig
    ];
  };

  flake.nixosModules.rpi4bConfig =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      imports = [
        self.nixosModules.CommunCeph
        self.nixosModules.k3s
        self.nixosModules.tailscale
      ];

      networking = {
        hostName = "rpi4b";
        networkmanager.enable = true;
        # defaultGateway = "192.168.1.254";
      };

      users.users.rpi4b = {
        shell = pkgs.fish;
        name = "rpi4b";
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
        ];
      };
    };
}
