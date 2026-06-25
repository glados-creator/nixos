{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.stitanDesktop =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      # Enable SDDM ~kde plasma login manager~ as display manager
      services.displayManager.sddm.enable = true;
      # services.displayManager.plasma-login-manager.enable = true;
      services.displayManager.defaultSession = "plasma"; # Default to Plasma
      services.xserver.wacom.enable = true; # wacom graphical tablet support

      # Enable both X11 and Wayland sessions
      services.xserver.enable = true;
      services.desktopManager.plasma6.enable = true; # Plasma 6
      services.xserver.desktopManager.xfce.enable = true; # XFCE
      # services.xserver.desktopManager.cinnamon.enable = true; # Cinnamon

      # Wayland compositors
      programs.hyprland.enable = true;
      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
      };

      # GNOME (supports both X11 and Wayland)
      services.desktopManager.gnome.enable = true;

      # Niri compositor (Wayland)
      programs.niri = {
        enable = true;
        # package = pkgs.niri;
      };

      # AwesomeWM (X11)
      services.xserver.windowManager.awesome = {
        enable = true;
        luaModules = with pkgs.luaPackages; [
          luafilesystem
          lgi
        ];
      };

      # Additional packages for Wine support
      environment.systemPackages = with pkgs; [
        xf86-input-wacom
        kdePackages.wacomtablet
        # Qt and GTK theming for better integration
        qt5.qtbase
        qt5.qttools
        qt5.qtdeclarative
        qt5.qtwayland

        qt6.qtbase
        qt6.qttools
        qt6.qtdeclarative
        qt6.qtwayland

        glib-networking # GLib network extensions
        gsettings-desktop-schemas
        qt6.qtmultimedia
      ];
    };
}
