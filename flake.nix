{
  description = "Cardano JS SDK";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    n2c.url = "github:nlewo/nix2container";
    n2c.inputs.nixpkgs.follows = "nixpkgs";

    nix-helm.url = "github:gytis-ivaskevicius/nix-helm";
    nix-helm.inputs.nixpkgs.follows = "nixpkgs";

    std = {
      url = "github:divnix/std/v0.24.0-1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.n2c.follows = "n2c";
      inputs.devshell.follows = "devshell";
    };
  };

  # --- Flake Local Nix Configuration ----------------------------
  nixConfig = {
    # still used by single-user-mode (e.g. ci)
    extra-substituters = [
      "https://cache.iog.io"
      "s3://lace-nix-cache?region=us-east-1"
    ];
    extra-trusted-substituters = [
      "https://cache.iog.io"
      "s3://lace-nix-cache?region=us-east-1"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "nixbuild.net/lace@iohk.io-1:sEHlRBG/EcTkef5vJx2LmDPxpe8kln81TQuZyb9TdJY="
      "lace:doMHHeFIW0/T/Gw5y+S6OfhRVC5Imhm28rptgdLRBn4="
    ];
    allow-import-from-derivation = "true";
  };
  # --------------------------------------------------------------


  outputs = inputs: import ./outputs.nix inputs;
}
