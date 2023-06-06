{
  inputs = {
    std.url = "github:divnix/std"; # keep minor version in lockstep with GH std-action
    # std.inputs.nixpkgs.follows = "nixpkgs";
    std.inputs.n2c.follows = "n2c";
    haumea.url = "github:nix-community/haumea/v0.2.2";
    n2c.url = "github:nlewo/nix2container";
    n2c.inputs.nixpkgs.follows = "std/nixpkgs";
  };

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = {std, ...} @ inputs:
    std.growOn {
      inherit inputs;
      cellsFrom = ./ops;
      cellBlocks = with std.blockTypes; [
        # Software Delivery Lifecycle (Packaging Layers)
        # For deeper context, please consult:
        #   https://std.divnix.com/patterns/four-packaging-layers.html
        (installables "packages" {ci.build = true;})
        (runnables "operables")
        (containers "oci-images" {ci.publish = true;})
      ];
    };
}
