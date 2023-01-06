# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.6.0...@cardano-sdk/cardano-services-client@0.7.0) (2022-12-22)

### ⚠ BREAKING CHANGES

- - BlockSize is now an OpaqueNumber rather than a type alias for number

* BlockNo is now an OpaqueNumber rather than a type alias for number
* EpochNo is now an OpaqueNumber rather than a type alias for number
* Slot is now an OpaqueNumber rather than a type alias for number
* Percentage is now an OpaqueNumber rather than a type alias for number

- classify TxSubmission errors as variant of CardanoNode error

### Features

- add opaque numeric types to core package ([9ead8bd](https://github.com/input-output-hk/cardano-js-sdk/commit/9ead8bdb34b7ffc57c32f9ab18a6c6ca14af3fda))

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
- **cardano-services-client:** import warning ([2e0ac62](https://github.com/input-output-hk/cardano-js-sdk/commit/2e0ac62e5bf8abd5ae859e24abea00e9543e78c6))

### Code Refactoring

- classify TxSubmission errors as variant of CardanoNode error ([234305e](https://github.com/input-output-hk/cardano-js-sdk/commit/234305e28aefd3d9bd1736315bdf89ca31f7556f))

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.5.0...@cardano-sdk/cardano-services-client@0.6.0) (2022-11-04)

### ⚠ BREAKING CHANGES

- support the complete set of protocol parameters
- make stake pools pagination a required arg
- add pagination in 'transactionsByAddresses'
- rework TxSubmitProvider to submit transactions as hex string instead of Buffer
- rework all provider signatures args from positional to a single object

### Features

- add pagination in 'transactionsByAddresses' ([fc88afa](https://github.com/input-output-hk/cardano-js-sdk/commit/fc88afa9f006e9fc7b50b5a98665058a0d563e31))
- make stake pools pagination a required arg ([6cf8206](https://github.com/input-output-hk/cardano-js-sdk/commit/6cf8206be2162db7196794f7252e5cbb84b65c77))
- support the complete set of protocol parameters ([46d7aa9](https://github.com/input-output-hk/cardano-js-sdk/commit/46d7aa97230a666ca119c7de5ed0cf70b742d2a2))

### Bug Fixes

- **cardano-services-client:** do not re-wrap UnknownTxSubmissionError ([a51c9e8](https://github.com/input-output-hk/cardano-js-sdk/commit/a51c9e870e19acf5a36ca4e7f2da0001c998f95a))

### Code Refactoring

- rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))
- rework TxSubmitProvider to submit transactions as hex string instead of Buffer ([032a1b7](https://github.com/input-output-hk/cardano-js-sdk/commit/032a1b7a11941d52b5baf0d447b615c58a294068))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.4.0...@cardano-sdk/cardano-services-client@0.5.0) (2022-08-30)

### ⚠ BREAKING CHANGES

- replace `NetworkInfoProvider.timeSettings` with `eraSummaries`

### Features

- **cardano-services-client:** add asset info http provider ([866f3d5](https://github.com/input-output-hk/cardano-js-sdk/commit/866f3d5374e7572a966bff0a93a92ebf0412208c))
- replace `NetworkInfoProvider.timeSettings` with `eraSummaries` ([58f6fc7](https://github.com/input-output-hk/cardano-js-sdk/commit/58f6fc7c5ace703583c36f95d3d6962483ad924d))

### Bug Fixes

- **cardano-services-client:** added Axios adapter to allow patching the axios requests method ([166a273](https://github.com/input-output-hk/cardano-js-sdk/commit/166a273d378e321dd190d0bc4adb50d6f96bb389))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/cardano-services-client@0.4.0) (2022-07-25)

### Features

- **cardano-services-client:** add asset info http provider ([866f3d5](https://github.com/input-output-hk/cardano-js-sdk/commit/866f3d5374e7572a966bff0a93a92ebf0412208c))

## 0.3.0 (2022-06-24)

### ⚠ BREAKING CHANGES

- move stakePoolStats from wallet provider to stake pool provider
- rename `StakePoolSearchProvider` to `StakePoolProvider`
- add serializable object key transformation support
- **cardano-services-client:** reimplement txSubmitHttpProvider using createHttpProvider
- **cardano-graphql:** remove graphql concerns from services client package, rename

### Features

- add ChainHistory http provider ([64aa7ae](https://github.com/input-output-hk/cardano-js-sdk/commit/64aa7aeff061aa2cf9bc6196347f6cf5b9c7f6be))
- add utxo http provider ([a55fcdb](https://github.com/input-output-hk/cardano-js-sdk/commit/a55fcdb08276c37a1852f0c39e5b0a78501ddf0b))
- **cardano-services-client:** add generic http provider client ([72e2060](https://github.com/input-output-hk/cardano-js-sdk/commit/72e20602137a55ca4c6f95221b3d7aa09c10da9a))
- **cardano-services-client:** add stakePoolSearchHttpProvider ([286f41f](https://github.com/input-output-hk/cardano-js-sdk/commit/286f41f700cc6d41fa5192d33e73c87ea6a418ac))
- **cardano-services-client:** networkInfoProvider ([a304468](https://github.com/input-output-hk/cardano-js-sdk/commit/a30446870528acbabda121c691443ee4ba1b2784))
- rewards data ([5ce2ff0](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce2ff00856d362cf0e423ddadadb15cef764932))
- **web-extension:** add rewards provider support ([3630fba](https://github.com/input-output-hk/cardano-js-sdk/commit/3630fbae9fd8bdb5539a32e39b65f2ce8577a481))

### Bug Fixes

- **cardano-services-client:** http provider can now be the return value of an async function ([e732f5d](https://github.com/input-output-hk/cardano-js-sdk/commit/e732f5d7fcacd75cfecda3e1c21f387d21f46bed))
- **cardano-services-client:** update test URL and reword docblock ([4bfe001](https://github.com/input-output-hk/cardano-js-sdk/commit/4bfe0017a48146c81f571967299d360b8efc6732))

### Miscellaneous Chores

- **cardano-graphql:** remove graphql concerns from services client package, rename ([f197e46](https://github.com/input-output-hk/cardano-js-sdk/commit/f197e46254f7f56b6461239a12f213c0e34ccc5c))

### Code Refactoring

- add serializable object key transformation support ([32e422e](https://github.com/input-output-hk/cardano-js-sdk/commit/32e422e83f723a41521193d9cf4206a538fbcb43))
- **cardano-services-client:** reimplement txSubmitHttpProvider using createHttpProvider ([db17e34](https://github.com/input-output-hk/cardano-js-sdk/commit/db17e34193322856b1f5073c39658f223d31087b))
- move stakePoolStats from wallet provider to stake pool provider ([52d71a7](https://github.com/input-output-hk/cardano-js-sdk/commit/52d71a70700b05902cca6205fe01a63f811ba5af))
- rename `StakePoolSearchProvider` to `StakePoolProvider` ([b432103](https://github.com/input-output-hk/cardano-js-sdk/commit/b43210348da7914664733f85f8be8999271a8667))
