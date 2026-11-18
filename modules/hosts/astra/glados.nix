{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.AstraGladosHome =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      # --- Home Manager for user glados ---
      home-manager.backupFileExtension = "backup";
      home-manager.users.glados =
        {
          config,
          pkgs,
          lib,
          stdenv,
          ...
        }:
        {
          # Basic Home Manager settings
          home.username = "glados";
          home.homeDirectory = "/home/glados";
          home.stateVersion = "26.05";
          home.enableNixpkgsReleaseCheck = false;
          nixpkgs.config.allowUnfree = true;

          nixpkgs.config.android_sdk.accept_license = true;

          home.packages = with pkgs; [
            home-manager

            bun
            firefox
            chromium
            discord
            godot

            # prog
            android-studio-full
            android-tools
            arduino
            arduino-cli
            arduino-ide
            distrobox
            distroshelf
            wireshark

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
            blender
            krita
            gimp
            vlc
            inkscape
            obs-studio

            # Office
            libreoffice-stable

            cura-appimage
          ];

          services.blueman-applet.enable = true;
          programs.mangohud.enable = true;

          programs.vscodium = {
            enable = true;
            package = pkgs.vscodium; # This ensures you use VSCodium instead of VS Code
            profiles.default = {
              extensions = with pkgs.vscode-extensions; [
                # 3timeslazy.vscodium-devpodcontainers
                # jeanp413.open-remote-ssh-0.0.49-universal
                ms-python.python
              ];
              userSettings = {
                "editor.fontSize" = 13;
                # "editor.minimap.enabled" = false;
                "terminal.integrated.shell.linux" = "fish";
                "workbench.sideBar.location" = "right";
                "diffEditor.ignoreTrimWhitespace" = false;
              };
            };
          };

          programs.git = {
            enable = true;
            settings.contents.user = {
              name = "glados";
              email = "79933806+glados-creator@users.noreply.github.com";
            };
          };

        };
          
    };
}
