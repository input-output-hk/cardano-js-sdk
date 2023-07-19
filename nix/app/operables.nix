let
  inherit (inputs) std;
  inherit (inputs.nixpkgs) lib;
  /*
  Available networks at the time of writing:

  $ ls packages/cardano-services/config/network/
  mainnet  preprod  preprod_p2p  preview  preview_p2p  testnet  vasil-dev  vasil-dev_p2p  vasil-qa
  */
  networkConfig = inputs.self + /packages/cardano-services/config/network;
in {
  server = std.lib.ops.mkOperable {
    package = cell.packages.server;
    # find all configuration options in: packages/cardano-services/src/cli.ts
    runtimeScript = ''
      ${cell.packages.server}/bin/cli --cardano-node-config-path \
        "${networkConfig}/''${NETWORK-mainnet}/cardano-node/config.json"
    '';
    meta.description = "A transparent (thin) wrapper around the Cardano Services CLI";
  };
}
