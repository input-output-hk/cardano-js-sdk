# End to end tests for Cardano JS SDK

This directory contains end-to-end tests for cardano-js-sdk. Each directory under 'test' is a self-contained set of tests for a particular component/use case that exactly mimics how a user might expect the cardano-js-sdk to work, so they allow high-fidelity reproductions of real-world issues.

For this to work, we first install dependencies and build the sdk from the root via:

```bash
$ yarn cleanup
$ yarn install
$ yarn build
```

To test the different use cases, you can run the e2e tests as follow (from the root):

```bash
$ cd packages/e2e
$ yarn test:wallet
```

This will run all the e2e tests related to the wallet component.

## Configuring the Environment

The providers used during the e2e test can be configured via environment variables, or by creating a file '.env', there is an example of such file in '.env.example'.

If you are using testnet or mainnet as your test environment, make sure that the wallets you are configuring via environment variables contain some funds.

If you need to create a new wallet via a brand new set of mnemonics, you can run (from the root):

```bash
$ cd packages/e2e
$ yarn generate-mnemonics
```

And you will get the set of mnemonics on the console:

```bash
$ ts-node ./src/Util/mnemonic.ts

polar thought measure warrior spot lens source school knock legal brave stone repeat item hero dose blade kit reflect assume dream current view farm 

Done in 5.38s.
```

## Running blockfrost end to end tests

To run the blockfrost end to end tests you only need to configure two providers, AssetProvider and ChainHistoryProvider, both must be configured as blockfrost providers and a valid blockfrost API key must be also set, make sure that in your .env file you have the environment variables set:

```
LOGGER_MIN_SEVERITY=debug
BLOCKFROST_API_KEY=testnetNElagmhpQDubE6Ic4XBUVJjV5DROyijO
ASSET_PROVIDER=blockfrost
CHAIN_HISTORY_PROVIDER=blockfrost
```

> :red_circle: Remember to get your own blockfrost API key at https://blockfrost.io/ and set it in the configuration file, the API key displayed here is invalid and for demostration purposes only.

Then to run the blockforst test run (from the root):

```bash
$ cd packages/e2e
$ yarn test:blockfrost
```

## Running cardano-services end to end tests

TBD

## Running faucet end to end tests

The faucet end to end test are meant to showcase the use of the private testnet. The faucet end to end test show how we can fund wallets with out private testnet tAda so we can run the end to end tests. For the faucet end to end test to run we must first start our private testnet environment as follows:

```bash
$ cd packages/e2e
$ yarn private-network:up
```

Note that once you finish running the test, it is advisable that you stop the enviroment with:

```bash
$ cd packages/e2e
$ yarn private-network:down
```
Instead of CTRL-C since there are some resources that need to be clear before the environment can be set up again, if you dont stop the containers with the proper command, you may run into issues restarting it.

For the faucet to work correctly we must configured it with the mnemonic of the genesis wallet, this wallet control all the funds on the private testnet and is the only way of obtaining tADA on that network.

```
FAUCET_PROVIDER=cardano-wallet
FAUCET_PROVIDER_PARAMS='{"url":"http://localhost:8090/v2","mnemonic":"fire method repair aware foot tray accuse brother popular olive find account sick rocket next"}'
```

## Running wallet end to end tests

The faucet 2e2e

## Running web-extension end to end tests

The web-extension end to end tests are a bit different from the rest as they emulate user interaction with a browser instance. There is only one key difference between running the web-extension end to end tests and the rest, and that is the location of the .env file, for the web-extension end to end tests the .env file must be located within the packages/e2e/web-extension directory, this is an example of the environment file you need to run the tests:

```
TX_SUBMIT_PROVIDER=blockfrost
TX_SUBMIT_HTTP_URL=http://localhost:3000
ASSET_PROVIDER=blockfrost
UTXO_PROVIDER=blockfrost
REWARDS_PROVIDER=blockfrost
STAKE_POOL_PROVIDER=stub
NETWORK_INFO_PROVIDER=blockfrost
CHAIN_HISTORY_PROVIDER=blockfrost
BLOCKFROST_API_KEY=testnetNElagmhpQDubE6Ic4XBUVJjV5DROyijO
NETWORK_ID=0
MNEMONIC_WORDS="vacant invite slender salute undo drink above scatter item silver hold route repeat patch paper"
WALLET_PASSWORD=some_password
POOL_ID_1=pool1euf2nh92ehqfw7rpd4s9qgq34z8dg4pvfqhjmhggmzk95gcd402
POOL_ID_2=pool1fghrkl620rl3g54ezv56weeuwlyce2tdannm2hphs62syf3vyyh
OGMIOS_URL=ws://localhost:1337
LOGGER_MIN_SEVERITY=debug
KEY_AGENT=InMemory
```
> :red_circle: Remember to get your own blockfrost API key at https://blockfrost.io/ and set it in the configuration file, the API key displayed here is invalid and for demostration purposes only.

Then to run the blockforst test run (from the root):

```bash
$ cd packages/e2e
$ yarn test:web-extension
```
