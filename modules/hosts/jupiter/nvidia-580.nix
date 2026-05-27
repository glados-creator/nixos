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

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        # This adds the necessary VA-API driver for NVIDIA to the graphics driver path.
        extraPackages = with pkgs; [ nvidia-vaapi-driver ];
      };

      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.legacy_580; # pkgs.linuxPackages.nvidiaPackages.stable;
        powerManagement.enable = true;
        open = false;
        nvidiaSettings = true;
        modesetting.enable = true;
      };

      environment.systemPackages = with pkgs; [
        nvtopPackages.nvidia
        nvitop
        nvidia-container-toolkit
        opencl-caps-viewer
        libva-vdpau-driver
        libvdpau-va-gl
        nvidia-vaapi-driver
        nv-codec-headers
        libva-utils
        vdpauinfo
        mesa-demos
      ];
      hardware.nvidia-container-toolkit.enable = true;
      hardware.nvidia-container-toolkit.mount-nvidia-executables = true;
    };
}
