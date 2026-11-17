{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.podman =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      virtualisation = {
        docker.enable = false;
        podman = {
          enable = true;
          dockerCompat = true;
          # Needed so containers under podman-compose can resolve each other.
          defaultNetwork.settings.dns_enabled = true;
        };
        containers = {
          enable = true;
          containersConf.cniPlugins = with pkgs; [
            cni-plugins
            dnsname-cni
            # calico-cni-plugin
            # multus-cni
            # linkerd
          ];
        };
      };

      # With dockerCompat = true the socket lives at /run/docker.sock
      # and is owned by the `docker` group — add your user to it.
      # users.users.YOUR_USERNAME.extraGroups = [ "docker" ];

      systemd.user.sockets.podman = {
        enable = true;
        Unit = {
          Description = "Podman API Socket";
          Documentation = "man:podman-system-service(1)";
        };
        Socket = {
          ListenStream = "%t/podman/podman.sock"; # %t expands to $XDG_RUNTIME_DIR
          SocketMode = "0660";
        };
        Install = {
          WantedBy = [ "sockets.target" ];
        };
      };

      systemd.user.services.podman = {
        enable = true;
        Unit = {
          Description = "Podman API Service";
          Requires = "podman.socket";
          After = "podman.socket";
          Documentation = "man:podman-system-service(1)";
        };
        Service = {
          Type = "exec";
          ExecStart = "${pkgs.podman}/bin/podman system service";
          Restart = "on-failure";
          RestartSec = 1;
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };

      # users.users.YOUR_USERNAME = {
      #  linger = true;
      #  autoSubUidGidRange = true; # Good practice for rootless container users
      # };

      environment.systemPackages = with pkgs; [
        podman
        podman-compose
        podman-desktop
        podman-tui

        # "dev" module:
        podenv
        devpod
        devpod-desktop
        devenv
        vscodium
      ];
    };
}
