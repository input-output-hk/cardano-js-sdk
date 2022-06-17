**Current node version: 1.34.1**

Run an Alonzo private testnet, with or without Docker.

## How it works

- We run 3 nodes to facilitate protocol bootstrapping. They are run in the same parent process for scripting simplicity. Of course you can run them in 3 different processes/containers/hosts to make it more realistic.
- The configs mimic official mainnet configs.
- The `Test...HardFork` parameters in `config.json` help us fork directly to Alonzo era right from the start.
- Once the nodes are ready, `mint-tokens.sh` will run automatically and mint some test tokens to the genesis address. You can modify this script to mint more tokens or distribute to other addresses. The genesis keys are located in `shelley/utxo-keys`.

## How to run

### With Docker

**Note:** We will mount the node sockets in `sockets` directory, however these sockets don't work with Docker for Mac. If you're using MacOS, you need to `docker exec` into node container to use `cardano-cli`. Please note that `cardano-node` and `cardano-cli` behave **quite differently** in MacOS, so you might want to run them in Docker or Linux to be close to production environment.

1. Run `docker-compose up` to start a new private testnet in Docker.
2. Run `./scripts/install.sh` to install `cardano-cli`.
3. Run `export CARDANO_NODE_SOCKET_PATH=$PWD/sockets/node-pool1.sock` for `cardano-cli` to work.
4. (Optional) Run `export PATH=$PATH:$PWD/bin` so you can use `cardano-cli` instead of `./bin/cardano-cli`.
5. Check the network: `./bin/cardano-cli query tip --testnet-magic 42`

### Without Docker

Supported OS:

- Linux
- MacOS

1. Run `./scripts/install.sh` to install necessary binaries.
2. Run `./scripts/reset.sh` to run a new private testnet.
3. Run `export CARDANO_NODE_SOCKET_PATH=$PWD/sockets/node-pool1.sock` for `cardano-cli` to work.
4. (Optional) Run `export PATH=$PATH:$PWD/bin` so you can use `cardano-cli` instead of `./bin/cardano-cli`.
5. Check the network: `./bin/cardano-cli query tip --testnet-magic 42`

## How this repo is created

1. Clone `cardano-node`, check-out to the version we're interested in.
2. Run `./scripts/byron-to-alonzo/mkfiles.sh alonzo`.
3. Modify configs files according to official mainnet configs or personal preferences.

## Important configs for DApp developers

1. `shelley/genesis.json`

- `maxTxSize`: Maximum transaction size (default 16kB).
- `initialFunds`: How initial ADA is distributed.

2. `alonzo/genesis.json`

- `maxTxExUnits`: Maximum ExUnits per transaction.
- `maxBlockExUnits`: Maximum ExUnits per block.
