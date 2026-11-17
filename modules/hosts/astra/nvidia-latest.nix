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
        powerManagement.enable = true;
        open = true;
        nvidiaSettings = true;
        modesetting.enable = true;
      };

      # TODO : PUT REAL IDS
      # lspci -D | grep -E "VGA|3D"
      services.udev.extraRules = ''
        SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:01:00.0", SYMLINK+="dri/gpu-2060"
        SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:0a:00.0", SYMLINK+="dri/gpu-3080"
      '';

      environment.sessionVariables = {
        # Only keep the one for your compositor. The FIRST device is the primary (render) GPU.
        KWIN_DRM_DEVICES = "/dev/dri/gpu-2060:/dev/dri/gpu-3080";
        WLR_DRM_DEVICES = "/dev/dri/gpu-2060:/dev/dri/gpu-3080";
        # Hyprland:
        AQ_DRM_DEVICES  = "/dev/dri/gpu-2060:/dev/dri/gpu-3080";
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

        # x11
        # xinit
        # xf86-video-fbdev
        # xf86-video-nv
        # xf86-video-vesa
        # xf86-video-nested
      ];
      hardware.nvidia-container-toolkit.enable = true;
      hardware.nvidia-container-toolkit.mount-nvidia-executables = true;
    };
}
