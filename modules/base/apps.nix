{
  self,
  inputs,
  ...
}:
{
  # Fonts + app delivery. profile-full only.
  flake.nixosModules.apps =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      fonts.packages = with pkgs; [
        dejavu_fonts
        liberation_ttf
        fira-code
        fira-code-symbols
        noto-fonts
      ];

      programs.appimage = {
        enable = true;
        binfmt = true;
      };

      services.flatpak.enable = true;

      environment.systemPackages = with pkgs; [
        wpa_supplicant_gui
      ];
    };
}
