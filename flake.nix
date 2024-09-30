{
  description = "Cardano JS SDK";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    devshell.url = "github:numtide/devshell";

    n2c.url = "github:nlewo/nix2container";
    n2c.inputs.nixpkgs.follows = "nixpkgs";

    nix-toolbox.url = "github:DevPalace/nix-toolbox/";
    #nix-toolbox.inputs.nixpkgs.follows = "nixpkgs";
    nix-toolbox.inputs.flake-parts.follows = "flake-parts";
    nix-toolbox.inputs.nix2container.follows = "";


    std = {
      url = "github:divnix/std";
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
    allow-import-from-derivation = "true";
  };
  # --------------------------------------------------------------

  outputs = {
    std,
    self,
    nix-toolbox,
    devshell,
    ...
  } @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        std.flakeModule
        devshell.flakeModule
        ./nix/local/envs.nix
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

      std.grow = with inputs; {
        cellsFrom = ./nix;
        cellBlocks = with std.blockTypes; [
          # Software Delivery Lifecycle (Local Development Environment)
          (runnables "jobs")
          # Software Delivery Lifecycle (Packaging Layers)
          # For deeper context, please consult:
          #   https://std.divnix.com/patterns/four-packaging-layers.html
          (installables "packages" {ci.build = true;})
          (runnables "operables")
          (containers "oci-images" {ci.publish = true;})
        ];
      };

      std.harvest = {
        packages = [["local" "packages"] ["local" "jobs"]];
        devShells = [["local" "envs"] ["desktop" "envs"]];
        hydraJobs = ["desktop" "hydraJobs"];
      };

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        legacyPackages.cardano-services = import ./nix/cardano-services/deployments {inherit pkgs nix-toolbox inputs;};
      };
    };
}
