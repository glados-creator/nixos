{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.AstraGuestDesktop =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      # security.pam.loginLimits = [
      #   { domain = "@audio"; type = "-"; item = "rtprio";  value = "95"; }
      #   { domain = "@audio"; type = "-"; item = "memlock"; value = "unlimited"; }
      #   { domain = "@audio"; type = "-"; item = "nice";    value = "-19"; }
      # ];

      # Enable SDDM ~kde plasma login manager~ as display manager
      services.displayManager.sddm.enable = true;
      services.xserver.wacom.enable = true; # wacom graphical tablet support

      # Enable both X11 and Wayland sessions
      services.xserver.enable = true;
      services.desktopManager.plasma6.enable = true; # Plasma 6
      services.xserver.desktopManager.xfce.enable = true; # XFCE

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

      programs.gamemode.enable = true;

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
