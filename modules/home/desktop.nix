{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.gladosDesktop =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      # set local
      services.xserver.xkb = {
        layout = lib.mkForce "fr,us,ca,gb";
        options = lib.mkForce "grp:win_shift_toggle,eurosign:e";
      };

      # Enable SDDM as display manager
      services.displayManager.sddm.enable = true;
      services.xserver.wacom.enable = true; # wacom graphical tablet support

      # Enable both X11 and Wayland sessions
      services.xserver.enable = true;
      services.desktopManager.plasma6.enable = true; # Plasma 5 for X11
      services.xserver.desktopManager.xfce.enable = true; # XFCE as alternative X11

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
        winetricks # Helper scripts for Wine
        wineWow64Packages.wayland # Wine with Wayland support
        # For better compatibility
        dxvk # DirectX to Vulkan translation
        vkd3d # DirectX 12 to Vulkan translation
        vkd3d-proton
        vkbasalt-cli
        gamescope # Gaming compositor
        mangohud # Performance overlay
        goverlay # mangohud gui config
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
        # required for vr
        libsForQt5.qt5.qtmultimedia
      ];

      # SDDM configuration
      services.displayManager.sddm.theme = "breeze-dark";

      programs.gamescope = {
        enable = true;
        capSysNice = true;
      };

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        extest.enable = true;
        protontricks.enable = true;
        gamescopeSession.enable = true;
        extraPackages = with pkgs; [
          gamescope
          bash
          # Provide Qt5 libraries for SteamVR
          qt5.qtbase
          qt5.qttools
          qt5.qtdeclarative
          qt5.qtwayland

          qt6.qtbase
          qt6.qttools
          qt6.qtdeclarative
          qt6.qtwayland
          # Optionally add newer nss (though Steam runtime may still use its own)
          nss
        ];
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };
    };
}
