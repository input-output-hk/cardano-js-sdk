# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.12.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.12.0...@cardano-sdk/cardano-services-client@0.12.1) (2023-08-21)

**Note:** Version bump only for package @cardano-sdk/cardano-services-client

## [0.12.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.11.0...@cardano-sdk/cardano-services-client@0.12.0) (2023-08-15)

### ⚠ BREAKING CHANGES

* add HandleProvider.getPolicyIds and utilize it in PersonalWallet also, handles$ resolvedAt is now only set via hydration (provider)

### Features

* add HandleProvider.getPolicyIds and utilize it in PersonalWallet also, handles$ resolvedAt is now only set via hydration (provider) ([af6a8d0](https://github.com/input-output-hk/cardano-js-sdk/commit/af6a8d011bbd2c218aa23e1d75bb25294fc61a27))

## [0.11.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.10.6...@cardano-sdk/cardano-services-client@0.11.0) (2023-08-11)

### ⚠ BREAKING CHANGES

* EpochRewards renamed to Reward
- The pool the stake address was delegated to when the reward is earned is now
included in the EpochRewards (Will be null for payments from the treasury or the reserves)
- Reward no longer coalesce rewards from the same epoch

### Features

* epoch rewards now includes the pool id of the pool that generated the reward ([96fd72b](https://github.com/input-output-hk/cardano-js-sdk/commit/96fd72bba7b087a74eb2080f0cc6ed7c1c2a7329))

## [0.10.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.10.5...@cardano-sdk/cardano-services-client@0.10.6) (2023-07-31)

**Note:** Version bump only for package @cardano-sdk/cardano-services-client

## [0.10.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.10.4...@cardano-sdk/cardano-services-client@0.10.5) (2023-07-13)

**Note:** Version bump only for package @cardano-sdk/cardano-services-client

## [0.10.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.10.3...@cardano-sdk/cardano-services-client@0.10.4) (2023-07-04)

### Bug Fixes

* **cardano-services-client:** background and profile image as ipfs url ([054b12f](https://github.com/input-output-hk/cardano-js-sdk/commit/054b12f6175d465ca60d3e756e924173e4a6061f))

## [0.10.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.10.2...@cardano-sdk/cardano-services-client@0.10.3) (2023-07-03)

### Bug Fixes

* **cardano-services-client:** type of KoraLabsHandleProvider to be implementing HandleProvider ([96f36da](https://github.com/input-output-hk/cardano-js-sdk/commit/96f36da478a27137a3353e50eedf06e02aebda17))

## [0.10.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.10.1...@cardano-sdk/cardano-services-client@0.10.2) (2023-06-29)

### Bug Fixes

* **cardano-services-client:** package.json import ([0293d14](https://github.com/input-output-hk/cardano-js-sdk/commit/0293d14d5ca2392b7c8580f6d701691324785710))

## [0.10.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.10.0...@cardano-sdk/cardano-services-client@0.10.1) (2023-06-29)

### Bug Fixes

* fix handle api response property names ([2ecc994](https://github.com/input-output-hk/cardano-js-sdk/commit/2ecc9940e738105e014a1451d4a5e5cd95df6277))

## [0.10.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.9.9...@cardano-sdk/cardano-services-client@0.10.0) (2023-06-28)

### ⚠ BREAKING CHANGES

* revert inclusion of version in the HttpProvider interface

### Features

* adds cardanoAddress type in HandleResolution interface ([2ee31c9](https://github.com/input-output-hk/cardano-js-sdk/commit/2ee31c9f0b61fc5e67385128448225d2d1d85617))
* implement verification and presubmission checks on handles in OgmiosTxProvider ([0f18042](https://github.com/input-output-hk/cardano-js-sdk/commit/0f1804287672968614e8aa6bf2f095b0e9a88b22))

### Bug Fixes

* revert inclusion of version in the HttpProvider interface ([3f50013](https://github.com/input-output-hk/cardano-js-sdk/commit/3f5001367686668806bfe967d3d7b6dd5e96dccc))

## [0.9.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.9.8...@cardano-sdk/cardano-services-client@0.9.9) (2023-06-23)

### Features

* add API and software version HTTP headers ([2e9664f](https://github.com/input-output-hk/cardano-js-sdk/commit/2e9664fcaff56adcfa4f21eb2b71b2fb6a3b411d))

### Bug Fixes

* handle undefined state on HandleResolution ([#774](https://github.com/input-output-hk/cardano-js-sdk/issues/774)) ([5e5fee3](https://github.com/input-output-hk/cardano-js-sdk/commit/5e5fee38fceb6312e5371bf594e5422ce2dcb7bf))

## [0.9.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.9.7...@cardano-sdk/cardano-services-client@0.9.8) (2023-06-20)

### Features

* **cardano-services-client:** add handle http provider ([4cc6b4a](https://github.com/input-output-hk/cardano-js-sdk/commit/4cc6b4abf523d5d0643836abfded8a9befccbf3a))
* map out optional properties from Koralab api response ([1efd986](https://github.com/input-output-hk/cardano-js-sdk/commit/1efd9862686136fd5c106ddc56e126e8b0da8868))

## [0.9.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.9.6...@cardano-sdk/cardano-services-client@0.9.7) (2023-06-13)

**Note:** Version bump only for package @cardano-sdk/cardano-services-client

## [0.9.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.9.5...@cardano-sdk/cardano-services-client@0.9.6) (2023-06-12)

**Note:** Version bump only for package @cardano-sdk/cardano-services-client

## [0.9.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.9.4...@cardano-sdk/cardano-services-client@0.9.5) (2023-06-06)

**Note:** Version bump only for package @cardano-sdk/cardano-services-client

## [0.9.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.9.3...@cardano-sdk/cardano-services-client@0.9.4) (2023-06-05)

**Note:** Version bump only for package @cardano-sdk/cardano-services-client

## [0.9.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.9.2...@cardano-sdk/cardano-services-client@0.9.3) (2023-06-01)

### Features

* **cardano-services-client:** add KoraLabsHandleProvider ([746e311](https://github.com/input-output-hk/cardano-js-sdk/commit/746e3114b2090d48151d8fd2cc9f7913dbe42adf))

## [0.9.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.9.1...@cardano-sdk/cardano-services-client@0.9.2) (2023-05-24)

**Note:** Version bump only for package @cardano-sdk/cardano-services-client

## [0.9.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.9.0...@cardano-sdk/cardano-services-client@0.9.1) (2023-05-22)

**Note:** Version bump only for package @cardano-sdk/cardano-services-client

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.8.0...@cardano-sdk/cardano-services-client@0.9.0) (2023-05-02)

### ⚠ BREAKING CHANGES

- rename AssetInfo 'quantity' to 'supply'
- - `TokenMetadata` has new mandatory property `assetId`

* `DbSyncAssetProvider` constructor requires new
  `DbSyncAssetProviderProp` object as first positional argument
* `createAssetsService` accepts an array of assetIds instead of a
  single assetId

### Features

- support assets fetching by ids ([8ed208a](https://github.com/input-output-hk/cardano-js-sdk/commit/8ed208a7a060c6999294c1f53266d6452adb278d))

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))

### Code Refactoring

- rename AssetInfo 'quantity' to 'supply' ([6e28df4](https://github.com/input-output-hk/cardano-js-sdk/commit/6e28df412797974b8ce6f6deb0c3346ff5938a05))

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.7.2...@cardano-sdk/cardano-services-client@0.8.0) (2023-03-13)

### ⚠ BREAKING CHANGES

- core type for address string reprensetation 'Address' renamed to PaymentAddress

### Code Refactoring

- core type for address string reprensetation 'Address' renamed to PaymentAddress ([4287463](https://github.com/input-output-hk/cardano-js-sdk/commit/42874633de6069510efdc57323f61140d22ed203))

## [0.7.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.7.1...@cardano-sdk/cardano-services-client@0.7.2) (2023-03-01)

**Note:** Version bump only for package @cardano-sdk/cardano-services-client

## [0.7.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services-client@0.7.0...@cardano-sdk/cardano-services-client@0.7.1) (2023-02-17)

### Bug Fixes

- **cardano-services:** updated http provider error handling ([#514](https://github.com/input-output-hk/cardano-js-sdk/issues/514)) ([33a4867](https://github.com/input-output-hk/cardano-js-sdk/commit/33a48670490fa998cef0196eb71492103105dcf7))

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
