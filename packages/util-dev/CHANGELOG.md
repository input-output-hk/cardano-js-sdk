# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.5.0-nightly.14](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.5.0-nightly.13...@cardano-sdk/util-dev@0.5.0-nightly.14) (2022-10-13)

**Note:** Version bump only for package @cardano-sdk/util-dev





## [0.5.0-nightly.13](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.5.0-nightly.12...@cardano-sdk/util-dev@0.5.0-nightly.13) (2022-10-11)

**Note:** Version bump only for package @cardano-sdk/util-dev





## [0.5.0-nightly.12](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.5.0-nightly.11...@cardano-sdk/util-dev@0.5.0-nightly.12) (2022-10-08)


### ⚠ BREAKING CHANGES

* make stake pools pagination a required arg

### Features

* make stake pools pagination a required arg ([6cf8206](https://github.com/input-output-hk/cardano-js-sdk/commit/6cf8206be2162db7196794f7252e5cbb84b65c77))



## [0.5.0-nightly.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.5.0-nightly.10...@cardano-sdk/util-dev@0.5.0-nightly.11) (2022-10-07)

**Note:** Version bump only for package @cardano-sdk/util-dev





## [0.5.0-nightly.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.5.0-nightly.9...@cardano-sdk/util-dev@0.5.0-nightly.10) (2022-10-05)

**Note:** Version bump only for package @cardano-sdk/util-dev





## [0.5.0-nightly.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.5.0-nightly.8...@cardano-sdk/util-dev@0.5.0-nightly.9) (2022-09-26)

**Note:** Version bump only for package @cardano-sdk/util-dev





## [0.5.0-nightly.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.5.0-nightly.7...@cardano-sdk/util-dev@0.5.0-nightly.8) (2022-09-23)

**Note:** Version bump only for package @cardano-sdk/util-dev





## [0.5.0-nightly.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.5.0-nightly.6...@cardano-sdk/util-dev@0.5.0-nightly.7) (2022-09-21)

**Note:** Version bump only for package @cardano-sdk/util-dev





## [0.5.0-nightly.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.5.0-nightly.5...@cardano-sdk/util-dev@0.5.0-nightly.6) (2022-09-20)

**Note:** Version bump only for package @cardano-sdk/util-dev





## [0.5.0-nightly.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.5.0-nightly.4...@cardano-sdk/util-dev@0.5.0-nightly.5) (2022-09-16)

**Note:** Version bump only for package @cardano-sdk/util-dev





## [0.5.0-nightly.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.4.1...@cardano-sdk/util-dev@0.5.0-nightly.4) (2022-09-14)


### ⚠ BREAKING CHANGES

* rework all provider signatures args from positional to a single object

### Code Refactoring

* rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))



## [0.5.0-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.4.1...@cardano-sdk/util-dev@0.5.0-nightly.0) (2022-09-14)


### ⚠ BREAKING CHANGES

* rework all provider signatures args from positional to a single object

### Code Refactoring

* rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))



## [0.4.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.4.0...@cardano-sdk/util-dev@0.4.1) (2022-08-30)


### Features

* **util-dev:** add test logger object ([d0453e3](https://github.com/input-output-hk/cardano-js-sdk/commit/d0453e30ac1381f98295394453c038e881ba77a9))


### Bug Fixes

* **util-dev:** rm TestLogger dependency on 'stream' for browser compat ([297a27e](https://github.com/input-output-hk/cardano-js-sdk/commit/297a27e089dff5a8dd0dfa33835d4982db370801))



## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/util-dev@0.4.0) (2022-07-25)

## 0.3.0 (2022-06-24)


### ⚠ BREAKING CHANGES

* move stakePoolStats from wallet provider to stake pool provider
* rename `StakePoolSearchProvider` to `StakePoolProvider`
* remove TimeSettingsProvider and NetworkInfo.currentEpoch
* change TimeSettings interface from fn to obj
* **util-dev:** rename mock minimumCost to minimumCostCoefficient

### Features

* add totalResultCount to StakePoolSearch response ([4265f6a](https://github.com/input-output-hk/cardano-js-sdk/commit/4265f6af60a92c93604b93167fd297530b6e01f8))
* **cardano-graphql-services:** module logger ([d93a121](https://github.com/input-output-hk/cardano-js-sdk/commit/d93a121c626e7c9ce060d575802bc2775cf875e3))
* **cardano-services:** stake pool search http server ([c3dd013](https://github.com/input-output-hk/cardano-js-sdk/commit/c3dd0133843327906535ce2ac623482cf95dd397))
* **util-dev:** add createStubTimeSettingsProvider ([d19321b](https://github.com/input-output-hk/cardano-js-sdk/commit/d19321b515387f8943f7e0df88b0173c71c46ffb))
* **util-dev:** add createStubUtxoProvider ([ac4156d](https://github.com/input-output-hk/cardano-js-sdk/commit/ac4156d6b74ce05daf11e5feeceef9c941973020))
* **util-dev:** add utils to create TxIn/TxOut/Utxo, refactor SelectionConstraints to use core types ([021087e](https://github.com/input-output-hk/cardano-js-sdk/commit/021087e7d3b0ca3de0fbc1bdc9438a6a00a4a07e))


### Bug Fixes

* rm imports from @cardano-sdk/*/src/* ([3fdead3](https://github.com/input-output-hk/cardano-js-sdk/commit/3fdead3ae381a3efb98299b9881c6a964461b7db))


### Code Refactoring

* change TimeSettings interface from fn to obj ([bc3b22d](https://github.com/input-output-hk/cardano-js-sdk/commit/bc3b22d55071f85073c54dcf47c535912bedb512))
* move stakePoolStats from wallet provider to stake pool provider ([52d71a7](https://github.com/input-output-hk/cardano-js-sdk/commit/52d71a70700b05902cca6205fe01a63f811ba5af))
* remove TimeSettingsProvider and NetworkInfo.currentEpoch ([4a8f72f](https://github.com/input-output-hk/cardano-js-sdk/commit/4a8f72f57f699f7c0bf4a9a4b742fc0a3e4aa8ce))
* rename `StakePoolSearchProvider` to `StakePoolProvider` ([b432103](https://github.com/input-output-hk/cardano-js-sdk/commit/b43210348da7914664733f85f8be8999271a8667))
* **util-dev:** rename mock minimumCost to minimumCostCoefficient ([1632c1d](https://github.com/input-output-hk/cardano-js-sdk/commit/1632c1d9775dec97edf815816017b7f6714dcd4d))

### 0.1.5 (2021-10-27)


### Features

* **util-dev:** add createStubStakePoolSearchProvider ([2e0906b](https://github.com/input-output-hk/cardano-js-sdk/commit/2e0906bc19acdf91b805e1eb647e88aa33ed1b7b))
* **util-dev:** add flushPromises util ([19eb508](https://github.com/input-output-hk/cardano-js-sdk/commit/19eb508af9c5364f9db604cfe4705857cd62f720))

### 0.1.3 (2021-10-05)
