{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.config =
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

      programs.git = {
        enable = true;
        lfs.enable = true;
      };

      programs.bash = {
        enable = true;
      };

      programs.zsh = {
        enable = true;
      };

      programs.fish = {
        enable = true;
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

      # Fonts
      fonts.packages = with pkgs; [
        dejavu_fonts
        liberation_ttf
        fira-code
        fira-code-symbols
        noto-fonts
      ];

      programs.appimage = {
        enable = true;
        binfmt = true;
      };

      services.flatpak.enable = true;

      hardware.enableRedistributableFirmware = true;
      hardware.enableAllFirmware = true;
      hardware.steam-hardware.enable = true;
      hardware.inputmodule.enable = true;
      hardware.xpad-noone.enable = true; # Xpad driver
      hardware.xone.enable = true; # xone driver for Xbox One
      hardware.xpadneo.enable = true; # Enable the xpadneo driver for Xbox One wireless controllers

      services.libinput.enable = true;

      environment.systemPackages = with pkgs; [
        nixfmt
        nixfmt-tree
        nix-tree
        openssh
        wget
        curl
        iftop
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

        # "new" utils
        ripgrep
        zoxide
        dua
        tealdeer # tldr man
        prettyping
        doggo
        delta
        bandwhich
        zsh
        lazyjournal

        # idk
        libwacom
        mesa
        mesa-demos
        vulkan-tools

        # prog
        python315
        openjdk25
        rustup
        go
        clang_22
        graphviz
        gh
      ];
    };
}
