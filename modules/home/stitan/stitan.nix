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

      environment.systemPackages = with pkgs; [
        firefox
        chromium
        alacritty
        discord

        # Media / creative
        krita
        gimp
        vlc
        inkscape
        obs-studio

        # Office
        libreoffice-fresh

        # Utilities / system
        fishPlugins.fzf-fish
        oh-my-fish
      ];

      programs.neovim = {
        enable = true;
        withPython3 = true;
        withNodeJs = true;
        # waylandSupport = true;
        # plugins = with pkgs.vimPlugins; [
        #   YankRing-vim
        #   vim-nix
        # ];
        # initLua = "";
      };

      # Now configure home-manager for user 'glados'
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
          home.username = "stitan";
          home.homeDirectory = "/home/stitan";
          home.stateVersion = "26.05";
          home.enableNixpkgsReleaseCheck = false;
          nixpkgs.config.allowUnfree = true;

          # Developer and desktop packages for saturn's titan
          home.packages = with pkgs; [
            home-manager
            firefox
            chromium
            alacritty
            discord

            # Media / creative
            krita
            gimp
            vlc
            inkscape
            obs-studio

            # Office
            libreoffice-fresh

            # Utilities / system
            fishPlugins.fzf-fish
            oh-my-fish
          ];

          services.blueman-applet.enable = true;

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

          programs.neovim = {
            enable = true;
            withPython3 = true;
            withNodeJs = true;
            waylandSupport = true;
            plugins = with pkgs.vimPlugins; [
              YankRing-vim
              vim-nix
            ];
            initLua = "";
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
