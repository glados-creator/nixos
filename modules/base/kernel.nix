{
  self,
  inputs,
  ...
}:
{
  # ---------------------------------------------------------------------------
  # CachyOS kernel (x86_64 only; Pis keep the nixos-raspberrypi kernel).
  # Default flavour: cachyos-hardened. Per host:
  #   custom.kernel.variant = "lts" | "latest" | "nixpkgs";
  # ---------------------------------------------------------------------------
  flake.nixosModules.kernel =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.custom.kernel;
      variants = {
        hardened = pkgs.cachyosKernels.linuxPackages-cachyos-hardened;
        lts = pkgs.cachyosKernels.linuxPackages-cachyos-lts;
        latest = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
        nixpkgs = pkgs.linuxPackages;
      };
    in
    {
      options.custom.kernel = {
        variant = lib.mkOption {
          type = lib.types.enum [
            "hardened"
            "lts"
            "latest"
            "nixpkgs"
          ];
          default = "hardened";
          description = "Which kernel to boot.";
        };
        allowUserns = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Allow unprivileged user namespaces on the hardened kernel
            (needed by rootless podman, flatpak, browser sandboxes).
          '';
        };
      };

      config = {
        # "pinned" = exact kernel versions that the binary cache has built
        nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];

        boot.kernelPackages = lib.mkDefault variants.${cfg.variant};

        nix.settings = {
          extra-substituters = [ "https://attic.xuyh0120.win/lantian" ];
          extra-trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
        };

        boot.kernel.sysctl = lib.mkIf (cfg.variant == "hardened" && cfg.allowUserns) {
          "kernel.unprivileged_userns_clone" = 1;
        };
      };
    };

  # Modules for k3s / ceph nodes (was in base.nix's kernelModules list)
  flake.nixosModules.kernel-modules-cluster =
    { ... }:
    {
      boot.kernelModules = [
        "ceph"
        "rbd"
        "xfs"
        "overlay"
        "fuse"
        "nf_tables"
        "vxlan"
        "ip_tables"
        "ip6_tables"
        "br_netfilter"
      ];
    };
}
