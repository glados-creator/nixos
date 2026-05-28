{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.jupiterNvidia580 =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      nixpkgs.config.nvidia.acceptLicense = true;
      services.xserver.videoDrivers = [ "nvidia" ];
      # Enable OpenGL
      hardware.graphics.enable = true;
      hardware.graphics.enable32Bit = true;

      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.legacy_580; # pkgs.linuxPackages.nvidiaPackages.stable;
        powerManagement.enable = true;
        open = false;
        nvidiaSettings = true;
      };

      environment.systemPackages = with pkgs; [
        nvtopPackages.nvidia
        nvitop
        nvidia-container-toolkit
        opencl-caps-viewer
        libva-vdpau-driver
        libvdpau-va-gl
      ];
      hardware.nvidia-container-toolkit.enable = true;
      hardware.nvidia-container-toolkit.mount-nvidia-executables = true;
    };
}
