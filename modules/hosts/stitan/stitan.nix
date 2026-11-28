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
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      # --- Home Manager for user glados ---
      home-manager.backupFileExtension = "backup";
      home-manager.users.stitan =
        {
          config,
          pkgs,
          lib,
          stdenv,
          ...
        }:
        {
          # imports = [
          #   self.homeModules.shell
          # ];
          # Basic Home Manager settings
          home.username = "stitan";
          home.homeDirectory = "/home/stitan";
          home.stateVersion = "26.11";
          home.enableNixpkgsReleaseCheck = false;
          nixpkgs.config.allowUnfree = true;

          home.packages = with pkgs; [
            home-manager

            firefox
            chromium

            # prog
            wireshark

            # Gaming / Windows compatibility
            steam

            # Media / creative
            krita
            gimp
            vlc
            inkscape

            # Office
            libreoffice

            cura-appimage
          ];

          services.blueman-applet.enable = true;
          # programs.mangohud.enable = true;

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
