{
  self,
  inputs,
  ...
}:
{
  #  https://github.com/vimjoyer/nixconf/blob/421795866265554d9ca5f2c7b658aac80d9ab0f9/nixos/features/gaming.nix
  # https://github.com/vimjoyer/nixconf/blob/421795866265554d9ca5f2c7b658aac80d9ab0f9/nixos/features/vr.nix
  # vr-xr pkgs
  # see https://github.com/vimjoyer/nixconf/blob/main/nixos/features/nix.nix
  flake.nixosModules.VR =
    # modules/nixos/vr.nix
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      # Pick up the user's home directory from NixOS config – no recursion.
      userHome = config.users.users.glados.home;
    in
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
      ];
      # ---------------------------
      # System packages
      # ---------------------------
      nixpkgs.config.android_sdk.accept_license = true;

      environment.systemPackages = with pkgs; [
        # VR streaming & runtimes
        alvr
        wivrn
        wayvr
        monado
        openxr-loader
        opencomposite # keep for non-streaming use, but don't make it default
        vulkan-tools
        libva
        libdrm
        libxkbcommon
        vulkan-headers
        vulkan-loader
        binutils-unwrapped
        unzip
        x264
        ffmpeg

        # alvr build tools
        # androidsdk
        # android-studio-full
        # android-studio-tools
        # android-studio
        android-tools

        # android-tools
        brotli
        bzip2
        celt
        # ffmpeg-alvr
        gmp
        jack2
        lame
        libx11
        libxcursor
        libxi
        libxrandr
        # libdrm
        libglvnd
        libogg
        libpng
        libtheora
        libunwind
        # libva
        libvdpau
        # libxkbcommon
        openapv
        openssl
        openvr
        pipewire
        soxr
        # vulkan-headers
        # vulkan-loader
        wayland
        # x264
        xvidcore
      ];

      # ---------------------------
      # Monado OpenXR runtime (user service)
      # ---------------------------
      services.monado = {
        enable = true;
        defaultRuntime = true; # Register as default OpenXR runtime
      };

      # Environment variables for Monado (hand‑tracking, SLAM, etc.)
      systemd.user.services.monado.environment = {
        STEAMVR_LH_ENABLE = "1";
        XRT_COMPOSITOR_COMPUTE = "1";
        IPC_EXIT_ON_DISCONNECT = "1";
        WMR_HANDTRACKING = "1";
        VIT_SYSTEM_LIBRARY_PATH = "${pkgs.basalt-monado}/lib/libbasalt.so";
      };

      # Monado Vulkan layers
      hardware.graphics.extraPackages = with pkgs; [ monado-vulkan-layers ];

      # ---------------------------
      # ALVR (wireless Quest streaming)
      # ---------------------------
      programs.alvr = {
        enable = true;
        openFirewall = true;
      };

      # ---------------------------
      # WiVRn (standalone OpenXR streaming) – optional
      # ---------------------------
      services.wivrn = {
        enable = true;
        openFirewall = true;
        # defaultRuntime = true;   # keep monado as default
        highPriority = true;
        autoStart = false;

        # Enable NVIDIA hardware encoding (CUDA) if you have an Nvidia card
        package = pkgs.wivrn.override { cudaSupport = true; };
        steam.importOXRRuntimes = true;
      };

      # ---------------------------
      # Steam (with OpenXR awareness)
      # ---------------------------
      programs.steam = {
        enable = true;
        package = pkgs.steam.override {
          extraProfile = ''
            export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
          '';
        };
      };

      # ---------------------------
      # Home‑manager user config (glados)
      # ---------------------------
      home-manager.users.glados = {
        # MUST enable XDG for configFile to work
        xdg.enable = true;
        # xdg.dataHome = "${userHome}/.local/share";

        # Tell the system which OpenXR runtime to use
        xdg.configFile."openxr/1/active_runtime.json".source =
          "${config.services.monado.package}/share/openxr/1/openxr_monado.json";

        # Hand‑tracking models (needed for Monado controller‑free tracking)
        home.file.".local/share/monado/hand-tracking-models".source = pkgs.fetchgit {
          url = "https://gitlab.freedesktop.org/monado/utilities/hand-tracking-models";
          sha256 = "sha256-x/X4HyyHdQUxn3CdMbWj5cfLvV7UyQe1D01H93UCk+M=";
          fetchLFS = true;
        };

        # IMPORTANT: Do NOT override openvrpaths with OpenComposite here.
        # ALVR uses its own OpenVR driver; forcing OpenComposite would break wireless streaming.
        # If you later want OpenComposite for wired/Oculus, do it conditionally.
      };
    };
}
