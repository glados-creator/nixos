{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.bus =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # linker
      programs.nix-ld.dev.enable = true;

      programs.dconf.enable = true;
      # Polkit for authentication dialogs
      security.polkit.enable = true;
      services = {
        # Enable dbus for session management
        dbus.enable = true;
        # iPhone/iPad tethering, file transfer
        #   usbmuxd.enable = true;
        # Upower for power management
        upower.enable = true;
        # dbus udisks2
        udisks2.enable = true;
        # dbus virtual filesystem bus
        gvfs.enable = true;

        homed.enable = true;
        nscd.enable = true; # Name Service Cache Deamon , speed up ls
        # NFS
        rpcbind.enable = true;
        # disk errors
        smartd.enable = true;

        power-profiles-daemon.enable = true; # power profiles over D-Bus
        accounts-daemon.enable = true; # user account management over D-Bus
        logind.settings.Login = {
          # power-key hibernate
          HandlePowerKey = lib.mkDefault "hibernate";
          # lock session after 20 min
          IdleAction = "lock";
          IdleActionSec = 1200; # 20 minutes in seconds        };
        };

      };
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          kdePackages.xdg-desktop-portal-kde
          xdg-desktop-portal-gtk
        ];
        config = {
          common.default = "*";
          plasma.default = [
            "kde"
            "gtk"
          ]; # prefer KDE portal for Plasma
        };
      };
      programs.coolercontrol.enable = true;
      environment.systemPackages = with pkgs; [
        lm_sensors
      ];
    };
}
