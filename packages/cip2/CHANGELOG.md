# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.5.1-nightly.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cip2@0.5.1-nightly.2...@cardano-sdk/cip2@0.5.1-nightly.3) (2022-09-06)

**Note:** Version bump only for package @cardano-sdk/cip2





## [0.5.1-nightly.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cip2@0.5.1-nightly.1...@cardano-sdk/cip2@0.5.1-nightly.2) (2022-09-02)

**Note:** Version bump only for package @cardano-sdk/cip2





## [0.5.1-nightly.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cip2@0.5.1-nightly.0...@cardano-sdk/cip2@0.5.1-nightly.1) (2022-09-01)

**Note:** Version bump only for package @cardano-sdk/cip2





## [0.5.1-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cip2@0.5.0...@cardano-sdk/cip2@0.5.1-nightly.0) (2022-08-31)

**Note:** Version bump only for package @cardano-sdk/cip2





## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cip2@0.4.0...@cardano-sdk/cip2@0.5.0) (2022-08-30)


### ⚠ BREAKING CHANGES

* rename InputSelectionParameters implicitCoin->implicitValue.coin
* rm TxAlonzo.implicitCoin
* update min utxo computation to be Babbage-compatible

### Features

* **cip2:** add implicit tokens support (mint/burn) for input selection ([3361855](https://github.com/input-output-hk/cardano-js-sdk/commit/3361855a2fbf20afc8ead11565ac6759548ab13f))


### Bug Fixes

* update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))


### Code Refactoring

* rename InputSelectionParameters implicitCoin->implicitValue.coin ([3242a0d](https://github.com/input-output-hk/cardano-js-sdk/commit/3242a0dc63da0e59c4f8536d16758ea19f58a2c0))
* rm TxAlonzo.implicitCoin ([167d205](https://github.com/input-output-hk/cardano-js-sdk/commit/167d205dd15c857b229f968ab53a6e52e5504d3f))



## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/cip2@0.4.0) (2022-07-25)


### ⚠ BREAKING CHANGES

* update min utxo computation to be Babbage-compatible

### Bug Fixes

* update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))

## 0.3.0 (2022-06-24)


### ⚠ BREAKING CHANGES

* **cip2:** update interfaces to use core package types instead of CSL

### Features

* **cip2:** add support for custom random fn ([934c855](https://github.com/input-output-hk/cardano-js-sdk/commit/934c85520ca666bc62cc51afa6fbf17dda7bbfb5))


### Bug Fixes

* **cip2:** adjust fee by hardcoded value (+10k) ([7410ae0](https://github.com/input-output-hk/cardano-js-sdk/commit/7410ae053ea2b4c78d82659a89bdcfd895a4e808))
* **cip2:** computeSelectionLimit constraint logic error ([b329971](https://github.com/input-output-hk/cardano-js-sdk/commit/b3299713ae40a6e5e06a312b4b28f6c20a6a3ef8))
* **cip2:** omit 0 qty assets from change bundles ([d3a12cf](https://github.com/input-output-hk/cardano-js-sdk/commit/d3a12cfb577bcae04f793e96f23ce84ee87a7bcb))
* **cip2:** property tests generate quantities > 0 ([3988ca0](https://github.com/input-output-hk/cardano-js-sdk/commit/3988ca002d45ca8a060d54fb67b244702157ca7e))
* **cip2:** recompute min fee after selecting extra utxo due to min value ([bfb7db5](https://github.com/input-output-hk/cardano-js-sdk/commit/bfb7db55b76d154e036e788edae376b1589510ee))
* **cip2:** remove hardcoded value in minimum cost selection constraint ([ad6d133](https://github.com/input-output-hk/cardano-js-sdk/commit/ad6d133a0ba1f865bf2ae1ca3f46b8e6f918502b))
* resolve issues preventing to make a delegation tx ([7429f46](https://github.com/input-output-hk/cardano-js-sdk/commit/7429f466763342b08b6bed44f23d3bf24dbf92f2))
* rm imports from @cardano-sdk/*/src/* ([3fdead3](https://github.com/input-output-hk/cardano-js-sdk/commit/3fdead3ae381a3efb98299b9881c6a964461b7db))


### Code Refactoring

* **cip2:** update interfaces to use core package types instead of CSL ([5c66d32](https://github.com/input-output-hk/cardano-js-sdk/commit/5c66d32fdc58100a2b0807a0470342d54a3989ed))

### 0.1.5 (2021-10-27)


### Features

* **cip2:** add support for implicit coin ([47f6bd2](https://github.com/input-output-hk/cardano-js-sdk/commit/47f6bd2ee714ff9b6b9d8d311f2b3526f88a1a2b))

### 0.1.3 (2021-10-05)

### 0.1.2 (2021-09-30)


### Bug Fixes

* add missing dependencies ([2d3bfbc](https://github.com/input-output-hk/cardano-js-sdk/commit/2d3bfbc3f8d5fdce3be64835c57304b540e05811))

### 0.1.1 (2021-09-30)


### Features

* **cip2:** implement defaultSelectionConstraints ([f93e3f1](https://github.com/input-output-hk/cardano-js-sdk/commit/f93e3f1fd860a477f81975ad415d38c3c93c65d9))
* **cip2:** initial implementation of RoundRobinRandomImprove ([17080e2](https://github.com/input-output-hk/cardano-js-sdk/commit/17080e2ee37ed5b3f51affef8dc834ae3943219f))


### Bug Fixes

* **cip2:** add fee to selection skeleton ([36e93bc](https://github.com/input-output-hk/cardano-js-sdk/commit/36e93bccb8f5426022631f409b85aa2fe4ea7470))
* **cip2:** change token bundle size constraint arg to CSL.MultiAsset ([4bde8e8](https://github.com/input-output-hk/cardano-js-sdk/commit/4bde8e8fde11908d4295f3f53918faed255f1ba0))
* **cip2:** compute selection limit constraint with actual fee instead of max u64 ([eee4f5e](https://github.com/input-output-hk/cardano-js-sdk/commit/eee4f5e035a20fb61b151d294213978fd8f39302))
* **cip2:** ensure there are no empty change bundles, add some test info to README ([8f3f20b](https://github.com/input-output-hk/cardano-js-sdk/commit/8f3f20ba8de812895844fad0d09eb63104114a83))
* **cip2:** exclude fee from change bundles ([16d7c26](https://github.com/input-output-hk/cardano-js-sdk/commit/16d7c267df0b9f70d1e2ba1afd03e531282686fd))
