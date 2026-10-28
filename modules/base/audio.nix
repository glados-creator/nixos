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
      # Enable RealtimeKit to grant audio processes real-time scheduling
      security.rtkit.enable = true;
      hardware.pulseaudio.enable = false; 
      services.pipewire = {
        enable = true;
        wireplumber.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # jack.enable = true;
      };
      environment.systemPackages = with pkgs; [
        wireplumber # audio
        pavucontrol # audio gui
      ];
    };
}
