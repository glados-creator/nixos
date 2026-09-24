{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/08eff661f245e0b315bc338e2e236cfe8864c3e0";

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
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
