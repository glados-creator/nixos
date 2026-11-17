{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.jupiterguestHome =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      # --- Home Manager for user guest ---
      home-manager.backupFileExtension = "backup";
      home-manager.users.guest =
        {
          config,
          pkgs,
          lib,
          stdenv,
          ...
        }:
        {
          # Basic Home Manager settings
          home.username = "guest";
          home.homeDirectory = "/home/guest";
          home.stateVersion = "26.05";
          home.enableNixpkgsReleaseCheck = false;
          nixpkgs.config.allowUnfree = true;

          home.packages = with pkgs; [
            home-manager

            firefox
            chromium

            # prog
            distrobox
            distroshelf

            waydroid
            waydroid-nftables

            # Gaming / Windows compatibility
            steam
            wine-wayland
            winetricks
            lutris
            heroic


            # Media / creative
            krita
            gimp
            vlc
            inkscape
            obs-studio

            # Office
            libreoffice-stable
          ];

          services.blueman-applet.enable = true;
          programs.mangohud.enable = true;
        };
          
    };
}
