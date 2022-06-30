# End-to-end tests for Cardano JS SDK

Directories under `./test` group test suites to demonstrate the SDK for specific application use cases.

For this to work, we first install dependencies and build the sdk from the root via:

```bash
$ yarn cleanup
$ yarn install
$ yarn build
```

To test the different use cases, you can run the e2e tests as follows:

```bash
$ yarn workspace @cardano-sdk/e2e test:wallet
```

This command will run all the e2e tests related to the wallet component.

## Configuring the Environment

The providers used during the e2e test can be configured via environment variables or by creating a file '.env'; there is an example of such file in '.env.example'.

If you are using _testnet_ or _mainnet_ as your test environment, ensure that the wallets you are configuring via environment variables contain some funds.

<a name="generate_wallet"></a>
If you need to create a new wallet via a new set of mnemonics, you can run:

```bash
$ yarn workspace @cardano-sdk/e2e generate-mnemonics
```

And you will get the set of mnemonics plus the first derivative address on the console:

```bash
$ ts-node ./src/Util/mnemonic.ts

  Mnemonic:   toward bridge spell endless tunnel there deputy market scheme ketchup heavy fall fault pudding split desert swear maximum orchard estate match good decorate tribe 

  Address:    addr_test1qzdutxe3exf3vls6cymrs7r28dh8uuvk9gpj0w474zysxpx09lufhes0cfv0p2wkl7lg9g0zh6rfd5plk7d32qztf63qyk5mz5

Done in 5.44s.
```
To add funds to your newly created wallet, copy the address displayed in the console and go to [Public Testnet Faucet](https://testnets.cardano.org/en/testnets/cardano/tools/faucet/). You can request 1000 tADA every 24h.

> :information_source: tADA is a limited resource, so if you are no longer using the address, return the tADA to the faucet for others to use.

## Blockfrost

To run the Blockfrost end-to-end tests you only need to configure two providers, AssetProvider and ChainHistoryProvider, both must be configured as Blockfrost providers and a valid Blockfrost API key must be also set, make sure that in your .env file, you have the environment variables set:

```
# Blockfrost secrets
BLOCKFROST_API_KEY=testnetSOMEAPIKEY

# Providers setup
ASSET_PROVIDER=blockfrost
CHAIN_HISTORY_PROVIDER=blockfrost
```

> :information_source: Remember to get your Blockfrost API key at [blockfrost.io](https://blockfrost.io/) and set it in the configuration file, the API key displayed here is invalid and for demonstration purposes only.

Then to run the blockforst test run:

```bash
$ yarn workspace @cardano-sdk/e2e test:blockfrost
```

## Cardano Services

Cardano services end to end test perform load testing. Please note that you must have several services up before executing the test, to start the environment(from the root):

```bash
$ cd packages/cardano-services
$ yarn testnet:up
```

Once your environment is synced up, in a different terminal you can proceed to run the test, this is an example of the configuration you may need:

```
# Logger
LOGGER_MIN_SEVERITY=debug

# Blockfrost secrets
BLOCKFROST_API_KEY=testnetSOMEAPIKEY

# Providers setup
KEY_MANAGEMENT_PROVIDER=inMemory
KEY_MANAGEMENT_PARAMS='{"accountIndex": 0, "networkId": 0, "password":"some_password","mnemonic":"run yarn workspace @cardano-sdk/e2e generate-mnemonics to generate your own"}'
ASSET_PROVIDER=blockfrost
CHAIN_HISTORY_PROVIDER=blockfrost
NETWORK_INFO_PROVIDER=blockfrost
REWARDS_PROVIDER=blockfrost
TX_SUBMIT_PROVIDER=http
TX_SUBMIT_PROVIDER_PARAMS='{"url": "http://localhost:3456/tx-submit"}'
UTXO_PROVIDER=blockfrost
WALLET_PROVIDER=blockfrost
STAKE_POOL_PROVIDER=stub

# Test Parameters
OGMIOS_URL=ws://localhost:1338
TX_SUBMIT_HTTP_URL=http://localhost:3456/tx-submit
RABBITMQ_URL=amqp://localhost
TRANSACTIONS_NUMBER=10
START_LOCAL_HTTP_SERVER=true
WORKER_PARALLEL_TRANSACTION=3
```
> :information_source: Remember to get your Blockfrost API key at [blockfrost.io](https://blockfrost.io/) and set it in the configuration file, the API key displayed here is invalid and for demonstration purposes only.

> :information_source: Remember to use a wallet with enough funds to carry out transactions (see [here](#generate_wallet)).

To execute the test:

```bash
$ yarn workspace @cardano-sdk/e2e test:cardano-services
```

## Local Network Faucet

The end-to-end faucet test are meant to showcase the use of the private testnet. The faucet end-to-end test shows how we can fund wallets with private testnet tADA so we can run the end-to-end tests. For the faucet end-to-end test to run, we must first start our private testnet environment as follows:

```bash
$ yarn workspace @cardano-sdk/e2e private-network:up
```

:warning: Note that once you finish running the test, you should stop the enviroment with:

```bash
$ yarn workspace @cardano-sdk/e2e private-network:down
```
Instead of CTRL-C, since some resources need to be clear before you can set up the environment again, if you don't stop the containers with the proper command, you may run into issues restarting it.

For the faucet to work correctly, we must configure it with the mnemonic of the genesis wallet. This wallet controls all the funds on the private testnet and is the only way of obtaining tADA on that network.

```
# Logger
LOGGER_MIN_SEVERITY=debug

# Providers setup
KEY_MANAGEMENT_PROVIDER=inMemory
KEY_MANAGEMENT_PARAMS='{"accountIndex": 0, "networkId": 0, "password":"some_password","mnemonic":"run yarn workspace @cardano-sdk/e2e generate-mnemonics to generate your own"}'
FAUCET_PROVIDER=cardano-wallet
FAUCET_PROVIDER_PARAMS='{"url":"http://localhost:8090/v2","mnemonic":"fire method repair aware foot tray accuse brother popular olive find account sick rocket next"}'
```

Then to run the faucet tests, run:

```bash
$ yarn workspace @cardano-sdk/e2e test:faucet
```

## Wallet

The wallet end-to-end tests showcase the use of different providers to create, sign, send and keep track of transactions on the blockchain, query assets and their metadata, delegate to pools and keep track of rewards (among others):

Since the wallet test interacts with most of the providers, you need to make sure to provide the proper values for all the environment variables that configure said providers, for example:

```
# Logger
LOGGER_MIN_SEVERITY=debug

# Blockfrost secrets
BLOCKFROST_API_KEY=testnetSOMEAPIKEY

# Providers setup
KEY_MANAGEMENT_PROVIDER=inMemory
KEY_MANAGEMENT_PARAMS='{"accountIndex": 0, "networkId": 0, "password":"some_password","mnemonic":"run yarn workspace @cardano-sdk/e2e generate-mnemonics to generate your own"}'
ASSET_PROVIDER=blockfrost
CHAIN_HISTORY_PROVIDER=blockfrost
NETWORK_INFO_PROVIDER=blockfrost
REWARDS_PROVIDER=blockfrost
TX_SUBMIT_PROVIDER=blockfrost
UTXO_PROVIDER=blockfrost
WALLET_PROVIDER=blockfrost
STAKE_POOL_PROVIDER=stub

# Test Params
POOL_ID_1=pool1euf2nh92ehqfw7rpd4s9qgq34z8dg4pvfqhjmhggmzk95gcd402
POOL_ID_2=pool1fghrkl620rl3g54ezv56weeuwlyce2tdannm2hphs62syf3vyyh
```
> :information_source: Remember to get your Blockfrost API key at [blockfrost.io](https://blockfrost.io/) and set it in the configuration file, the API key displayed here is invalid and for demonstration purposes only.

> :information_source: Remember to use a wallet with enough funds to carry out transactions (see [here](#generate_wallet)).

Then to run the wallet tests, run:

```bash
$ yarn workspace @cardano-sdk/e2e test:wallet
```

## Web Extensions

The web-extension end-to-end tests are slightly different from the rest as they emulate user interaction with a browser instance. There is only one key difference between running the web-extension end-to-end tests and the rest, and that is the location of the .env file; for the web-extension end-to-end tests, the .env file must be located within the packages/e2e/web-extension directory, this is an example of the environment file you need to run the tests:

```
TX_SUBMIT_PROVIDER=blockfrost
TX_SUBMIT_HTTP_URL=http://localhost:3000
ASSET_PROVIDER=blockfrost
UTXO_PROVIDER=blockfrost
REWARDS_PROVIDER=blockfrost
STAKE_POOL_PROVIDER=stub
NETWORK_INFO_PROVIDER=blockfrost
CHAIN_HISTORY_PROVIDER=blockfrost
BLOCKFROST_API_KEY=testnetSOMEAPIKEY
NETWORK_ID=0
MNEMONIC_WORDS="vacant invite slender salute undo drink above scatter item silver hold route repeat patch paper"
WALLET_PASSWORD=some_password
POOL_ID_1=pool1euf2nh92ehqfw7rpd4s9qgq34z8dg4pvfqhjmhggmzk95gcd402
POOL_ID_2=pool1fghrkl620rl3g54ezv56weeuwlyce2tdannm2hphs62syf3vyyh
OGMIOS_URL=ws://localhost:1337
LOGGER_MIN_SEVERITY=debug
KEY_AGENT=InMemory
```
> :information_source: Remember to get your Blockfrost API key at [blockfrost.io](https://blockfrost.io/) and set it in the configuration file, the API key displayed here is invalid and for demonstration purposes only.

Then to run the web-extension tests run:

```bash
$ yarn workspace @cardano-sdk/e2e test:web-extension
```