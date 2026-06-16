{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.plutoamdgpu =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # Graphics drivers
      services.xserver.videoDrivers = [ "amdgpu" ];

      # Enable Mesa + ROCm OpenCL
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [ rocmPackages.clr.icd ];
      };

      # System packages
      environment.systemPackages = with pkgs; [
        nvtopPackages.amd
        opencl-caps-viewer
        libva-utils
        vdpauinfo
        mesa-demos
        rocmPackages.rocminfo
        rocmPackages.rocm-smi
      ];

      # Environment variables for ROCm
      environment.variables = {
        ROC_ENABLE_PRE_VEGA = "1";
        OCL_ICD_VENDORS = "${pkgs.rocmPackages.clr.icd}/etc/OpenCL/vendors";
      };
    };
}