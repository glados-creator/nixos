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
      # PAM limits
      security.pam.loginLimits = [
        { domain = "@sddm"; type = "soft"; item = "rtprio"; value = "20"; }
        { domain = "@sddm"; type = "soft"; item = "nice"; value = "-20"; }
        { domain = "@pipewire"; type = "soft"; item = "rtprio"; value = "20"; }
        { domain = "@pipewire"; type = "soft"; item = "nice";   value = "-20"; }
      ];

      # # Enable SDDM ~kde plasma login manager~ as display manager
      # services.displayManager.sddm.enable = true;
      # Use ly as the display manager
      services.displayManager.ly.enable = true;
      # services.displayManager.plasma-login-manager.enable = false;

      services.displayManager.defaultSession = lib.mkForce "plasma"; # Default to Plasma
      services.xserver.wacom.enable = true; # wacom graphical tablet support

      # X11 and desktop environments – all support X11
      services.xserver.enable = true;
      # services.xserver.fontPath = "/run/current-system/sw/share/X11/fonts";
      # services.xserver.logFile = "/tmp/Xorg.0.log";
      services.xserver.modules = with pkgs; [
        # x11
        xinit
        xf86-video-fbdev
        xf86-video-nv
        xf86-video-vesa
        xf86-video-nested
        xf86-input-libinput
      ];
      services.desktopManager.plasma6.enable = true; # Plasma 6
      services.xserver.desktopManager.xfce.enable = true; # XFCE
      # services.xserver.desktopManager.cinnamon.enable = true; # Cinnamon

      # Wayland compositors
      # programs.hyprland.enable = true;
      # programs.sway = {
      #   enable = true;
      #   wrapperFeatures.gtk = true;
      # };

      # GNOME (supports both X11 and Wayland)
      services.desktopManager.gnome.enable = true;

      # Niri compositor (Wayland)
      # programs.niri = {
      #   enable = true;
      #   # package = pkgs.niri;
      # };

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
        # winetricks # Helper scripts for Wine
        # wineWow64Packages.wayland # Wine with Wayland support
        # For better compatibility
        # dxvk # DirectX to Vulkan translation
        # vkd3d # DirectX 12 to Vulkan translation
        # vkd3d-proton
        # vkbasalt-cli
        # gamescope # Gaming compositor
        # mangohud # Performance overlay
        # goverlay # mangohud gui config
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

        # bottles # windows ?
        vulkan-loader
      ];

      # programs.gamemode.enable = true;

      # programs.gamescope = {
      #   enable = true;
      #   capSysNice = true;
      # };

      # programs.steam = {
      #   enable = true;
      #   remotePlay.openFirewall = true;
      #   dedicatedServer.openFirewall = true;
      #   localNetworkGameTransfers.openFirewall = true;
      #   extest.enable = true;
      #   protontricks.enable = true;
      #   gamescopeSession.enable = true;
      #   extraPackages = with pkgs; [
      #     gamescope
      #     bash
      #     # Provide Qt5 libraries for SteamVR
      #     qt5.qtbase
      #     qt5.qttools
      #     qt5.qtdeclarative
      #     qt5.qtwayland
      #
      #     qt6.qtbase
      #     qt6.qttools
      #     qt6.qtdeclarative
      #     qt6.qtwayland
      #     # Optionally add newer nss (though Steam runtime may still use its own)
      #     nss
      #   ];
      #   extraCompatPackages = with pkgs; [
      #     proton-ge-bin
      #   ];
      # };
    };
}
