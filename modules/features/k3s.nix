{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.k3s =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      # Your cluster's control plane address
      controlPlaneIP = "192.168.1.24";
    in
    {
      imports = [
        self.nixosModules.Ceph
      ];

      environment.variables = {
        KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
      };

      environment.systemPackages = with pkgs; [
        k3s
        etcd
        cni-plugins
        calico-cni-plugin
        multus-cni
        linkerd
        kubevirt
        kubectl
        k9s
        cri-tools # crictl
        crun
      ];

      # Agent node: only what workers need
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [
          6443 # Kubernetes API server
          2379 # etcd client
          2380 # etcd peer
          10250 # kubelet
          5473 # Calico Typha
          179 # Calico BGP
        ];
        allowedUDPPorts = [
          4789 # Calico VXLAN
        ];
      };

      services.k3s = {
        enable = true;
        role = "agent";
        serverAddr = "https://${controlPlaneIP}:6443";
        # Keep the token out of /nix/store: create this file by hand (or via sops-nix)
        tokenFile = "/etc/k3s/token";
        nodeName = config.networking.hostName;
        extraFlags = [
          "--kubelet-arg=--fail-swap-on=false"
          "--kube-proxy-arg=--proxy-mode=nftables"
          "--container-runtime-endpoint=unix:///var/run/crio/crio.sock"
          "--kubelet-arg=cgroup-driver=systemd"
        ]
        ++ lib.optionals (config.services.k3s.role == "server") [
          "--disable=traefik"
          "--disable=helm-controller"
          "--disable=servicelb"
          "--disable=metrics-server"
          "--disable-network-policy"
          "--flannel-backend=none"
        ];
      };

      # k3s must start after CRI-O
      systemd.services.k3s = {
        after = [ "crio.service" ];
        requires = [ "crio.service" ];
      };

      # Standard CNI plugins. Calico's own binaries (calico, calico-ipam)
      # are written to /opt/cni/bin by its install-cni container.
      systemd.tmpfiles.rules = [
        "C+ /opt/cni/bin/bandwidth - - - - ${pkgs.cni-plugins}/bin/bandwidth"
        "C+ /opt/cni/bin/bridge - - - - ${pkgs.cni-plugins}/bin/bridge"
        "C+ /opt/cni/bin/dhcp - - - - ${pkgs.cni-plugins}/bin/dhcp"
        "C+ /opt/cni/bin/dummy - - - - ${pkgs.cni-plugins}/bin/dummy"
        "C+ /opt/cni/bin/firewall - - - - ${pkgs.cni-plugins}/bin/firewall"
        "C+ /opt/cni/bin/host-device - - - - ${pkgs.cni-plugins}/bin/host-device"
        "C+ /opt/cni/bin/host-local - - - - ${pkgs.cni-plugins}/bin/host-local"
        "C+ /opt/cni/bin/ipvlan - - - - ${pkgs.cni-plugins}/bin/ipvlan"
        "C+ /opt/cni/bin/loopback - - - - ${pkgs.cni-plugins}/bin/loopback"
        "C+ /opt/cni/bin/macvlan - - - - ${pkgs.cni-plugins}/bin/macvlan"
        "C+ /opt/cni/bin/portmap - - - - ${pkgs.cni-plugins}/bin/portmap"
        "C+ /opt/cni/bin/ptp - - - - ${pkgs.cni-plugins}/bin/ptp"
        "C+ /opt/cni/bin/sbr - - - - ${pkgs.cni-plugins}/bin/sbr"
        "C+ /opt/cni/bin/static - - - - ${pkgs.cni-plugins}/bin/static"
        "C+ /opt/cni/bin/tap - - - - ${pkgs.cni-plugins}/bin/tap"
        "C+ /opt/cni/bin/tuning - - - - ${pkgs.cni-plugins}/bin/tuning"
        "C+ /opt/cni/bin/vlan - - - - ${pkgs.cni-plugins}/bin/vlan"
        "C+ /opt/cni/bin/vrf - - - - ${pkgs.cni-plugins}/bin/vrf"
      ];

      boot.kernel.sysctl = {
        # Increase the system-wide limit for inotify watches
        "fs.inotify.max_user_watches" = 524288;
        # Increase the system-wide limit for open file descriptors
        "fs.file-max" = 65535;
        # needed for multus multiple NICs
        "net.ipv4.conf.all.rp_filter" = 2;
        "net.ipv4.conf.default.rp_filter" = 2;
      };

      virtualisation.cri-o.enable = true;

      # k3s's registries.yaml is ignored with external CRI-O, so mirrors are
      # defined here. Harbor credentials go in /etc/containers/auth.json
      # or in imagePullSecrets, not in Nix.
      # nixpkgs' containers module only has the deprecated v1 options on this pin,
      # so write a v2 registries.conf (with Harbor mirrors) ourselves.
      environment.etc."containers/registries.conf".source = lib.mkForce (
        (pkgs.formats.toml { }).generate "registries.conf" {
          unqualified-search-registries = [ "docker.io" ];
          registry =
            lib.mapAttrsToList
              (reg: project: {
                prefix = reg;
                location = reg;
                mirror = [
                  {
                    location = "harbor.main.home/${project}";
                    insecure = true;
                  }
                ];
              })
              {
                "docker.io" = "docker";
                "ghcr.io" = "ghcr";
                "quay.io" = "quay";
                "codeberg.org" = "codeberg";
                "lscr.io" = "lscr";
              };
        }
      );

      environment.etc."crio/crio.conf.d/10-k3s.conf".text = ''
        [crio]
        root = "/var/lib/crio"

        [crio.image]
        global_auth_file = "/etc/crio/auth.json"

        [crio.runtime]
        default_runtime = "crun"
        cgroup_manager = "systemd"
        conmon_cgroup = "pod"

        [crio.runtime.runtimes.crun]
        runtime_path = "${pkgs.crun}/bin/crun"
        runtime_type = "oci"
        runtime_root = "/run/crun"

        [crio.network]
        network_dir = "/etc/cni/net.d/"
        plugin_dirs = ["/opt/cni/bin"]
      '';
    };
}
