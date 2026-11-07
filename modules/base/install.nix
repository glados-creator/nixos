{
  self,
  inputs,
  ...
}:
{
  # Core CLI tools: on every profile (including minimal-rpi).
  flake.nixosModules.install =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # Global environment variable for Git pager
      # environment.variables = {
      #   GIT_PAGER = "delta";
      #   KUBECONFIG="/etc/rancher/k3s/k3s.yaml";
      # };

      environment.systemPackages = with pkgs; [
        # Networking / Remote Access
        openssh
        wget
        curl
        rsync
        dnsutils

        # monitor
        htop
        btop
        iotop
        lm_sensors
        pciutils
        usbutils

        # disk
        lvm2
        util-linux
        e2fsprogs
        nfs-utils
        xfsprogs

        # File management / compression
        git
        tree
        file
        zip
        unzip
        jq
        vim
        nano
        less
        tmux
        fastfetch
        ripgrep
        fd
      ];
    };

  # Extras + dev toolchains: profile-full only.
  flake.nixosModules.install-full =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      programs.nix-ld.dev.enable = true;
      environment.systemPackages = with pkgs; [
        # nix
        nixfmt
        nixfmt-tree
        nix-tree

        # monitor / network
        iftop
        bandwhich
        lazyjournal

        # "new" utils
        fzf
        eza
        bat
        busybox
        zoxide
        dua
        tealdeer # tldr man
        prettyping
        doggo
        delta

        # prog
        python315
        openjdk25
        rustup
        go
        clang_22
        graphviz
        gh

        networkmanagerapplet

          # Connectivity & Basic Info
  curl              # HTTP/HTTPS client
  wget              # Download utility
  dig               # DNS lookup
  mtr               # Combination of ping and traceroute
  traceroute        # Trace network path
  nettools          # ifconfig, netstat, etc. (legacy but useful)
  ethtool           # Query/control network driver & hardware settings

  # Traffic & Analysis
  tcpdump           # Command-line packet analyzer
  nmap              # Network exploration and security auditing
  iperf3            # Network bandwidth measurement
  socat             # Multipurpose relay (netcat on steroids)
  nethogs           # Per-process bandwidth monitor
  bandwhich         # Terminal bandwidth utilization monitor

  # VPN & Advanced
  wireguard-tools   # WireGuard VPN utilities
  openvpn           # OpenVPN client
      ];
    };
}
