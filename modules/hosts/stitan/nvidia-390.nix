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
      services.xserver.videoDrivers = [ "nvidia" ];
      # Enable OpenGL
      hardware.graphics.enable = true;
      hardware.graphics.enable32Bit = true;

      hardware.nvidia.nvidiaPersistenced = false; # tmp until nixpkgs commit 4c1018dae (2026-04-09)

      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.legacy_390; # pkgs.linuxPackages.nvidiaPackages.legacy_390;
        modesetting.enable = true;
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
        nvidia-vaapi-driver
        nv-codec-headers
      ];
      hardware.nvidia-container-toolkit.enable = true;
      hardware.nvidia-container-toolkit.mount-nvidia-executables = true;
    };
}
