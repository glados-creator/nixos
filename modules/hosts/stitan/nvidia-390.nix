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
      # No nvidia.acceptLicense / allowBroken needed — nouveau is fully FOSS,
      # nothing to license-accept and nothing marked broken.

      services.xserver.videoDrivers = [ "nouveau" "modesetting" "fbdev" ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        # nvidia-vaapi-driver is specifically a bridge to NVIDIA's proprietary
        # NVDEC — meaningless without the nvidia kernel module, so it's gone.
        # Nouveau's VDPAU support comes from Mesa itself (nouveau state tracker);
        # libvdpau-va-gl bridges that to VA-API consumers. Kept below.
      };

      # All hardware.nvidia.* settings removed entirely — they're specific to
      # the nvidia/nvidia-open kernel modules and do nothing (or fail to eval)
      # once videoDrivers no longer includes "nvidia".

      # nvidia-drm.fbdev=1 was working around the nvidia-drm KMS fbdev handoff.
      # Nouveau's DRM/KMS fbdev just works without a kernel param.
      boot.kernelParams = [ ];

      environment.systemPackages = with pkgs; [
        nvtopPackages.full   # nvidia-specific nvtop variant swapped for the generic build
        nvitop
        btop                 # btop-cuda has no meaning without CUDA
        # nvidia-container-toolkit
        opencl-caps-viewer
        libva-vdpau-driver
        libvdpau-va-gl
        # nvidia-vaapi-driver
        # nv-codec-headers
        libva-utils
        vdpauinfo
        mesa-demos

        # x11
        xinit
        xf86-video-fbdev
        xf86-video-vesa
        xf86-video-nested
        xf86-input-libinput
        # xf86-video-nv dropped — that's the old NV DDX for pre-KMS nvidia,
        # not relevant to nouveau (which uses the generic modesetting DDX)
      ];

      # nvidia-container-toolkit and opencl-caps-viewer dropped: no CUDA,
      # no meaningful OpenCL surface under nouveau without Rusticl, and this
      # box was never going to be a container GPU-compute node on a Fermi card.
      hardware.nvidia-container-toolkit.enable = lib.mkForce false;
      hardware.nvidia-container-toolkit.mount-nvidia-executables = false;
    };
}
