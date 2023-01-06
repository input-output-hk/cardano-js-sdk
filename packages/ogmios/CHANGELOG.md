# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.6.0...@cardano-sdk/ogmios@0.7.0) (2022-12-22)

### ⚠ BREAKING CHANGES

- Alonzo transaction outputs will now contain a datumHash field, carrying the datum hash digest. However, they will also contain a datum field with the exact same value for backward compatibility reason. In Babbage however, transaction outputs will carry either datum or datumHash depending on the case; and datum will only contain inline datums.
- use titlecase for mainnet/testnet in NetworkId
- - rename `redeemer.scriptHash` to `redeemer.data` in core

* change the type from `Hash28ByteBase16` to `HexBlob`

- - BlockSize is now an OpaqueNumber rather than a type alias for number

* BlockNo is now an OpaqueNumber rather than a type alias for number
* EpochNo is now an OpaqueNumber rather than a type alias for number
* Slot is now an OpaqueNumber rather than a type alias for number
* Percentage is now an OpaqueNumber rather than a type alias for number

- rename era-specific types in core
- rename block types

* CompactBlock -> BlockInfo
* Block -> ExtendedBlockInfo

- hoist ogmiosToCore to ogmios package
- classify TxSubmission errors as variant of CardanoNode error

### Features

- add opaque numeric types to core package ([9ead8bd](https://github.com/input-output-hk/cardano-js-sdk/commit/9ead8bdb34b7ffc57c32f9ab18a6c6ca14af3fda))
- added new babbage era types in Transactions and Outputs ([0b1f2ff](https://github.com/input-output-hk/cardano-js-sdk/commit/0b1f2ffaad2edec281d206a6865cd1e6053d9826))
- adds projected tip to the db sync based providers's health check response ([eb76414](https://github.com/input-output-hk/cardano-js-sdk/commit/eb76414d5796d6009611ba848e8d5c5fdffa46e4))
- implement ogmiosToCore certificates mapping ([aef2e8d](https://github.com/input-output-hk/cardano-js-sdk/commit/aef2e8d64da9352c6aab206034950d64f44e9559))
- **ogmios:** add ogmiosToCore.blockHeader ([08fc7dc](https://github.com/input-output-hk/cardano-js-sdk/commit/08fc7dc958f30411136c660d8f9759487dba431c))
- **ogmios:** add ogmiosToCore.genesis ([c48f6d4](https://github.com/input-output-hk/cardano-js-sdk/commit/c48f6d4eba896861b6e35ff39571bc261bafa991))
- **ogmios:** complete Ogmios tx to core mapping ([bcac56b](https://github.com/input-output-hk/cardano-js-sdk/commit/bcac56bbf943110703696e0854b2af2f5e2b1737))
- rename era-specific types in core ([c4955b1](https://github.com/input-output-hk/cardano-js-sdk/commit/c4955b1f3ae0992bb55b1c1461a1e449be0b6ef2))

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
- **ogmios:** map prevHash='genesis' to undefined ([ad47bbb](https://github.com/input-output-hk/cardano-js-sdk/commit/ad47bbba6d8eef5d46ae14d9976e31d54be9aab1))

### Code Refactoring

- change redeemer script hash to data ([a24bbb8](https://github.com/input-output-hk/cardano-js-sdk/commit/a24bbb80d57007352d64b5b99dbc7a19d4948208))
- classify TxSubmission errors as variant of CardanoNode error ([234305e](https://github.com/input-output-hk/cardano-js-sdk/commit/234305e28aefd3d9bd1736315bdf89ca31f7556f))
- use titlecase for mainnet/testnet in NetworkId ([252c589](https://github.com/input-output-hk/cardano-js-sdk/commit/252c589480d3e422b9021ea66a67af978fb80264))

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.5.0...@cardano-sdk/ogmios@0.6.0) (2022-11-04)

### ⚠ BREAKING CHANGES

- rework TxSubmitProvider to submit transactions as hex string instead of Buffer
- rework all provider signatures args from positional to a single object

### Features

- improve db health check query ([1595350](https://github.com/input-output-hk/cardano-js-sdk/commit/159535092033a745664c399ee1273da436fd3374))
- **ogmios:** createInteractionContextWithLogger util ([7602718](https://github.com/input-output-hk/cardano-js-sdk/commit/7602718ec65949d2a3dd17d3dfaeba782a6c22c9))

### Bug Fixes

- **ogmios:** correctly handle interaction context logging with createInteractionContextWithLogger ([9298ee0](https://github.com/input-output-hk/cardano-js-sdk/commit/9298ee0e6c98bef0c1aa4dc70f349094ec00a5c9))
- **ogmios:** correctly map era summary slotLength ([b3be517](https://github.com/input-output-hk/cardano-js-sdk/commit/b3be5174ca7759c76d64a4923efc5c004275e8df))

### Code Refactoring

- rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))
- rework TxSubmitProvider to submit transactions as hex string instead of Buffer ([032a1b7](https://github.com/input-output-hk/cardano-js-sdk/commit/032a1b7a11941d52b5baf0d447b615c58a294068))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.4.0...@cardano-sdk/ogmios@0.5.0) (2022-08-30)

### ⚠ BREAKING CHANGES

- replace `NetworkInfoProvider.timeSettings` with `eraSummaries`
- logger is now required

### Features

- extend HealthCheckResponse ([2e6d0a3](https://github.com/input-output-hk/cardano-js-sdk/commit/2e6d0a3d2067ce8538886f1a9d0d55fab7647ae9))
- ogmios cardano node DNS resolution ([d132c9f](https://github.com/input-output-hk/cardano-js-sdk/commit/d132c9f52485086a5cf797217d48c816ae51d2b3))
- replace `NetworkInfoProvider.timeSettings` with `eraSummaries` ([58f6fc7](https://github.com/input-output-hk/cardano-js-sdk/commit/58f6fc7c5ace703583c36f95d3d6962483ad924d))

### Code Refactoring

- logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/ogmios@0.4.0) (2022-07-25)

### Features

- **ogmios:** enriched the test mock to respond with beforeValidityInterval ([b56f9a8](https://github.com/input-output-hk/cardano-js-sdk/commit/b56f9a83b38d9c46dfa1d7008ab632f9a737b9ea))
- support any network by fetching time settings from the node ([08d9ed2](https://github.com/input-output-hk/cardano-js-sdk/commit/08d9ed2b6aa20cf4df2a063f046f4e5ca28c6bd5))

## 0.3.0 (2022-06-24)

### Features

- add Provider interface, use as base for TxSubmitProvider ([e155ed4](https://github.com/input-output-hk/cardano-js-sdk/commit/e155ed4efcd1338a54099d1a9034ccbeddeef1cc))
- **ogmios:** added submitTxHook to test mock server ([ccbddae](https://github.com/input-output-hk/cardano-js-sdk/commit/ccbddaefeae228b7b02160a6b2ef4e7e0995e689))
- **ogmios:** added urlToConnectionConfig function ([bd22262](https://github.com/input-output-hk/cardano-js-sdk/commit/bd22262cdac4d90561069fefe89028eaf01643a0))
- **ogmios:** export Ogmios client function for SDK access ([92af547](https://github.com/input-output-hk/cardano-js-sdk/commit/92af5472ceff52b747428c37c953ffd3c940d950))
- **ogmios:** exported listenPromise & serverClosePromise test functions ([354de85](https://github.com/input-output-hk/cardano-js-sdk/commit/354de855990b3cad66d61314d481f8063a346b6c))
- **ogmios:** package init and ogmiosTxSubmitProvider ([3b8461b](https://github.com/input-output-hk/cardano-js-sdk/commit/3b8461b2ca9081736c1495318be68deb0e12bd6b))

### Bug Fixes

- **ogmios:** fix failing tests ([3c8c5f7](https://github.com/input-output-hk/cardano-js-sdk/commit/3c8c5f746a41508006e9f059e138b70d9ea1baff))
- **ogmios:** tx submit provider ts error fix ([a24a78c](https://github.com/input-output-hk/cardano-js-sdk/commit/a24a78c5b2d8e75f0c99c12c47cf0b5eb3424b49))
