let
  inherit (inputs) std;
  inherit (inputs.nixpkgs) lib yarn;
  /*
  Available networks at the time of writing:

  $ ls packages/cardano-services/config/network/
  mainnet  preprod  preprod_p2p  preview  preview_p2p  testnet  vasil-dev  vasil-dev_p2p  vasil-qa
  */
  cardanoServicesPath = pkg: "${pkg}/libexec/incl/packages/cardano-services";
  runCardanoServices = pkg: "${lib.getExe pkg.nodejs} ${cardanoServicesPath pkg}";
in {
  cardano-services = std.lib.ops.mkOperable rec {
    package = cell.packages.cardano-services;
    runtimeScript = ''
      export API_URL=''${API_URL:-http://0.0.0.0:3000}
      export CLI="${runCardanoServices package}/dist/cjs/cli.js"
      export CARDANO_NODE_CONFIGS_DIR="${cardanoServicesPath package}/config/network"

      if [ -n "$NETWORK" ]; then
        export CARDANO_NODE_CONFIG_PATH="$CARDANO_NODE_CONFIGS_DIR/''${NETWORK}/cardano-node/config.json"
      fi

      exec $CLI "$@"
    '';
    meta.description = "A transparent (thin) wrapper around the Cardano Services CLI";
  };

  e2e = std.lib.ops.mkOperable rec {
    package = cell.packages.cardano-services;
    runtimeScript = ''
      cd ${cell.packages.e2e}/libexec/incl
      exec ${lib.getExe yarn} workspace @cardano-sdk/e2e test:wallet
    '';
    meta.description = "Cardano Services E2E tests";
  };
}
