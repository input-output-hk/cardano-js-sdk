let
  inherit (inputs) std;
  inherit (inputs.nixpkgs) lib;
  # TODO: understand if CARDANO_NODE_CONFIG_PATH has appropriate defaults (depending on network)
  # see also epic about organizing defaults in a single place
in {
  server = std.lib.ops.mkOperable {
    package = cell.packages.server;
    runtimeScript = "${cell.packages.server}/bin/cli";
    meta.description = "A transparent (thin) wrapper around the Cardano Services CLI";
  };
}
