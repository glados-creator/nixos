{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.stitanNvidia390 =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      nixpkgs.config.allowBroken = true; # allow broken packages
      nixpkgs.config.nvidia.acceptLicense = true;
      services.xserver.videoDrivers = [ "nvidia" "modesetting" "fbdev" ];
      # services.xserver.videoDrivers = [ "modesetting" ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        # This adds the necessary VA-API driver for NVIDIA to the graphics driver path.
        extraPackages = with pkgs; [ nvidia-vaapi-driver ];
      };

      hardware.nvidia.nvidiaPersistenced = false; # tmp until nixpkgs commit 4c1018dae (2026-04-09)

      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.legacy_390; # pkgs.linuxPackages.nvidiaPackages.legacy_390;
        # powerManagement.enable = true;
        open = false;
        nvidiaSettings = true;
        modesetting.enable = true;
      };

      boot.kernelParams = [ "nvidia-drm.fbdev=1" ];

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
        xinit
        xf86-video-fbdev
        xf86-video-nv
        xf86-video-vesa
        xf86-video-nested
        xf86-input-libinput
      ];
      hardware.nvidia-container-toolkit.enable = true;
      hardware.nvidia-container-toolkit.mount-nvidia-executables = true;
    };
}
