{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.rpi5a = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.rpi5aConfig
    ];
  };

  flake.nixosModules.rpi5aConfig =
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
        hostName = "rpi5a";
        networkmanager.enable = true;
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
          "pipewire"
          "networkmanager"
          "systemd-journal"
        ];
      };
    };
}
