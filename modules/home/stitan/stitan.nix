{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.stitanHome =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      # Import the Home Manager module from your flake input
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      # Now configure home-manager for user 'glados'
      home-manager.users.stitan =
        {
          config,
          pkgs,
          lib,
          stdenv,
          ...
        }:
        {
          home.username = "stitan";
          home.homeDirectory = "/home/stitan";
          home.stateVersion = "26.05";
          nixpkgs.config.allowUnfree = true;

          home.packages = with pkgs; [
            home-manager
            firefox
            ungoogled-chromium
            alacritty
            discord

            # Media / creative
            vlc
            obs-studio

            # Office
            libreoffice-fresh

            # Utilities / system
            fishPlugins.fzf-fish
            oh-my-fish
          ];

          programs.git = {
            enable = true;
            settings.contents.user = {
              name = "glados";
              email = "79933806+glados-creator@users.noreply.github.com";
            };
          };

          programs.fish = {
            enable = true;
            shellAliases = {
              ll = "eza -larth";
              eza = "ls"; # alias eza -> ls
              bat = "cat"; # alisa bat -> cat
              # rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#astra";
            };
          };
        };
    };
}
