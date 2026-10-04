{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.rpi4a = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.rpi4aConfig
    ];
  };

  flake.nixosModules.rpi4aConfig =
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
        hostName = "rpi4a";
        networkmanager.enable = true;
        # defaultGateway = "192.168.1.254";
      };

      users.users.rpi4a = {
        shell = pkgs.fish;
        name = "rpi4a";
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
