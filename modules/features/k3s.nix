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
      controlPlaneIP = "192.168.1.24";
      # Your actual server token (from /var/lib/rancher/k3s/server/token on the server)
      clusterToken = (builtins.readFile ./k3s_token.crt);
    in
    {
      environment.systemPackages = with pkgs; [
        k3s
        etcd
        multus-cni
      ];

      # Essential firewall configuration for cluster communication
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [
          6443 # Kubernetes API server
          2379 # etcd client
          2380 # etcd peer
          8472 # Flannel VXLAN (if using flannel)
          10250 # kubelet
        ];
        allowedUDPPorts = [ 8472 ]; # Flannel VXLAN
      };
      # services.k3s.enable = false;

      services.k3s = {
        enable = true;
        role = "agent";
        serverAddr = "https://${controlPlaneIP}:6443";
        token = clusterToken;
        nodeName = config.networking.hostName;
        # extraFlags = [
        #   "--node-label=agent=true"
        # ];
      };

      systemd.tmpfiles.rules = [
        # DELETE Volatile State (Run on every boot)
        # "D! /etc/rancher/k3s 0755 root root -"
        # "D! /etc/rancher/node 0755 root root -"
        "D! /var/lib/kubelet 0755 root root -"
        "D! /var/lib/longhorn 0755 root root -"
        "D! /var/lib/etcd 0755 root root -"
        "D! /var/lib/cni 0755 root root -"
        "D! /var/lib/rancher/k3s/data 0755 root root -"
        "D! /var/lib/rancher/k3s/storage 0755 root root -"
        "D! /var/lib/rancher/k3s/agent/ 0755 root root -"
      ];

      boot.kernel.sysctl = {
        # Increase the system-wide limit for inotify watches
        "fs.inotify.max_user_watches" = 524288;
        # Increase the system-wide limit for open file descriptors
        "fs.file-max" = 65535;
      };

      environment.etc."cni/net.d/00-multus.conf" = {
        text = ''
          {
            "capabilities": {
              "portMappings": true
            },
            "cniVersion": "0.3.1",
            "logLevel": "verbose",
            "logToStderr": true,
            "name": "multus-cni-network",
            "clusterNetwork": "/host/etc/cni/net.d/10-calico.conflist",
            "type": "multus-shim"
          }
        '';
      };

      environment.etc."rancher/k3s/registries.yaml" = {
        text = ''
          mirrors:
            docker.io:
              endpoint:
                - "http://harbor.main.home/dockerhub"
            ghcr.io:
              endpoint:
                - "http://harbor.main.home/ghcr"
            quay.io:
              endpoint:
                - "http://harbor.main.home/quay"
            lscr.io:
              endpoint:
                - "http://harbor.main.home/lscr"
          configs:
            "harbor.main.home":
              auth:
                username: glados
                password: PortalChell
              tls:
                insecure_skip_verify: true
        '';
      };

    };
}
