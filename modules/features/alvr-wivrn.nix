{
  self,
  inputs,
  ...
}:
{

  # todo : update this crap
  # fix the "one day" things in read me
  # install cachix nixfmt
  # fix home manager

  #  https://github.com/vimjoyer/nixconf/blob/421795866265554d9ca5f2c7b658aac80d9ab0f9/nixos/features/gaming.nix
  # https://github.com/vimjoyer/nixconf/blob/421795866265554d9ca5f2c7b658aac80d9ab0f9/nixos/features/vr.nix
  # vr-xr pkgs
  # see https://github.com/vimjoyer/nixconf/blob/main/nixos/features/nix.nix
  flake.nixosModules.thingy =
    {
      config,
      pkgs,
      lib,
      stdenv,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        # vr
        alvr
        monado
        wayvr
        wivrn
        opencomposite
        # xrizer
        basalt-monado
        openxr-loader
        monado-vulkan-layers

        unzip
        x264
        ffmpeg

        vulkan-tools
        libva
        libdrm
        libxkbcommon
        vulkan-headers
        vulkan-loader
        binutils-unwrapped
      ];

      # NEW
      # https://github.com/alvr-org/ALVR/issues/2792

      # OLD
      # https://github.com/NixOS/nixpkgs/issues/258196
      # https://monado.freedesktop.org/steamvr.html
      # https://wiki.nixos.org/wiki/VR
      # sudo setcap CAP_SYS_NICE+ep ~/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher
      # Monado can be run with the following commands:
      #   systemctl --user start monado.service
      #   systemctl --user stop monado.{service,socket}
      #   journalctl --user --follow --unit monado.service
      # Games require LAUNCH OPTIONS: "env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%"
      # steam-run ./alvr-dashboard

      # Monado (The OpenXR Runtime)
      services.monado = {
        enable = true;
        defaultRuntime = true; # Register as default OpenXR runtime
      };
      # environment.variables = {
      #   STEAMVR_LH_ENABLE = "1";
      #   XRT_COMPOSITOR_COMPUTE = "1";
      #   WMR_HANDTRACKING = "0";
      #
      #   VIT_SYSTEM_LIBRARY_PATH = "${pkgs.basalt-monado}/lib/libbasalt.so";
      # };
      # Also needed for NVIDIA stability
      hardware.graphics.extraPackages = with pkgs; [ monado-vulkan-layers ];

      systemd.user.services.monado.environment = {
        STEAMVR_LH_ENABLE = "1";
        XRT_COMPOSITOR_COMPUTE = "1";
        IPC_EXIT_ON_DISCONNECT = "1";
        WMR_HANDTRACKING = "1";

        VIT_SYSTEM_LIBRARY_PATH = "${pkgs.basalt-monado}/lib/libbasalt.so";
      };

      # WiVRn (Wireless Streaming for Quest)
      services.wivrn = {
        enable = true;
        openFirewall = true;
        # defaultRuntime = true;  # Makes WiVRn the default OpenXR runtime
        highPriority = true;
        autoStart = false; # Start on boot

        # CRITICAL for RTX 3080: Enable GPU encoding with CUDA
        package = pkgs.wivrn.override { cudaSupport = true; };
        steam.importOXRRuntimes = true;
      };

      programs.alvr = {
        enable = true;
        openFirewall = true;
      };

      programs.steam.package = pkgs.steam.override {
        extraProfile = ''
          # Allows Monado to be used
          export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
        '';
      };

      # OpenXR discovery
      home-manager.users."glados" = {
        xdg.configFile."openxr/1/active_runtime.json".source =
          "${config.services.monado.package}/share/openxr/1/openxr_monado.json";
        home.file.".local/share/monado/hand-tracking-models".source = pkgs.fetchgit {
          url = "https://gitlab.freedesktop.org/monado/utilities/hand-tracking-models";
          sha256 = "sha256-x/X4HyyHdQUxn3CdMbWj5cfLvV7UyQe1D01H93UCk+M=";
          fetchLFS = true;
        };
        xdg.configFile."openvr/openvrpaths.vrpath".text = builtins.toJSON {
          config = [ "${config.home-manager.users."glados".xdg.dataHome}/Steam/config" ];
          external_drivers = null;
          jsonid = "vrpathreg";
          log = [ "${config.home-manager.users."glados".xdg.dataHome}/Steam/logs" ];
          runtime = [ "${pkgs.opencomposite}/lib/opencomposite" ];
          version = 1;
        };
      };
    };
}
