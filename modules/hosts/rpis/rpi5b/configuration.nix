{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.rpi5b = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.rpi5bConfig
    ];
  };

  flake.nixosModules.rpi5bConfig =
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
        hostName = "rpi5b";
        networkmanager.enable = true;
        # defaultGateway = "192.168.1.254";
      };

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
          "pipewire"
          "networkmanager"
          "systemd-journal"
        ];
      };
    };
}
