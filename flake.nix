{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: {
    packages = nixpkgs.lib.mapAttrs (system: pkgs: {
      default = pkgs.callPackage ./yarn-project.nix { } { src = ./.; };
    }) nixpkgs.legacyPackages;
  };
}
