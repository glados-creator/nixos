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
      stdenv,
      ...
    }:
    let
      # Your cluster's control plane address
      controlPlaneIP = "192.168.1.14";
      # Your actual server token (from /var/lib/rancher/k3s/server/token on the server)
      clusterToken = (builtins.readFile ./k3s_token.crt);
    in
    {
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
      ];

      # Essential firewall configuration for cluster communication
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
      # services.k3s.enable = false;

      services.k3s = {
        enable = true;
        role = "agent";
        serverAddr = "https://${controlPlaneIP}:6443";
        token = clusterToken;
        nodeName = config.networking.hostName;
        extraFlags = [
          # "--cluster-init"
          "--disable=traefik"
          "--disable=helm-controller"
          "--flannel-backend=none"
          "--disable-network-policy"
          "--disable=servicelb"
          "--disable=metrics-server"
          "--kubelet-arg=--fail-swap-on=false"
          "--kube-proxy-arg=--proxy-mode=nftables"
          # "--node-label=server=true"
          "--node-label=agent=true"
          # "--kubelet-arg=--masquerade-all=true"
          "--container-runtime-endpoint=unix:///var/run/crio/crio.sock"
          "--kubelet-arg=cgroup-driver=systemd"
        ];
      };

      # systemd.tmpfiles.rules = [
      #   # DELETE Volatile State (Run on every boot)
      #   # "D! /etc/rancher/k3s 0755 root root -"
      #   # "D! /etc/rancher/node 0755 root root -"
      #   # "D! /var/lib/kubelet 0755 root root -"
      #   # "D! /var/lib/longhorn 0755 root root -"
      #   # "D! /var/lib/etcd 0755 root root -"
      #   # "D! /var/lib/cni 0755 root root -"
      #   # "D! /var/lib/rancher/k3s/data 0755 root root -"
      #   # "D! /var/lib/rancher/k3s/storage 0755 root root -"
      #   # "D! /var/lib/rancher/k3s/agent/ 0755 root root -"
      # ];

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

      # environment.etc."cni/net.d/00-multus.conf" = {
      #   text = ''
      #     {
      #       "capabilities": {
      #         "portMappings": true
      #       },
      #       "cniVersion": "0.3.1",
      #       "logLevel": "verbose",
      #       "logToStderr": true,
      #       "name": "multus-cni-network",
      #       "clusterNetwork": "/host/etc/cni/net.d/10-calico.conflist",
      #       "type": "multus-shim"
      #     }
      #   '';
      # };

      environment.etc."rancher/k3s/registries.yaml" = {
        text = ''
          mirrors:
            docker.io:
              endpoint:
                - "http://harbor.main.home/docker"
            ghcr.io:
              endpoint:
                - "http://harbor.main.home/ghcr"
            quay.io:
              endpoint:
                - "http://harbor.main.home/quay"
            codeberg.org:
              endpoint:
                - "http://harbor.main.home/codeberg"
            lscr.io:
              endpoint:
                - "http://harbor.main.home/lscr"
          configs:
            "harbor.main.home":
              auth:
                username: <username>
                password: <Password>
              tls:
                insecure_skip_verify: true
        '';
      };

      virtualisation.cri-o.enable = true;

      environment.etc."crio/crio.conf.d/10-k3s.conf".text = ''
        [crio]
        root = "/var/lib/crio"

        [crio.runtime]
        cgroup_manager = "systemd"
        conmon_cgroup = "pod"

        [crio.network]
        network_dir = "/etc/cni/net.d/"
        plugin_dirs = ["/opt/cni/bin"]
      '';

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

    };
}
