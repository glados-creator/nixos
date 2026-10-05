{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.audio =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      # audio
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        wireplumber.enable = true;
        jack.enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
      environment.systemPackages = with pkgs; [

        wireplumber # audio
        pavucontrol # audio gui
      ];
    };
}
