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

  # outputs = inputs: import ./outputs.nix inputs;
  outputs = {
    std,
    self,
    nix-helm,
    ...
  } @ inputs:
  inputs.flake-parts.lib.mkFlake {inherit inputs;} {
    imports = with inputs; [
      std.flakeModule
      devshell.flakeModule
    ];
    systems = ["x86_64-linux" "aarch64-linux"];
  
    std.grow = {
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
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
  
      legacyPackages.cardano-services = import ./nix/cardano-services/deployments {inherit pkgs nix-helm inputs;};
  
      devshells = import ./nix/local/envs.nix pkgs;
    };
  };
}
