**Current node version: 1.34.1**

Run a local test network, within a Docker container or natively on the host.

## How it works

- 3 nodes are run in the parent process to bootstrap the network. They could also be run in separate processes, containers, or hosts to be more realistic.
- The config is similar to _mainnet_, with exceptions to fit an automated testing environment.
- The `Test...HardFork` parameters in `config.json` expedite the protocol upgrade to the latest era within a single epoch, rather than using protocol upgrade proposals.
- Once the network is ready, `mint-tokens.sh` will mint test tokens owned by the genesis address. You can modify this script to change the inital token distribution. The genesis keys are located in `shelley/utxo-keys`.

## How to run

### With Docker

**Note:** We will mount the node sockets in `sockets` directory, however these sockets don't work with Docker for Mac. If you're using MacOS, you need to `docker exec` into node container to use `cardano-cli`. Please note that `cardano-node` and `cardano-cli` behave **quite differently** in MacOS, so you might want to run them in Docker or Linux to be close to production environment.

1. Run `docker-compose up` to start a new local test network in Docker.
2. Run `./scripts/install.sh` to install `cardano-cli`.
3. Run `export CARDANO_NODE_SOCKET_PATH=$PWD/sockets/node-pool1.sock` for `cardano-cli` to work.
4. (Optional) Run `export PATH=$PATH:$PWD/bin` so you can use `cardano-cli` instead of `./bin/cardano-cli`.
5. Check the network: `./bin/cardano-cli query tip --testnet-magic 888`

### Native

Supported OS:

- Linux
- MacOS

1. Run `./scripts/install.sh` to install necessary binaries.
2. Run `./scripts/reset.sh` to run a new private testnet.
3. Run `export CARDANO_NODE_SOCKET_PATH=$PWD/sockets/node-pool1.sock` for `cardano-cli` to work.
4. (Optional) Run `export PATH=$PATH:$PWD/bin` so you can use `cardano-cli` instead of `./bin/cardano-cli`.
5. Check the network: `./bin/cardano-cli query tip --testnet-magic 888`

## How this repo was created

1. `cardano-node` git repository was cloned, with the intended version checked out.
2. `./scripts/byron-to-alonzo/mkfiles.sh alonzo` run.
3. Config files were modified to suit the use case.

## Notable options

1. `shelley/genesis.json`

- `maxTxSize`: Maximum transaction size (default 16kB).
- `initialFunds`: How initial ADA is distributed.

2. `alonzo/genesis.json`

- `maxTxExUnits`: Maximum ExUnits per transaction.
- `maxBlockExUnits`: Maximum ExUnits per block.
