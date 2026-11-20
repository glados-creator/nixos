{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.nvidia-latest =
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

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        # This adds the necessary VA-API driver for NVIDIA to the graphics driver path.
        extraPackages = with pkgs; [ nvidia-vaapi-driver ];
      };

      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.latest; # pkgs.linuxPackages.nvidiaPackages.stable;
        powerManagement.enable = false;
        open = true;
        nvidiaSettings = true;
        modesetting.enable = true;
      };

      environment.systemPackages = with pkgs; [
        nvtopPackages.nvidia
        nvitop
        btop-cuda
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

      services.udev.extraRules = ''
        SUBSYSTEM=="drm", KERNEL=="card[0-9]*", KERNELS=="0000:04:00.0", SYMLINK+="dri/gpu-2060"
        SUBSYSTEM=="drm", KERNEL=="card[0-9]*", KERNELS=="0000:07:00.0", SYMLINK+="dri/gpu-3080"
      '';
      environment.sessionVariables.KWIN_DRM_DEVICES = "/dev/dri/gpu-3080:/dev/dri/gpu-2060";

      boot.kernelParams = [
        "nvidia-drm.modeset=1"
        "nvidia-drm.fbdev=1"
      ];
    };
}
