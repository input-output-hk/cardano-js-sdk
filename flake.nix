{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = inputs: let
    nixpkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    inherit (nixpkgs) lib;
  in rec {
    packages.x86_64-linux = nixpkgs.yarn2nix-moretea.mkYarnWorkspace {
      src = ./.;
    };
    checks.x86_64-linux = lib.filterAttrs (k: v: lib.hasPrefix "@cardano-sdk/" k) packages.x86_64-linux;
    devShells.x86_64-linux.default = nixpkgs.mkShell {
      nativeBuildInputs = [
        nixpkgs.nodejs-16_x.pkgs.yarn
        nixpkgs.nodejs-16_x
      ];
    };
  };
}
