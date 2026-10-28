{
  nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    home-manager.url = "github:nix-community/home-manager";
    disko.url = "github:nix-community/disko";
    # fenix.url = "github:nix-community/fenix/monthly";
    # vulnix.url = "github:nix-community/vulnix";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    # NUR.url = "github:nix-community/NUR";
    # nix-mineral.url = "github:nix-community/nix-mineral";
    # stylix.url = "github:nix-community/stylix";
    lanzaboote.url = "github:nix-community/lanzaboote";
    nix-ld.url = "github:Mic92/nix-ld";

    # Pi hosts. No `follows`: it brings its own nixpkgs and kernel.
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    # cachyos hardened kernel
    # nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
