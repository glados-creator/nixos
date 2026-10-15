{
  self,
  inputs,
  ...
}:
{
  # k3s with CRI-O instead of the embedded containerd.
  # Import it next to your existing `k3s` module; it only acts when
  # services.k3s.enable = true.
  flake.nixosModules.k3s-crio =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      # k3s's flannel writes its CNI conf to the dir below and delegates to
      # `flannel` + `bridge` + `portmap`: give CRI-O those binaries.
      cniBin = pkgs.symlinkJoin {
        name = "k3s-cni-bin";
        paths = [
          pkgs.cni-plugins
          pkgs.cni-plugin-flannel
        ];
      };
    in
    {
      imports = [ self.nixosModules.kernel-modules-cluster ];

      config = lib.mkIf config.services.k3s.enable {
        virtualisation.cri-o.enable = true;

        # one unqualified registry => short image names (`nginx`) are not ambiguous
        virtualisation.containers.registries.search = lib.mkDefault [ "docker.io" ];

        # drop-in sorts after the module's 00-default.conf and overrides it
        environment.etc."crio/crio.conf.d/10-k3s.conf".text = ''
          [crio.runtime]
          cgroup_manager = "systemd"
          conmon_cgroup = "pod"

          [crio.network]
          network_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/"
          plugin_dirs = ["${cniBin}/bin"]
        '';

        services.k3s.extraFlags = [
          # setting this disables k3s's embedded containerd
          "--container-runtime-endpoint=unix:///var/run/crio/crio.sock"
          "--kubelet-arg=cgroup-driver=systemd"
        ];

        systemd.services.k3s = {
          after = [ "crio.service" ];
          requires = [ "crio.service" ];
        };
      };
    };
}
