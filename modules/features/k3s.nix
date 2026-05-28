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
        extraFlags = [
          "--with-node-id"
          "--node-label=agent=true"
        ];
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

    };
}
