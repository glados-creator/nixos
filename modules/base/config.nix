{
  self,
  inputs,
  ...
}:
{
  # Essentials every machine needs: locale, shells, git, ssh.
  # Desktop-only stuff moved to apps.nix / peripherals.nix, packages to install.nix.
  flake.nixosModules.config =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # local
      time.timeZone = "Europe/Paris";
      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
          LC_TIME = "fr_FR.UTF-8"; # French date/time format
          LC_MONETARY = "fr_FR.UTF-8"; # Euro currency
        };
      };

      # set local
      services.xserver.xkb = {
        layout = lib.mkForce "fr,us,ca,gb";
        options = lib.mkForce "grp:win_shift_toggle,eurosign:e";
      };

      programs.git = {
        enable = true;
        lfs.enable = true;
      };

      programs.bash.enable = true;
      programs.zsh.enable = true;
      programs.fish.enable = true;

      # ssh
      programs.ssh = {
        enableAskPassword = false;
        # askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
      };
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "no";
        };
      };
    };
}
