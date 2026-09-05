{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.base =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      # local
      time.timeZone = "Europe/Paris";
      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
          LC_TIME = "fr_FR.UTF-8"; # French date/time format
          LC_MONETARY = "fr_FR.UTF-8"; # Euro currency
        };
      };

      # set local
      services.xserver.xkb = {
        layout = lib.mkForce "fr,us,ca,gb";
        options = lib.mkForce "grp:win_shift_toggle,eurosign:e";
      };

      # enable zram
      zramSwap.enable = true;
      # clean /tmp
      boot.tmp.cleanOnBoot = true;
      # network
      systemd.services.NetworkManager-wait-online.enable = false; # disables the 1 minute delay
      networking = {
        networkmanager.enable = true;
        firewall.enable = true;
        dhcpcd.enable = false; # not needed with NetworkManager
      };
      networking.nftables.enable = true;

      hardware.enableRedistributableFirmware = true;
      hardware.enableAllFirmware = true;
      hardware.steam-hardware.enable = true;
      hardware.inputmodule.enable = true;
      hardware.xpad-noone.enable = true; # Xpad driver
      hardware.xone.enable = true; # xone driver for Xbox One
      hardware.xpadneo.enable = true; # Enable the xpadneo driver for Xbox One wireless controllers

      # bleutooth motherducker
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;
      hardware.usb-modeswitch.enable = true;
      services.udev.packages = with pkgs; [ usb-modeswitch ];
      services.blueman.enable = true;

      services.libinput.enable = true;

      services.udev.extraRules = ''
        # Run usb-modeswitch when your specific device is detected
        ATTR{idVendor}=="0bda", ATTR{idProduct}=="1a2b", RUN+="${lib.getExe pkgs.usb-modeswitch} -K -v 0bda -p 1a2b"
      '';

      # audio
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        wireplumber.enable = true;
        jack.enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };

      programs.dconf.enable = true;
      # Polkit for authentication dialogs
      security.polkit.enable = true;
      # Enable dbus for session management
      services.dbus.enable = true;
      # Upower for power management
      services.upower.enable = true;
      # hibernate on powerkey
      services.logind.settings.Login = {
        HandlePowerKey = "hibernate";
      };

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          kdePackages.xdg-desktop-portal-kde
          xdg-desktop-portal-gtk
        ];
        config = {
          common.default = "*";
          plasma.default = [
            "kde"
            "gtk"
          ]; # prefer KDE portal for Plasma
        };
      };

      services.homed.enable = true;
      services.nscd.enable = true; # Name Service Cache Deamon , speed up ls

      programs.appimage = {
        enable = true;
        binfmt = true;
      };

      services.flatpak.enable = true;

      # ssh
      programs.ssh = {
        enableAskPassword = false;
        # askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
      };
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "no";
        };
      };

      # enable printing cups
      services.printing = {
        enable = true;
        openFirewall = true;
      };
      # hp deskjet 36xx -> hplip
      # canon pixma 29xx -> gutenprint
      services.printing.drivers = with pkgs; [
        hplip
        gutenprint
      ];

      hardware.sane = {
        # scanners
        enable = true;
        openFirewall = true;
      };

      programs.virt-manager.enable = true;
      # virt-manager qemu kvm docker podman
      virtualisation = {
        libvirtd.enable = true;
        libvirtd.qemu = {
          package = pkgs.qemu_kvm; # optimized KVM build
          swtpm.enable = true; # TPM 2.0 for Windows 11 guests
        };
        spiceUSBRedirection.enable = true;
        containers.enable = true;
        containerd.enable = true;
        docker.enable = true;
        podman.enable = true;
      };

      programs.git = {
        enable = true;
        lfs.enable = true;
      };

      # --- System-wide shell aliases for Bash and Zsh ---
      programs.bash = {
        enable = true;
      };

      programs.zsh = {
        enable = true;
      };

      # Fish aliases (also system-wide, but we'll keep them)
      programs.fish = {
        enable = true;
      };

      # Global environment variable for Git pager
      # environment.variables = {
      #   GIT_PAGER = "delta";
      #   KUBECONFIG="/etc/rancher/k3s/k3s.yaml";
      # };

      # Fonts
      fonts.packages = with pkgs; [
        dejavu_fonts
        liberation_ttf
        fira-code
        fira-code-symbols
        noto-fonts
      ];

      environment.systemPackages = with pkgs; [
        libwacom
        mesa
        mesa-demos
        vulkan-tools

        nixfmt
        nixfmt-tree
        nix-tree

        usb-modeswitch
        sane-airscan # scanner
        xsane # scanner
        # monitor
        qemu_kvm
        htop
        btop
        iotop
        lm_sensors
        pciutils
        usbutils
        # Networking / Remote Access
        openssh
        x11_ssh_askpass
        wget
        curl
        nmap
        iftop
        rsync
        dnsutils
        # disk
        lvm2
        util-linux
        e2fsprogs
        nfs-utils
        xfsprogs
        # prog
        python315
        openjdk25
        rustup
        go
        clang_22
        # File management / compression
        git
        tree
        file
        zip
        unzip
        fzf
        jq
        eza
        bat
        vim
        nano
        fd
        fastfetch
        busybox
        less
        tmux
        # virt
        docker
        docker-compose
        virt-manager
        podman
        podman-compose
        devpod
        devpod-desktop
        wireplumber # audio
        pavucontrol # audio gui
        blueman # bluetooth

        # "new" utils
        ripgrep
        zoxide
        dua
        tealdeer
        prettyping
        doggo
        delta
        bandwhich
        zsh
        lazyjournal
        bluetui
        wpa_supplicant
        wpa_supplicant_gui
      ];
    };
}
