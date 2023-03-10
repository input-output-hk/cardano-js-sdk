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
$ ts-node ./src/scripts/mnemonic.ts

  Mnemonic:   toward bridge spell endless tunnel there deputy market scheme ketchup heavy fall fault pudding split desert swear maximum orchard estate match good decorate tribe

  Address:    addr_test1qzdutxe3exf3vls6cymrs7r28dh8uuvk9gpj0w474zysxpx09lufhes0cfv0p2wkl7lg9g0zh6rfd5plk7d32qztf63qyk5mz5

Done in 5.44s.
```

To add funds to your newly created wallet, copy the address displayed in the console and go to [Public Testnet Faucet](https://testnets.cardano.org/en/testnets/cardano/tools/faucet/). You can request 1000 tADA every 24h.

> :information_source: tADA is a limited resource, so if you are no longer using the address, return the tADA to the faucet for others to use.

## Local Test Network

<a name="local_test_network"></a>

Some end-to-end tests can be run using the local test network, this network can be started as follows:

```bash
$ yarn workspace @cardano-sdk/e2e local-network:up
```

:warning: Note that once you finish running the test, you should stop the environment with:

```bash
$ yarn workspace @cardano-sdk/e2e local-network:down
```

Instead of CTRL-C, since some resources need to be clear before you can set up the environment again, if you don't stop the containers with the proper command, you may run into issues restarting it.

There are two ways of obtaining tADA on this network, first we have the faucet:

```javascript
let faucetProvider = await faucetProviderFactory.create(
  env.FAUCET_PROVIDER,
  env.FAUCET_PROVIDER_PARAMS,
  getLogger(env.LOGGER_MIN_SEVERITY)
);

await faucetProvider.request(address, amountFromFaucet, blockConfirmations);
```

The faucet allows you to request an arbitrary amount of tADA to a given address. The faucet will make sure the transaction is in a block before returning, which means you can access the funds immediately after.

The second way is via a set of fixed wallets that are created when the network bootstraps, these wallets contain 5 million tADA each, and you can use them directly if you find the use of the faucet not convenient:

```
Mnemonic:   vacant violin soft weird deliver render brief always monitor general maid smart jelly core drastic erode echo there clump dizzy card filter option defense

Address:    addr_test1qpw0djgj0x59ngrjvqthn7enhvruxnsavsw5th63la3mjel3tkc974sr23jmlzgq5zda4gtv8k9cy38756r9y3qgmkqqjz6aa7
```

```
Mnemonic:   slab gorilla reflect display cage aim silver add own arrange crew start female bitter menu inner combine exit swallow bamboo midnight wealth culture picnic

Address:    addr_test1qrml5hwl9s7ydm2djyup95ud6s74skkl4zzf8zk657s8thgm78sn3uhch64ujc7ffnpga68dfdqhg3sp7tk6759jrm7spy03k9
```

```
Mnemonic:   decorate survey empower stairs pledge humble social leisure baby wrap grief exact monster rug dash kiss perfect select science light frame play swallow day

Address:    addr_test1qrxhyr2flena4ams5pcx26n0yj4ttpmjq2tmuesu4waw8n0qkvxuy9e4kdpz0s7r67jr8pjl9q6ezm2jgg247y9q3zpqxga37s
```

```
Mnemonic:   phrase raw learn suspect inmate powder combine apology regular hero gain chronic fruit ritual short screen goddess odor keen creek brand today kit machine

Address:    addr_test1qpv5muwgjmmtqh2ta0kq9pmz0nurg9kmw7dryueqt57mncynjnzmk67fvy2unhzydrgzp2v6hl625t0d4qd5h3nxt04qu0ww7k
```

```
Mnemonic:   salon zoo engage submit smile frost later decide wing sight chaos renew lizard rely canal coral scene hobby scare step bus leaf tobacco slice

Address:    addr_test1qr0c3frkem9cqn5f73dnvqpena27k2fgqew6wct9eaka03agfwkvzr0zyq7nqvcj24zehrshx63zzdxv24x3a4tcnfeq9zwmn7
```

You can configure any of these five wallets in your test and use any amount of tADA you need.

### Local Test Network - development version

In addition to the **local-network** npm script there is a script suitable for development, which mounts the `packages` directory in
the service containers. It helps to apply changes to the components without shutting down the **local-network** each time.

It can be started with:

```bash
$ yarn workspace @cardano-sdk/e2e local-network:dev
```

and a good idea is to run following command before starting it.

```bash
$ yarn cleanup && yarn && yarn build
```

Restart the provider-server:

```bash
$ docker exec -it local-network-e2e-provider-server-1 kill 1
```

So, if while working on the `core` and `cardano-services` packages simultaneously, we need to restart the provider-server
to check the effect of our ongoing changes, it is enough to issue the following command:

```bash
$ yarn workspace @cardano-sdk/core build && yarn workspace @cardano-sdk/cardano-services build && docker exec -it local-network-e2e-provider-server-1 kill 1
```

if it exits with error we need to fix our ongoing changes, if it exits silently, the provider-server is now running with our changes.

## Local file server

The end-to-end environment runs a Nginx instance that allows us to serve files directly to the local-network.

Any file added to the `file-server` folder will be served to the docker cluster via `http://file-server/`, for example, `http://file-server/SP1.json`. The contents of this folder can be altered dynamically, and the files will be available instantly to the docker images (no need to restart the container).

It is also possible to access the file server from outside the docker cluster as the instance binds to port `7890` on the host by default:

`http://localhost:7890/SP1.json`

You can override this port mapping by setting the `FILE_SERVER_PORT` environment variable when starting to containers:

`FILE_SERVER_PORT=9874 docker compose -p local-network-e2e up`

## Local Network

The end-to-end local network test are meant to showcase the use of the local test network. The local network end-to-end test shows how we can fund wallets with local test network tADA so we can run the end-to-end tests. For the local network end-to-end test to run, we must first start our local test network environment (see [here](#local_test_network)).

For the local network tests to work correctly, we must configure it with the mnemonic of the genesis wallet. This wallet controls almost all the funds on the local test network and is the one of the ways of obtaining tADA on that network.

```
# Logger
LOGGER_MIN_SEVERITY=info

# Providers setup
FAUCET_PROVIDER=cardano-wallet
FAUCET_PROVIDER_PARAMS='{"baseUrl":"http://localhost:8090/v2","mnemonic":"fire method repair aware foot tray accuse brother popular olive find account sick rocket next"}'
KEY_MANAGEMENT_PROVIDER=inMemory
KEY_MANAGEMENT_PARAMS='{"accountIndex": 0, "chainId":{"networkId": 0, "networkMagic": 888}, "passphrase":"some_passphrase","mnemonic":""}'
ASSET_PROVIDER=http
ASSET_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/asset"}'
CHAIN_HISTORY_PROVIDER=http
CHAIN_HISTORY_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/chain-history"}'
NETWORK_INFO_PROVIDER=http
NETWORK_INFO_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/network-info"}'
REWARDS_PROVIDER=http
REWARDS_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/rewards"}'
TX_SUBMIT_PROVIDER=http
TX_SUBMIT_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/tx-submit"}'
UTXO_PROVIDER=http
UTXO_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/utxo"}'
STAKE_POOL_PROVIDER=stub
STAKE_POOL_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/stake-pool"}'
```

> :information_source: Notice that KEY_MANAGEMENT_PARAMS _mnemonic_ property is empty, if you leave this empty on the **local network's** e2e tests a new set of random mnemonics will be generated for you, this is the recommended way of setting up e2e tests on this network.

Then to run the local network tests, run:

```bash
$ yarn workspace @cardano-sdk/e2e test:local-network
```

## RabbitMQ Load Testing

**RabbitMQ** end to end load tests. Please note that this requires an _Ogmios_ server for submitting the txs.
The default configuration matches the **local-network** host mapping (just leaving the `.env` file untouched)
or we can configure the test to run against another system.

```
# Required by test:load-testing
OGMIOS_URL=ws://localhost:1340
TX_SUBMIT_HTTP_URL=http://localhost:3456/tx-submit
TRANSACTIONS_NUMBER=10
START_LOCAL_HTTP_SERVER=true
WORKER_PARALLEL_TRANSACTION=3
```

> :information_source: Ensure the configured wallet has sufficient funds for the test transactions (see [here](#generate_wallet)).

Before executing the test, start the _local-network_:

```bash
$ yarn workspace @cardano-sdk/e2e test:local-network
```

To execute the test:

```bash
$ yarn workspace @cardano-sdk/e2e test:load-testing
```

## Wallet

The wallet end-to-end tests showcase the use of different providers to create, sign, send and keep track of transactions on the blockchain, query assets and their metadata, delegate to pools and keep track of rewards (among others):

Since the wallet test interacts with most of the providers, you need to make sure to provide the proper values for all the environment variables that configure said providers, for example:

```
# Logger
LOGGER_MIN_SEVERITY=debug

# Providers setup
KEY_MANAGEMENT_PROVIDER=inMemory
KEY_MANAGEMENT_PARAMS='{"accountIndex": 0, "chainId":{"networkId": 0, "networkMagic": 888}, "passphrase":"some_passphrase","mnemonic":"vacant violin soft weird deliver render brief always monitor general maid smart jelly core drastic erode echo there clump dizzy card filter option defense"}'
ASSET_PROVIDER=http
ASSET_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/asset"}'
CHAIN_HISTORY_PROVIDER=http
CHAIN_HISTORY_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/chain-history"}'
NETWORK_INFO_PROVIDER=http
NETWORK_INFO_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/network-info"}'
REWARDS_PROVIDER=http
REWARDS_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/rewards"}'
TX_SUBMIT_PROVIDER=http
TX_SUBMIT_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/tx-submit"}'
UTXO_PROVIDER=http
UTXO_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/utxo"}'
STAKE_POOL_PROVIDER=http
STAKE_POOL_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/stake-pool"}'

```

> :information_source: Remember to use a wallet with enough funds to carry out transactions (see [here](#generate_wallet)).

Then to run the wallet tests, run:

```bash
$ yarn workspace @cardano-sdk/e2e test:wallet
```

## Web Extensions

The web-extension end-to-end tests are slightly different from the rest as they emulate user interaction with a browser instance. There is only one key difference between running the web-extension end-to-end tests and the rest, and that is the location of the .env file; for the web-extension end-to-end tests, the .env file must be located within the packages/e2e/web-extension directory, this is an example of the environment file you need to run the tests:

```
# Logger
LOGGER_MIN_SEVERITY=debug

# Providers setup
ASSET_PROVIDER=http
ASSET_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/asset"}'
CHAIN_HISTORY_PROVIDER=http
CHAIN_HISTORY_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/chain-history"}'
NETWORK_INFO_PROVIDER=http
NETWORK_INFO_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/network-info"}'
REWARDS_PROVIDER=http
REWARDS_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/rewards"}'
TX_SUBMIT_PROVIDER=http
TX_SUBMIT_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/tx-submit"}'
UTXO_PROVIDER=http
UTXO_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/utxo"}'
STAKE_POOL_PROVIDER=stub
STAKE_POOL_PROVIDER_PARAMS='{"baseUrl":"http://localhost:4000/stake-pool"}'

# Test Environment
NETWORK_ID=0
MNEMONIC_WORDS="vacant violin soft weird deliver render brief always monitor general maid smart jelly core drastic erode echo there clump dizzy card filter option defense"
```

Then to run the web-extension tests run:

```bash
$ yarn workspace @cardano-sdk/e2e test:web-extension
```

## Artillery

**Artillery stress tests** are not exactly _e2e tests_ in the meaning of _jest tests_; the SDK is run through artillery.
They are not aimed to check if specific functionalities work or not, but to stress test APIs.

Currently a few artillery load test scenarios are implemented.
The main purpose is to simulate expected load against provider endpoints or wallet initialization/restoration.

**The Artillery tests** are currently configured to run only with 1 worker.
With plan to design and introduce our custom Distributed load test solution in post MVP stage.

To run stake pool search scenario against the local-network endpoint:

```bash
$ STAKE_POOL_PROVIDER_URL="http://localhost:4000/stake-pool" yarn artillery:stake-pool-query
```

To run wallet restoration scenario against the local-network endpoint:

```bash
$ ARRIVAL_PHASE_DURATION_IN_SECS={duration of how long virtual users will be generated} VIRTUAL_USERS_COUNT={wallets count to restore} yarn artillery:wallet-restoration
```
