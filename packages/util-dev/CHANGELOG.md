# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.13.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.13.7...@cardano-sdk/util-dev@0.13.8) (2023-07-13)

**Note:** Version bump only for package @cardano-sdk/util-dev

## [0.13.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.13.6...@cardano-sdk/util-dev@0.13.7) (2023-07-04)

**Note:** Version bump only for package @cardano-sdk/util-dev

## [0.13.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.13.5...@cardano-sdk/util-dev@0.13.6) (2023-06-29)

### Features

* **util-dev:** add binds option to setup postgres container ([57040ca](https://github.com/input-output-hk/cardano-js-sdk/commit/57040cabca22644a6470a9e1a7d2d78adedca5c9))

## [0.13.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.13.4...@cardano-sdk/util-dev@0.13.5) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/util-dev

## [0.13.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.13.3...@cardano-sdk/util-dev@0.13.4) (2023-06-28)

### Features

* adds cardanoAddress type in HandleResolution interface ([2ee31c9](https://github.com/input-output-hk/cardano-js-sdk/commit/2ee31c9f0b61fc5e67385128448225d2d1d85617))
* implement verification and presubmission checks on handles in OgmiosTxProvider ([0f18042](https://github.com/input-output-hk/cardano-js-sdk/commit/0f1804287672968614e8aa6bf2f095b0e9a88b22))

## [0.13.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.13.2...@cardano-sdk/util-dev@0.13.3) (2023-06-23)

**Note:** Version bump only for package @cardano-sdk/util-dev

## [0.13.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.13.1...@cardano-sdk/util-dev@0.13.2) (2023-06-20)

**Note:** Version bump only for package @cardano-sdk/util-dev

## [0.13.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.13.0...@cardano-sdk/util-dev@0.13.1) (2023-06-13)

### Bug Fixes

* correct ledger mapping canonical asset and asset group ordering ([2095877](https://github.com/input-output-hk/cardano-js-sdk/commit/20958773d2885ee3e1934363dce96b4e8cea96a7))

## [0.13.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.12.1...@cardano-sdk/util-dev@0.13.0) (2023-06-12)

### ⚠ BREAKING CHANGES

* SignedTx.ctx now renamed to context

### Features

* add context to txSubmit ([57589ec](https://github.com/input-output-hk/cardano-js-sdk/commit/57589ecd3120573a0cea7e718291454e9b6f9f3b))

## [0.12.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.12.0...@cardano-sdk/util-dev@0.12.1) (2023-06-06)

### Features

* add ObservableWallet.handles$ that emits own handles ([1c3b532](https://github.com/input-output-hk/cardano-js-sdk/commit/1c3b532c9b9f4fe48ba1555749b21faa27648c1a))

## [0.12.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.11.1...@cardano-sdk/util-dev@0.12.0) (2023-06-05)

### ⚠ BREAKING CHANGES

* hoist Cardano.Percent to util package
* - remove `epochRewards` and type `StakePoolEpochRewards`
- remove `transactions` and type `StakePoolTransactions`

### Features

* add handle projection ([1d3f4ca](https://github.com/input-output-hk/cardano-js-sdk/commit/1d3f4ca3cfa3f1dfb668847de58eba4d0402d48e))
* add missing pool stats status ([6a59a78](https://github.com/input-output-hk/cardano-js-sdk/commit/6a59a78cff0eae3d965e62d65d8612a642dce8f8))

### Code Refactoring

* hoist Cardano.Percent to util package ([e4da0e3](https://github.com/input-output-hk/cardano-js-sdk/commit/e4da0e3851a4bdfd503c1f195c5ba1455ea6675b))
* remove unusable fields from StakePool core type ([a7aa17f](https://github.com/input-output-hk/cardano-js-sdk/commit/a7aa17fdd5224437555840d21f56c4660142c351))

## [0.11.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.11.0...@cardano-sdk/util-dev@0.11.1) (2023-06-01)

**Note:** Version bump only for package @cardano-sdk/util-dev

## [0.11.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.10.0...@cardano-sdk/util-dev@0.11.0) (2023-05-24)

### ⚠ BREAKING CHANGES

* the single address wallet now takes an additional dependency 'AddressDiscovery'

### Features

* the single address wallet now takes an additional dependency 'AddressDiscovery' ([d6d7cff](https://github.com/input-output-hk/cardano-js-sdk/commit/d6d7cffe3a7089af2aff39e78c491f4e0a06c989))

## [0.10.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.9.0...@cardano-sdk/util-dev@0.10.0) (2023-05-22)

### ⚠ BREAKING CHANGES

* **util-dev:** remove createStubLogger util

### Features

* **util-dev:** add stubProviders ([6d5d99c](https://github.com/input-output-hk/cardano-js-sdk/commit/6d5d99c80894a4b126647272f490d9e2c472d818))
* **util-dev:** remove createStubLogger util ([de06e4e](https://github.com/input-output-hk/cardano-js-sdk/commit/de06e4e46877116f7ceb1f04df920a351dd4724d))

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.8.0...@cardano-sdk/util-dev@0.9.0) (2023-05-02)

### ⚠ BREAKING CHANGES

- hoist patchObject from util-dev to util package

### Features

- add healthCheck$ to ObservableCardanoNode ([df35035](https://github.com/input-output-hk/cardano-js-sdk/commit/df3503597832939e6dc9c7ec953d24b3d709c723))
- expose configurable request timeout ([cea5379](https://github.com/input-output-hk/cardano-js-sdk/commit/cea5379e77afda47c2b10f5f9ad66695637f5a01))
- **util-dev:** add new chainSync dataset (WithMint) ([1a22f8a](https://github.com/input-output-hk/cardano-js-sdk/commit/1a22f8af04210968d2a4680334e3a82636846835))
- **util-dev:** update retirement chain sync dataset ([4ae30a7](https://github.com/input-output-hk/cardano-js-sdk/commit/4ae30a79426cb4726fa2c7eb2955a5aa4c8aac95))

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))
- **util-dev:** change hash of replayed block after rollback ([3d8c558](https://github.com/input-output-hk/cardano-js-sdk/commit/3d8c5583fb631c30bb9a933c8a401254e3a8aa4b))
- **util-dev:** transform chainSyncData with fromSerializableObject ([91d6b92](https://github.com/input-output-hk/cardano-js-sdk/commit/91d6b9221a1f9531150a615a68511e6178c891b6))

### Code Refactoring

- hoist patchObject from util-dev to util package ([bea7e03](https://github.com/input-output-hk/cardano-js-sdk/commit/bea7e035ebdcd7241b6f3cc8feb5fbcfdb90fa46))

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.7.1...@cardano-sdk/util-dev@0.8.0) (2023-03-13)

### ⚠ BREAKING CHANGES

- core type for address string reprensetation 'Address' renamed to PaymentAddress

### Features

- **util-dev:** add DockerUtil (hoisted from cardano-services tests) ([ccb86ab](https://github.com/input-output-hk/cardano-js-sdk/commit/ccb86ab3ad8f0ae3c73a3c36173b1f76c0704f6d))
- **util-dev:** add patchObject test util ([17afde8](https://github.com/input-output-hk/cardano-js-sdk/commit/17afde825ed7a092e770c0058161f71e55ba471b))

### Code Refactoring

- core type for address string reprensetation 'Address' renamed to PaymentAddress ([4287463](https://github.com/input-output-hk/cardano-js-sdk/commit/42874633de6069510efdc57323f61140d22ed203))

## [0.7.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.7.0...@cardano-sdk/util-dev@0.7.1) (2023-03-01)

**Note:** Version bump only for package @cardano-sdk/util-dev

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.6.0...@cardano-sdk/util-dev@0.7.0) (2023-02-17)

### ⚠ BREAKING CHANGES

- reworks stake pool epoch rewards fields to be ledger compliant
- EraSummary.parameters.slotLength type changed from number
  to Milliseconds

### Features

- update EraSummary slotLength type to be Milliseconds ([fb1f1a2](https://github.com/input-output-hk/cardano-js-sdk/commit/fb1f1a2c4fb77d03e45f9255c182e9bc54583324))
- **util-dev:** adds a reset method to test logger to reset recorded logged messages ([4ebe552](https://github.com/input-output-hk/cardano-js-sdk/commit/4ebe5524ee0d95c314520c25f6a9a42c6957fbc3))

### Code Refactoring

- reworks stake pool epoch rewards fields to be ledger compliant ([a9ff583](https://github.com/input-output-hk/cardano-js-sdk/commit/a9ff583d26fe427c2816ab286bb3ae4aeacc9301))

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.5.0...@cardano-sdk/util-dev@0.6.0) (2022-12-22)

### ⚠ BREAKING CHANGES

- moved testnetEraSummaries to util-dev package
- - BlockSize is now an OpaqueNumber rather than a type alias for number

* BlockNo is now an OpaqueNumber rather than a type alias for number
* EpochNo is now an OpaqueNumber rather than a type alias for number
* Slot is now an OpaqueNumber rather than a type alias for number
* Percentage is now an OpaqueNumber rather than a type alias for number

### Features

- add opaque numeric types to core package ([9ead8bd](https://github.com/input-output-hk/cardano-js-sdk/commit/9ead8bdb34b7ffc57c32f9ab18a6c6ca14af3fda))

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))

### Code Refactoring

- moved testnetEraSummaries to util-dev package ([5ad0514](https://github.com/input-output-hk/cardano-js-sdk/commit/5ad0514846dd2d186eb04c29821d987c6409a5c2))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.4.1...@cardano-sdk/util-dev@0.5.0) (2022-11-04)

### ⚠ BREAKING CHANGES

- free CSL resources using freeable util
- make stake pools pagination a required arg
- rework all provider signatures args from positional to a single object

### Features

- create common mock server util ([53bd4f7](https://github.com/input-output-hk/cardano-js-sdk/commit/53bd4f7de87406a8d3623c903847268e57d0ddeb))
- make stake pools pagination a required arg ([6cf8206](https://github.com/input-output-hk/cardano-js-sdk/commit/6cf8206be2162db7196794f7252e5cbb84b65c77))

### Bug Fixes

- free CSL resources using freeable util ([5ce0056](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce0056fb108f7bccfbd9f8ef562b82277f3c613))

### Code Refactoring

- rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))

## [0.4.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util-dev@0.4.0...@cardano-sdk/util-dev@0.4.1) (2022-08-30)

### Features

- **util-dev:** add test logger object ([d0453e3](https://github.com/input-output-hk/cardano-js-sdk/commit/d0453e30ac1381f98295394453c038e881ba77a9))

### Bug Fixes

- **util-dev:** rm TestLogger dependency on 'stream' for browser compat ([297a27e](https://github.com/input-output-hk/cardano-js-sdk/commit/297a27e089dff5a8dd0dfa33835d4982db370801))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/util-dev@0.4.0) (2022-07-25)

## 0.3.0 (2022-06-24)

### ⚠ BREAKING CHANGES

- move stakePoolStats from wallet provider to stake pool provider
- rename `StakePoolSearchProvider` to `StakePoolProvider`
- remove TimeSettingsProvider and NetworkInfo.currentEpoch
- change TimeSettings interface from fn to obj
- **util-dev:** rename mock minimumCost to minimumCostCoefficient

### Features

- add totalResultCount to StakePoolSearch response ([4265f6a](https://github.com/input-output-hk/cardano-js-sdk/commit/4265f6af60a92c93604b93167fd297530b6e01f8))
- **cardano-graphql-services:** module logger ([d93a121](https://github.com/input-output-hk/cardano-js-sdk/commit/d93a121c626e7c9ce060d575802bc2775cf875e3))
- **cardano-services:** stake pool search http server ([c3dd013](https://github.com/input-output-hk/cardano-js-sdk/commit/c3dd0133843327906535ce2ac623482cf95dd397))
- **util-dev:** add createStubTimeSettingsProvider ([d19321b](https://github.com/input-output-hk/cardano-js-sdk/commit/d19321b515387f8943f7e0df88b0173c71c46ffb))
- **util-dev:** add createStubUtxoProvider ([ac4156d](https://github.com/input-output-hk/cardano-js-sdk/commit/ac4156d6b74ce05daf11e5feeceef9c941973020))
- **util-dev:** add utils to create TxIn/TxOut/Utxo, refactor SelectionConstraints to use core types ([021087e](https://github.com/input-output-hk/cardano-js-sdk/commit/021087e7d3b0ca3de0fbc1bdc9438a6a00a4a07e))

### Bug Fixes

- rm imports from @cardano-sdk/_/src/_ ([3fdead3](https://github.com/input-output-hk/cardano-js-sdk/commit/3fdead3ae381a3efb98299b9881c6a964461b7db))

### Code Refactoring

- change TimeSettings interface from fn to obj ([bc3b22d](https://github.com/input-output-hk/cardano-js-sdk/commit/bc3b22d55071f85073c54dcf47c535912bedb512))
- move stakePoolStats from wallet provider to stake pool provider ([52d71a7](https://github.com/input-output-hk/cardano-js-sdk/commit/52d71a70700b05902cca6205fe01a63f811ba5af))
- remove TimeSettingsProvider and NetworkInfo.currentEpoch ([4a8f72f](https://github.com/input-output-hk/cardano-js-sdk/commit/4a8f72f57f699f7c0bf4a9a4b742fc0a3e4aa8ce))
- rename `StakePoolSearchProvider` to `StakePoolProvider` ([b432103](https://github.com/input-output-hk/cardano-js-sdk/commit/b43210348da7914664733f85f8be8999271a8667))
- **util-dev:** rename mock minimumCost to minimumCostCoefficient ([1632c1d](https://github.com/input-output-hk/cardano-js-sdk/commit/1632c1d9775dec97edf815816017b7f6714dcd4d))

### 0.1.5 (2021-10-27)

### Features

- **util-dev:** add createStubStakePoolSearchProvider ([2e0906b](https://github.com/input-output-hk/cardano-js-sdk/commit/2e0906bc19acdf91b805e1eb647e88aa33ed1b7b))
- **util-dev:** add flushPromises util ([19eb508](https://github.com/input-output-hk/cardano-js-sdk/commit/19eb508af9c5364f9db604cfe4705857cd62f720))

### 0.1.3 (2021-10-05)
