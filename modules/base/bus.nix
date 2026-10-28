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
      programs.dconf.enable = true;
      # Polkit for authentication dialogs
      security.polkit.enable = true;
      # Enable dbus for session management
      services.dbus.enable = true;
      # Upower for power management
      services.upower.enable = true;
      # hibernate on powerkey (mkDefault: a host can override if the hardened kernel blocks hibernation)
      services.logind.settings.Login = {
        HandlePowerKey = lib.mkDefault "hibernate";
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

      services.homed.enable = true;
      services.nscd.enable = true; # Name Service Cache Deamon , speed up ls
    };
}
