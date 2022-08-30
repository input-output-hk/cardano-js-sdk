# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

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
