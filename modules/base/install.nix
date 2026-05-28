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
      i18n.defaultLocale = "fr_FR.UTF-8";

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

      xdg = {
        portal = {
          enable = true;
          xdgOpenUsePortal = true;

          extraPortals = with pkgs; [
            kdePackages.xdg-desktop-portal-kde
            xdg-desktop-portal-gtk
          ];
        };
      };

      programs.appimage = {
        enable = true;
        binfmt = true;
      };

      services.flatpak.enable = true;

      hardware.enableAllFirmware = true;
      hardware.steam-hardware.enable = true;
      hardware.inputmodule.enable = true;
      hardware.xpad-noone.enable = true; # Xpad driver
      hardware.xone.enable = true; # xone driver for Xbox One
      hardware.xpadneo.enable = true; # Enable the xpadneo driver for Xbox One wireless controllers

      # bluetooth
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
      # bleutooth motherducker
      services.udev.packages = with pkgs; [ usb-modeswitch ];

      # audio
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        wireplumber.enable = true;
        jack.enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };

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

      programs.fish = {
        enable = true;
        shellAliases = {
          ll = "eza -larth";
          eza = "ls"; # alias eza -> ls
          bat = "cat"; # alisa bat -> cat
          # rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#astra";
        };
      };

      # Fonts for better rendering
      fonts.packages = with pkgs; [
        dejavu_fonts
        liberation_ttf
        fira-code
        fira-code-symbols
        noto-fonts
      ];

      environment.systemPackages = with pkgs; [
        libwacom
        mesa-demos
        vulkan-tools

        nixfmt
        nixfmt-tree

        usb-modeswitch
        sane-airscan # scanner
        xsane # scanner
        # monitor
        qemu_kvm
        htop
        btop
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
        # mold
        clang_22
        # File management / compression
        git
        tree
        file
        zip
        unzip
        # tar
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
      ];
    };
}
