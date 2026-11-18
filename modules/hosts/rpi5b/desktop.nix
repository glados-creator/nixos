{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.rpi5bDesktop =
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
      services.displayManager.sddm.wayland.enable = true;

      # Enable both X11 and Wayland sessions
      services.xserver.enable = false;
      services.xserver.desktopManager.xfce.enable = true; # XFCE
      # services.xserver.desktopManager.cinnamon.enable = true; # Cinnamon

      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
      };

    };
}
