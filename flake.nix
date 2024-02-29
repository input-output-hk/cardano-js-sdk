{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    devshell.url = "github:numtide/devshell";

    n2c.url = "github:nlewo/nix2container";
    n2c.inputs.nixpkgs.follows = "nixpkgs";

    std = {
      url = "github:divnix/std";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.n2c.follows = "n2c";
      inputs.devshell.follows = "devshell";
    };
  };

  outputs = {std, ...} @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = with inputs; [
        std.flakeModule
        devshell.flakeModule
      ];
      systems = ["x86_64-linux"];

      std.grow = {
        cellsFrom = ./nix;
        cellBlocks = with std.blockTypes; [
          # Software Delivery Lifecycle (Local Development Environment)
          (devshells "envs")
          (runnables "jobs")
          # Software Delivery Lifecycle (Packaging Layers)
          # For deeper context, please consult:
          #   https://std.divnix.com/patterns/four-packaging-layers.html
          (installables "packages" {ci.build = true;})
          (runnables "operables")
          (containers "oci-images" {ci.publish = true;})
          (kubectl "deployments" {
            ci.diff = true;
            ci.apply = true;
          })
        ];
      };
    };
}
