{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.k3sGpu =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      imports = [
        self.nixosModules.k3s
      ];

      services.k3s.extraFlags = [
        "--node-label=nixos-nvidia-cdi=enabled"
        "--node-label=gpu=true"
      ];
      # nixos nvidia gpu operator
      systemd.services.k3s.path = with pkgs; [
        runc
        nvidia-container-toolkit
        libnvidia-container
      ];
      # Generates the CDI spec (nvidia.com/gpu=...) in /run/cdi
      hardware.nvidia-container-toolkit.enable = true;

      # CRI-O reads CDI specs from these dirs (these are its defaults, set explicitly here)
      environment.etc."crio/crio.conf.d/30-cdi.conf".text = ''
        [crio.runtime]
        cdi_spec_dirs = ["/etc/cdi", "/var/run/cdi"]
      '';

      # Make sure the spec exists before CRI-O starts
      systemd.services.crio = {
        after = [ "nvidia-container-toolkit-cdi-generator.service" ];
        wants = [ "nvidia-container-toolkit-cdi-generator.service" ];
      };
    };
}
