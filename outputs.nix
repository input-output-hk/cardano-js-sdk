{
  std,
  self,
  nix-helm,
  ...
} @ inputs:
inputs.flake-parts.lib.mkFlake {inherit inputs;} {
  imports = with inputs; [
    std.flakeModule
    devshell.flakeModule
    ./nix/local/envs.nix
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
  };
}
