# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.5.0-nightly.23](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.22...@cardano-sdk/e2e@0.5.0-nightly.23) (2022-11-01)

**Note:** Version bump only for package @cardano-sdk/e2e

## [0.5.0-nightly.22](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.21...@cardano-sdk/e2e@0.5.0-nightly.22) (2022-10-26)

### Bug Fixes

- **e2e:** patch wallet to respect epoch boundary ([6fe2bfe](https://github.com/input-output-hk/cardano-js-sdk/commit/6fe2bfe59fdbbd29671e9bc55e43405844a10fd6))

## [0.5.0-nightly.21](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.20...@cardano-sdk/e2e@0.5.0-nightly.21) (2022-10-25)

### ⚠ BREAKING CHANGES

- **web-extension:** `ExposeApiProps` `api` has changed to observable `api$`.
  Users can use rxjs `of` function to create an observable: `api$: of(api)` to
  adapt existing code to this change.

### Features

- **web-extension:** enhance remoteApi to allow changing observed api object ([6245b90](https://github.com/input-output-hk/cardano-js-sdk/commit/6245b908d33aa14a2736f110add4605d3ce3ab4e))

## [0.5.0-nightly.20](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.19...@cardano-sdk/e2e@0.5.0-nightly.20) (2022-10-24)

**Note:** Version bump only for package @cardano-sdk/e2e

## [0.5.0-nightly.19](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.18...@cardano-sdk/e2e@0.5.0-nightly.19) (2022-10-13)

**Note:** Version bump only for package @cardano-sdk/e2e

## [0.5.0-nightly.18](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.17...@cardano-sdk/e2e@0.5.0-nightly.18) (2022-10-11)

**Note:** Version bump only for package @cardano-sdk/e2e

## [0.5.0-nightly.17](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.16...@cardano-sdk/e2e@0.5.0-nightly.17) (2022-10-08)

**Note:** Version bump only for package @cardano-sdk/e2e

## [0.5.0-nightly.16](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.15...@cardano-sdk/e2e@0.5.0-nightly.16) (2022-10-07)

**Note:** Version bump only for package @cardano-sdk/e2e

## [0.5.0-nightly.15](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.14...@cardano-sdk/e2e@0.5.0-nightly.15) (2022-10-05)

### ⚠ BREAKING CHANGES

- **wallet:** add inFlightTransactions store dependency to TransactionReemitterProps

Resubmit transactions that don't get confirmed for too long:

- **wallet:** add inFlight$ dependency to TransactionsReemitter
- **dapp-connector:** renamed cip30 package to dapp-connector
- add pagination in 'transactionsByAddresses'

### Features

- add pagination in 'transactionsByAddresses' ([fc88afa](https://github.com/input-output-hk/cardano-js-sdk/commit/fc88afa9f006e9fc7b50b5a98665058a0d563e31))
- **wallet:** resubmit recoverable transactions ([fa8aa85](https://github.com/input-output-hk/cardano-js-sdk/commit/fa8aa850d8afacf5fe1a524c29dd94bc20033a63))

### Code Refactoring

- **dapp-connector:** renamed cip30 package to dapp-connector ([cb4411d](https://github.com/input-output-hk/cardano-js-sdk/commit/cb4411da916b263ad8a6d85e0bdaffcfe21646c5))

## [0.5.0-nightly.14](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.13...@cardano-sdk/e2e@0.5.0-nightly.14) (2022-09-26)

### ⚠ BREAKING CHANGES

- **input-selection:** renamed cip2 package to input-selection

### Code Refactoring

- **input-selection:** renamed cip2 package to input-selection ([f4d6632](https://github.com/input-output-hk/cardano-js-sdk/commit/f4d6632d61c5b63bc15a64ec3962425f9ad2d6eb))

## [0.5.0-nightly.13](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.12...@cardano-sdk/e2e@0.5.0-nightly.13) (2022-09-23)

### ⚠ BREAKING CHANGES

- hoist Cardano.util.{deserializeTx,metadatum}

### Code Refactoring

- hoist Cardano.util.{deserializeTx,metadatum} ([a1d0754](https://github.com/input-output-hk/cardano-js-sdk/commit/a1d07549e7a5fccd36b9f75b9f713c0def8cb97f))

## [0.5.0-nightly.12](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.11...@cardano-sdk/e2e@0.5.0-nightly.12) (2022-09-22)

**Note:** Version bump only for package @cardano-sdk/e2e

## [0.5.0-nightly.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.10...@cardano-sdk/e2e@0.5.0-nightly.11) (2022-09-21)

**Note:** Version bump only for package @cardano-sdk/e2e

## [0.5.0-nightly.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.9...@cardano-sdk/e2e@0.5.0-nightly.10) (2022-09-20)

**Note:** Version bump only for package @cardano-sdk/e2e

## [0.5.0-nightly.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.8...@cardano-sdk/e2e@0.5.0-nightly.9) (2022-09-16)

**Note:** Version bump only for package @cardano-sdk/e2e

## [0.5.0-nightly.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.7...@cardano-sdk/e2e@0.5.0-nightly.8) (2022-09-15)

**Note:** Version bump only for package @cardano-sdk/e2e

## [0.5.0-nightly.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.4.0...@cardano-sdk/e2e@0.5.0-nightly.7) (2022-09-14)

### ⚠ BREAKING CHANGES

- buildTx() requires positional params and mandatory logger
- TxBuilder.delegate returns synchronously. No await needed anymore.
- lift key management and governance concepts to new packages
- rework all provider signatures args from positional to a single object
- convert boolean args to support ENV counterparts, parse as booleans
- consolidate cli & run entrypoints
- logger is now required
- rename pouchdb->pouchDb
- hoist stake$ and lovelaceSupply$ out of ObservableWallet
- update min utxo computation to be Babbage-compatible

### Features

- added signing options with extra signers to the transaction finalize method ([514b718](https://github.com/input-output-hk/cardano-js-sdk/commit/514b718825af93965739ec5f890f6be2aacf4f48))
- buildTx added logger ([2831a2a](https://github.com/input-output-hk/cardano-js-sdk/commit/2831a2ac99909fa6f2641f27c633932a4cbdb588))
- **e2e:** export utils as a library ([3ee8496](https://github.com/input-output-hk/cardano-js-sdk/commit/3ee8496177f4719449c869d09d9ea7a47fc38a22))
- **e2e:** update some tests to use txBuilder ([c38d52d](https://github.com/input-output-hk/cardano-js-sdk/commit/c38d52daef9d48fe2c59a383469fa7de57fa6e20))
- outputBuilder txOut method returns snapshot ([d07a89a](https://github.com/input-output-hk/cardano-js-sdk/commit/d07a89a7cb5610768daccc92058595906ea344d2))
- txBuilder deregister stake key cert ([b0d3358](https://github.com/input-output-hk/cardano-js-sdk/commit/b0d335861e2fa2274740f34240dba041e295fef2))
- txBuilder postpone adding certificates until build ([431cf51](https://github.com/input-output-hk/cardano-js-sdk/commit/431cf51a1903eaf7ece50228c587ebea4ccd5fc9))

### Bug Fixes

- convert boolean args to support ENV counterparts, parse as booleans ([d14bd9d](https://github.com/input-output-hk/cardano-js-sdk/commit/d14bd9d8aeec64f04aab094e0aceb8dc5b803926))
- **e2e:** fix a bug preventing get wallet to be parallelized and make required its logger parameter ([2a67e89](https://github.com/input-output-hk/cardano-js-sdk/commit/2a67e89720e396cc393fc70728590ba333068a2e))
- malformed string and add missing service to Docker defaults ([b40edf6](https://github.com/input-output-hk/cardano-js-sdk/commit/b40edf6f2aec7d654206725e38c88ab1f60d8222))
- update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))

### Code Refactoring

- consolidate cli & run entrypoints ([1452bfb](https://github.com/input-output-hk/cardano-js-sdk/commit/1452bfb4935129a37dbd83680d623dca081f3948))
- hoist stake$ and lovelaceSupply$ out of ObservableWallet ([3bf1720](https://github.com/input-output-hk/cardano-js-sdk/commit/3bf17200c8bae46b02817c16e5138d3678cfa3f5))
- lift key management and governance concepts to new packages ([15cde5f](https://github.com/input-output-hk/cardano-js-sdk/commit/15cde5f9becff94dac17278cb45e3adcaac763b5))
- logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))
- rename pouchdb->pouchDb ([c58ccf9](https://github.com/input-output-hk/cardano-js-sdk/commit/c58ccf9f7a8f701dce87e2f6ddc2f28c0aa68745))
- rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))

## [0.5.0-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.4.0...@cardano-sdk/e2e@0.5.0-nightly.0) (2022-09-14)

### ⚠ BREAKING CHANGES

- buildTx() requires positional params and mandatory logger
- TxBuilder.delegate returns synchronously. No await needed anymore.
- lift key management and governance concepts to new packages
- rework all provider signatures args from positional to a single object
- convert boolean args to support ENV counterparts, parse as booleans
- consolidate cli & run entrypoints
- logger is now required
- rename pouchdb->pouchDb
- hoist stake$ and lovelaceSupply$ out of ObservableWallet
- update min utxo computation to be Babbage-compatible

### Features

- added signing options with extra signers to the transaction finalize method ([514b718](https://github.com/input-output-hk/cardano-js-sdk/commit/514b718825af93965739ec5f890f6be2aacf4f48))
- buildTx added logger ([2831a2a](https://github.com/input-output-hk/cardano-js-sdk/commit/2831a2ac99909fa6f2641f27c633932a4cbdb588))
- **e2e:** export utils as a library ([3ee8496](https://github.com/input-output-hk/cardano-js-sdk/commit/3ee8496177f4719449c869d09d9ea7a47fc38a22))
- **e2e:** update some tests to use txBuilder ([c38d52d](https://github.com/input-output-hk/cardano-js-sdk/commit/c38d52daef9d48fe2c59a383469fa7de57fa6e20))
- outputBuilder txOut method returns snapshot ([d07a89a](https://github.com/input-output-hk/cardano-js-sdk/commit/d07a89a7cb5610768daccc92058595906ea344d2))
- txBuilder deregister stake key cert ([b0d3358](https://github.com/input-output-hk/cardano-js-sdk/commit/b0d335861e2fa2274740f34240dba041e295fef2))
- txBuilder postpone adding certificates until build ([431cf51](https://github.com/input-output-hk/cardano-js-sdk/commit/431cf51a1903eaf7ece50228c587ebea4ccd5fc9))

### Bug Fixes

- convert boolean args to support ENV counterparts, parse as booleans ([d14bd9d](https://github.com/input-output-hk/cardano-js-sdk/commit/d14bd9d8aeec64f04aab094e0aceb8dc5b803926))
- **e2e:** fix a bug preventing get wallet to be parallelized and make required its logger parameter ([2a67e89](https://github.com/input-output-hk/cardano-js-sdk/commit/2a67e89720e396cc393fc70728590ba333068a2e))
- malformed string and add missing service to Docker defaults ([b40edf6](https://github.com/input-output-hk/cardano-js-sdk/commit/b40edf6f2aec7d654206725e38c88ab1f60d8222))
- update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))

### Code Refactoring

- consolidate cli & run entrypoints ([1452bfb](https://github.com/input-output-hk/cardano-js-sdk/commit/1452bfb4935129a37dbd83680d623dca081f3948))
- hoist stake$ and lovelaceSupply$ out of ObservableWallet ([3bf1720](https://github.com/input-output-hk/cardano-js-sdk/commit/3bf17200c8bae46b02817c16e5138d3678cfa3f5))
- lift key management and governance concepts to new packages ([15cde5f](https://github.com/input-output-hk/cardano-js-sdk/commit/15cde5f9becff94dac17278cb45e3adcaac763b5))
- logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))
- rename pouchdb->pouchDb ([c58ccf9](https://github.com/input-output-hk/cardano-js-sdk/commit/c58ccf9f7a8f701dce87e2f6ddc2f28c0aa68745))
- rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))

## 0.4.0 (2022-08-30)

### ⚠ BREAKING CHANGES

- consolidate cli & run entrypoints
- logger is now required
- rename pouchdb->pouchDb
- hoist stake$ and lovelaceSupply$ out of ObservableWallet
- update min utxo computation to be Babbage-compatible
- hoist KeyAgent's InputResolver dependency to constructor

### Bug Fixes

- **e2e:** fix a bug preventing get wallet to be parallelized and make required its logger parameter ([2a67e89](https://github.com/input-output-hk/cardano-js-sdk/commit/2a67e89720e396cc393fc70728590ba333068a2e))
- malformed string and add missing service to Docker defaults ([b40edf6](https://github.com/input-output-hk/cardano-js-sdk/commit/b40edf6f2aec7d654206725e38c88ab1f60d8222))
- update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))

### Code Refactoring

- consolidate cli & run entrypoints ([1452bfb](https://github.com/input-output-hk/cardano-js-sdk/commit/1452bfb4935129a37dbd83680d623dca081f3948))
- hoist KeyAgent's InputResolver dependency to constructor ([759dc09](https://github.com/input-output-hk/cardano-js-sdk/commit/759dc09b427831cb193f1c0a545901abd4d50254))
- hoist stake$ and lovelaceSupply$ out of ObservableWallet ([3bf1720](https://github.com/input-output-hk/cardano-js-sdk/commit/3bf17200c8bae46b02817c16e5138d3678cfa3f5))
- logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))
- rename pouchdb->pouchDb ([c58ccf9](https://github.com/input-output-hk/cardano-js-sdk/commit/c58ccf9f7a8f701dce87e2f6ddc2f28c0aa68745))

## [0.3.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/e2e@0.3.0) (2022-07-25)

### ⚠ BREAKING CHANGES

- update min utxo computation to be Babbage-compatible
- hoist KeyAgent's InputResolver dependency to constructor

### Bug Fixes

- update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))

### Code Refactoring

- hoist KeyAgent's InputResolver dependency to constructor ([759dc09](https://github.com/input-output-hk/cardano-js-sdk/commit/759dc09b427831cb193f1c0a545901abd4d50254))
