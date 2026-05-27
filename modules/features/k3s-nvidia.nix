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
      services.k3s.extraFlags = [
        "--node-label=nixos-nvidia-cdi=enabled"
        "--node-label=gpu=true"
      ];
      # nixos nvidia gpu operator
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/cluster/k3s/docs/examples/NVIDIA.md
      services.k3s.containerdConfigTemplate = ''
        {{ template "base" . }}

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
            privileged_without_host_devices = false
            runtime_type = "io.containerd.runc.v2"

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
            BinaryName = "${pkgs.nvidia-container-toolkit.tools}/bin/nvidia-container-runtime"
      '';

      systemd.services.k3s.path = with pkgs; [
        runc
        nvidia-container-toolkit
        libnvidia-container
      ];
      hardware.nvidia-container-toolkit.enable = true;
    };
}
