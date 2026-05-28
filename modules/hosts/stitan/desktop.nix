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
      # Enable X11
      services.xserver.enable = true;

      # XFCE desktop environment only
      services.xserver.desktopManager.xfce.enable = true;

      # No display manager (SDDM not installed/enabled)

      # Basic X11 packages for startx - using correct names
      environment.systemPackages = with pkgs; [
        xinit # Provides startx command (was xorg.xinit)
        xrandr # For display management (was xorg.xrandr)
        xfce4-terminal # (was xfce.xfce4-terminal)
        mousepad # Simple text editor (was xfce.mousepad)
        thunar # File manager (was xfce.thunar)
        networkmanagerapplet
        pavucontrol # Audio control
      ];

      # Simple startx xinitrc
      environment.etc."X11/xinit/xinitrc".text = ''
        #!/bin/sh
        # System-wide xinitrc - starts XFCE by default
        exec startxfce4
      '';

      # Make sure the file is executable
      environment.etc."X11/xinit/xinitrc".mode = "0755";
    };
}
