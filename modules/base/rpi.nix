{ inputs, config, ... }:
{
  # Needed for flake.modules.* (skip if another file already imports it)
  imports = [ inputs.flake-parts.flakeModules.modules ];

  # Feature module: shared by every Pi
  flake.modules.nixos.pi-base = { pkgs, ... }: {
    system.stateVersion = "26.05";

    networking.networkmanager.enable = true;
    zramSwap.enable = true;

    users.groups = {
      gpio = { };
      i2c = { };
      spi = { };
    };

    users.users.glados = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
        "dialout"
        "gpio"
        "i2c"
        "spi"
      ];
      openssh.authorizedKeys.keys = [
        # "ssh-ed25519 AAAA... you@host"
      ];
    };

    services.udev.extraRules = ''
      SUBSYSTEM=="gpio", KERNEL=="gpiochip*", GROUP="gpio", MODE="0660"
      SUBSYSTEM=="i2c-dev", GROUP="i2c", MODE="0660"
      SUBSYSTEM=="spidev", GROUP="spi", MODE="0660"
    '';

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    environment.systemPackages = with pkgs; [
      git
      vim
      htop
    ];
  };

  # Hosts
  flake.nixosConfigurations.rpi5 = inputs.nixos-raspberrypi.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
      config.flake.modules.nixos.pi-base
      { networking.hostName = "rpi5"; }
    ];
  };

  flake.nixosConfigurations.rpi4 = inputs.nixos-raspberrypi.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base
      config.flake.modules.nixos.pi-base
      { networking.hostName = "rpi4"; }
    ];
  };
}
