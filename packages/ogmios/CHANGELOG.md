# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.6.0-nightly.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.6.0-nightly.2...@cardano-sdk/ogmios@0.6.0-nightly.3) (2022-09-14)

**Note:** Version bump only for package @cardano-sdk/ogmios





## [0.6.0-nightly.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.6.0-nightly.1...@cardano-sdk/ogmios@0.6.0-nightly.2) (2022-09-13)

**Note:** Version bump only for package @cardano-sdk/ogmios





## [0.6.0-nightly.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.6.0-nightly.0...@cardano-sdk/ogmios@0.6.0-nightly.1) (2022-09-10)

**Note:** Version bump only for package @cardano-sdk/ogmios





## [0.6.0-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.5.1-nightly.2...@cardano-sdk/ogmios@0.6.0-nightly.0) (2022-09-06)


### ⚠ BREAKING CHANGES

* rework TxSubmitProvider to submit transactions as hex string instead of Buffer
* rework all provider signatures args from positional to a single object

### Code Refactoring

* rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))
* rework TxSubmitProvider to submit transactions as hex string instead of Buffer ([032a1b7](https://github.com/input-output-hk/cardano-js-sdk/commit/032a1b7a11941d52b5baf0d447b615c58a294068))



## [0.5.1-nightly.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.5.1-nightly.1...@cardano-sdk/ogmios@0.5.1-nightly.2) (2022-09-02)

**Note:** Version bump only for package @cardano-sdk/ogmios





## [0.5.1-nightly.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.5.1-nightly.0...@cardano-sdk/ogmios@0.5.1-nightly.1) (2022-09-01)

**Note:** Version bump only for package @cardano-sdk/ogmios





## [0.5.1-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.5.0...@cardano-sdk/ogmios@0.5.1-nightly.0) (2022-08-31)

**Note:** Version bump only for package @cardano-sdk/ogmios





## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.4.0...@cardano-sdk/ogmios@0.5.0) (2022-08-30)


### ⚠ BREAKING CHANGES

* replace `NetworkInfoProvider.timeSettings` with `eraSummaries`
* logger is now required

### Features

* extend HealthCheckResponse ([2e6d0a3](https://github.com/input-output-hk/cardano-js-sdk/commit/2e6d0a3d2067ce8538886f1a9d0d55fab7647ae9))
* ogmios cardano node DNS resolution ([d132c9f](https://github.com/input-output-hk/cardano-js-sdk/commit/d132c9f52485086a5cf797217d48c816ae51d2b3))
* replace `NetworkInfoProvider.timeSettings` with `eraSummaries` ([58f6fc7](https://github.com/input-output-hk/cardano-js-sdk/commit/58f6fc7c5ace703583c36f95d3d6962483ad924d))


### Code Refactoring

* logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))



## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/ogmios@0.4.0) (2022-07-25)


### Features

* **ogmios:** enriched the test mock to respond with beforeValidityInterval ([b56f9a8](https://github.com/input-output-hk/cardano-js-sdk/commit/b56f9a83b38d9c46dfa1d7008ab632f9a737b9ea))
* support any network by fetching time settings from the node ([08d9ed2](https://github.com/input-output-hk/cardano-js-sdk/commit/08d9ed2b6aa20cf4df2a063f046f4e5ca28c6bd5))

## 0.3.0 (2022-06-24)


### Features

* add Provider interface, use as base for TxSubmitProvider ([e155ed4](https://github.com/input-output-hk/cardano-js-sdk/commit/e155ed4efcd1338a54099d1a9034ccbeddeef1cc))
* **ogmios:** added submitTxHook to test mock server ([ccbddae](https://github.com/input-output-hk/cardano-js-sdk/commit/ccbddaefeae228b7b02160a6b2ef4e7e0995e689))
* **ogmios:** added urlToConnectionConfig function ([bd22262](https://github.com/input-output-hk/cardano-js-sdk/commit/bd22262cdac4d90561069fefe89028eaf01643a0))
* **ogmios:** export Ogmios client function for SDK access ([92af547](https://github.com/input-output-hk/cardano-js-sdk/commit/92af5472ceff52b747428c37c953ffd3c940d950))
* **ogmios:** exported listenPromise & serverClosePromise test functions ([354de85](https://github.com/input-output-hk/cardano-js-sdk/commit/354de855990b3cad66d61314d481f8063a346b6c))
* **ogmios:** package init and ogmiosTxSubmitProvider ([3b8461b](https://github.com/input-output-hk/cardano-js-sdk/commit/3b8461b2ca9081736c1495318be68deb0e12bd6b))


### Bug Fixes

* **ogmios:** fix failing tests ([3c8c5f7](https://github.com/input-output-hk/cardano-js-sdk/commit/3c8c5f746a41508006e9f059e138b70d9ea1baff))
* **ogmios:** tx submit provider ts error fix ([a24a78c](https://github.com/input-output-hk/cardano-js-sdk/commit/a24a78c5b2d8e75f0c99c12c47cf0b5eb3424b49))
