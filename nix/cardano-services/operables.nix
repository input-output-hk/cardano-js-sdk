let
  inherit (inputs) std;
  inherit (inputs.nixpkgs) lib;
  /*
  Available networks at the time of writing:

  $ ls packages/cardano-services/config/network/
  mainnet  preprod  preprod_p2p  preview  preview_p2p  testnet  vasil-dev  vasil-dev_p2p  vasil-qa
  */
  cardanoServicesPath = pkg: "${pkg}/libexec/incl/packages/cardano-services";
  runCardanoServices = pkg: "${lib.getExe pkg.nodejs} \${NODE_EXTRA_OPTIONS:-} ${cardanoServicesPath pkg}";
in {
  cardano-services = std.lib.ops.mkOperable rec {
    package = cell.packages.cardano-services;
    runtimeScript = ''
      export API_URL=''${API_URL:-http://0.0.0.0:3000}
      export CLI="${runCardanoServices package}/dist/cjs/cli.js"
      export CARDANO_NODE_CONFIGS_DIR="${cardanoServicesPath package}/config/network"

      if [ -n "$NETWORK" ]; then
        if [ "$NETWORK" = "local" ]; then
          export CARDANO_NODE_CONFIG_PATH="/config/network/cardano-node/config.json"
        else
          export CARDANO_NODE_CONFIG_PATH="$CARDANO_NODE_CONFIGS_DIR/''${NETWORK}/cardano-node/config.json"
        fi
      fi

      exec $CLI "$@"
    '';
    meta.description = "A transparent (thin) wrapper around the Cardano Services CLI";
  };
}
