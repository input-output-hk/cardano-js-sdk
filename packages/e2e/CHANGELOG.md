# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.5.0-nightly.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.5...@cardano-sdk/e2e@0.5.0-nightly.6) (2022-09-14)

**Note:** Version bump only for package @cardano-sdk/e2e





## [0.5.0-nightly.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.4...@cardano-sdk/e2e@0.5.0-nightly.5) (2022-09-13)


### ⚠ BREAKING CHANGES

* buildTx() requires positional params and mandatory logger
* TxBuilder.delegate returns synchronously. No await needed anymore.

### Features

* buildTx added logger ([2831a2a](https://github.com/input-output-hk/cardano-js-sdk/commit/2831a2ac99909fa6f2641f27c633932a4cbdb588))
* outputBuilder txOut method returns snapshot ([d07a89a](https://github.com/input-output-hk/cardano-js-sdk/commit/d07a89a7cb5610768daccc92058595906ea344d2))
* txBuilder deregister stake key cert ([b0d3358](https://github.com/input-output-hk/cardano-js-sdk/commit/b0d335861e2fa2274740f34240dba041e295fef2))
* txBuilder postpone adding certificates until build ([431cf51](https://github.com/input-output-hk/cardano-js-sdk/commit/431cf51a1903eaf7ece50228c587ebea4ccd5fc9))



## [0.5.0-nightly.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.3...@cardano-sdk/e2e@0.5.0-nightly.4) (2022-09-10)


### ⚠ BREAKING CHANGES

* lift key management and governance concepts to new packages

### Features

* **e2e:** update some tests to use txBuilder ([c38d52d](https://github.com/input-output-hk/cardano-js-sdk/commit/c38d52daef9d48fe2c59a383469fa7de57fa6e20))


### Code Refactoring

* lift key management and governance concepts to new packages ([15cde5f](https://github.com/input-output-hk/cardano-js-sdk/commit/15cde5f9becff94dac17278cb45e3adcaac763b5))



## [0.5.0-nightly.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.2...@cardano-sdk/e2e@0.5.0-nightly.3) (2022-09-06)


### ⚠ BREAKING CHANGES

* rework all provider signatures args from positional to a single object

### Code Refactoring

* rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))



## [0.5.0-nightly.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.1...@cardano-sdk/e2e@0.5.0-nightly.2) (2022-09-02)


### ⚠ BREAKING CHANGES

* convert boolean args to support ENV counterparts, parse as booleans

### Bug Fixes

* convert boolean args to support ENV counterparts, parse as booleans ([d14bd9d](https://github.com/input-output-hk/cardano-js-sdk/commit/d14bd9d8aeec64f04aab094e0aceb8dc5b803926))



## [0.5.0-nightly.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0-nightly.0...@cardano-sdk/e2e@0.5.0-nightly.1) (2022-09-01)


### Features

* added signing options with extra signers to the transaction finalize method ([514b718](https://github.com/input-output-hk/cardano-js-sdk/commit/514b718825af93965739ec5f890f6be2aacf4f48))



## 0.5.0-nightly.0 (2022-08-31)


### Features

* **e2e:** export utils as a library ([3ee8496](https://github.com/input-output-hk/cardano-js-sdk/commit/3ee8496177f4719449c869d09d9ea7a47fc38a22))



## 0.4.0 (2022-08-30)


### ⚠ BREAKING CHANGES

* consolidate cli & run entrypoints
* logger is now required
* rename pouchdb->pouchDb
* hoist stake$ and lovelaceSupply$ out of ObservableWallet
* update min utxo computation to be Babbage-compatible
* hoist KeyAgent's InputResolver dependency to constructor

### Bug Fixes

* **e2e:** fix a bug preventing get wallet to be parallelized and make required its logger parameter ([2a67e89](https://github.com/input-output-hk/cardano-js-sdk/commit/2a67e89720e396cc393fc70728590ba333068a2e))
* malformed string and add missing service to Docker defaults ([b40edf6](https://github.com/input-output-hk/cardano-js-sdk/commit/b40edf6f2aec7d654206725e38c88ab1f60d8222))
* update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))


### Code Refactoring

* consolidate cli & run entrypoints ([1452bfb](https://github.com/input-output-hk/cardano-js-sdk/commit/1452bfb4935129a37dbd83680d623dca081f3948))
* hoist KeyAgent's InputResolver dependency to constructor ([759dc09](https://github.com/input-output-hk/cardano-js-sdk/commit/759dc09b427831cb193f1c0a545901abd4d50254))
* hoist stake$ and lovelaceSupply$ out of ObservableWallet ([3bf1720](https://github.com/input-output-hk/cardano-js-sdk/commit/3bf17200c8bae46b02817c16e5138d3678cfa3f5))
* logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))
* rename pouchdb->pouchDb ([c58ccf9](https://github.com/input-output-hk/cardano-js-sdk/commit/c58ccf9f7a8f701dce87e2f6ddc2f28c0aa68745))



## [0.3.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/e2e@0.3.0) (2022-07-25)


### ⚠ BREAKING CHANGES

* update min utxo computation to be Babbage-compatible
* hoist KeyAgent's InputResolver dependency to constructor

### Bug Fixes

* update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))


### Code Refactoring

* hoist KeyAgent's InputResolver dependency to constructor ([759dc09](https://github.com/input-output-hk/cardano-js-sdk/commit/759dc09b427831cb193f1c0a545901abd4d50254))
