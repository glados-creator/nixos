{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.AstraGuestHome =
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
          home.stateVersion = "26.11";
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
            dxvk # DirectX to Vulkan translation
            vkd3d # DirectX 12 to Vulkan translation
            vkd3d-proton
            vkbasalt-cli
            gamescope # Gaming compositor
            mangohud # Performance overlay
            goverlay # mangohud gui config
            bottles # windows ?
            vulkan-loader

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
