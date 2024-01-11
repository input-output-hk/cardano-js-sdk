# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.15.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.15.4...@cardano-sdk/ogmios@0.15.5) (2023-12-20)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.15.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.15.3...@cardano-sdk/ogmios@0.15.4) (2023-12-14)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.15.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.15.2...@cardano-sdk/ogmios@0.15.3) (2023-12-12)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.15.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.15.1...@cardano-sdk/ogmios@0.15.2) (2023-12-07)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.15.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.15.0...@cardano-sdk/ogmios@0.15.1) (2023-12-04)

### Features

* **ogmios:** map ogmiosTxSubmit errors to new error types ([18fde67](https://github.com/input-output-hk/cardano-js-sdk/commit/18fde6789af04002ed599d9a2e68aec52ba27988))

## [0.15.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.14.0...@cardano-sdk/ogmios@0.15.0) (2023-11-29)

### ⚠ BREAKING CHANGES

* stake registration and deregistration certificates now take a Credential instead of key hash

### Features

* stake registration and deregistration certificates now take a Credential instead of key hash ([49612f0](https://github.com/input-output-hk/cardano-js-sdk/commit/49612f0f313f357e7e2a7eed406852cbd2bb3dec))

### Bug Fixes

* **ogmios:** don't parse alonzo datum hashes as inline datums ([2be3c78](https://github.com/input-output-hk/cardano-js-sdk/commit/2be3c78cd7c06934f934b94dfa1e00b92775a793))

## [0.14.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.13.3...@cardano-sdk/ogmios@0.14.0) (2023-10-19)

### ⚠ BREAKING CHANGES

* hoist ReconnectionConfig type from ogmios to util-rxjs

### Code Refactoring

* hoist ReconnectionConfig type from ogmios to util-rxjs ([704b5d6](https://github.com/input-output-hk/cardano-js-sdk/commit/704b5d6c82e6290c5f08800311d36d1b5d7a1eeb))

## [0.13.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.13.2...@cardano-sdk/ogmios@0.13.3) (2023-10-12)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.13.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.13.1...@cardano-sdk/ogmios@0.13.2) (2023-10-09)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.13.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.13.0...@cardano-sdk/ogmios@0.13.1) (2023-09-29)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.13.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.18...@cardano-sdk/ogmios@0.13.0) (2023-09-20)

### ⚠ BREAKING CHANGES

* renamed field handle to handleResolutions
* incompatible with previous revisions of cardano-services
- rename utxo and transactions PouchDB stores
- update type of Tx.witness.redeemers
- update type of Tx.witness.datums
- update type of TxOut.datum
- remove Cardano.Datum type

fix(cardano-services): correct chain history openApi endpoints path url to match version

### Features

* **core:** added custom PlutusData serialization classes ([72e600c](https://github.com/input-output-hk/cardano-js-sdk/commit/72e600c9e3d9502862121a69408cff9ef4c0d8e9))
* update core types with deserialized PlutusData ([d8cc93b](https://github.com/input-output-hk/cardano-js-sdk/commit/d8cc93b520177c98224502aad39109a0cb524f3c))

### Bug Fixes

* correct ogmiosToCore auxiliaryData mapping ([eb0ddc0](https://github.com/input-output-hk/cardano-js-sdk/commit/eb0ddc03048680eb91ffc1cb17683c4993a00f85))
* **util:** deserialize bytes as Uint8Array instead of Buffer ([78460d3](https://github.com/input-output-hk/cardano-js-sdk/commit/78460d36c6c7b75815b0d5fce1303b5dde91f3b6))

### Code Refactoring

* renamed field handle to handleResolutions ([8b3296e](https://github.com/input-output-hk/cardano-js-sdk/commit/8b3296e19b27815f3a8487479a691483696cc898))

## [0.12.18](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.17...@cardano-sdk/ogmios@0.12.18) (2023-09-12)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.17](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.16...@cardano-sdk/ogmios@0.12.17) (2023-08-29)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.16](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.15...@cardano-sdk/ogmios@0.12.16) (2023-08-21)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.15](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.14...@cardano-sdk/ogmios@0.12.15) (2023-08-15)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.14](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.13...@cardano-sdk/ogmios@0.12.14) (2023-08-11)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.13](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.12...@cardano-sdk/ogmios@0.12.13) (2023-07-31)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.12](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.11...@cardano-sdk/ogmios@0.12.12) (2023-07-17)

### Bug Fixes

* **ogmios:** poll systemStart and genesisConfig while it's unavailable in current era ([87f7c9c](https://github.com/input-output-hk/cardano-js-sdk/commit/87f7c9c0261d0a39d12a0b975b1df8eb2b038464))

## [0.12.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.10...@cardano-sdk/ogmios@0.12.11) (2023-07-13)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.9...@cardano-sdk/ogmios@0.12.10) (2023-07-04)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.8...@cardano-sdk/ogmios@0.12.9) (2023-07-03)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.7...@cardano-sdk/ogmios@0.12.8) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.6...@cardano-sdk/ogmios@0.12.7) (2023-06-29)

### Bug Fixes

* **util:** add ServerNotReady to list of connection errors ([c7faf01](https://github.com/input-output-hk/cardano-js-sdk/commit/c7faf01194561b2941c42c4a74517de0a5a9f7d9))

## [0.12.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.5...@cardano-sdk/ogmios@0.12.6) (2023-06-28)

### Features

* implement verification and presubmission checks on handles in OgmiosTxProvider ([0f18042](https://github.com/input-output-hk/cardano-js-sdk/commit/0f1804287672968614e8aa6bf2f095b0e9a88b22))

## [0.12.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.4...@cardano-sdk/ogmios@0.12.5) (2023-06-23)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.3...@cardano-sdk/ogmios@0.12.4) (2023-06-20)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.2...@cardano-sdk/ogmios@0.12.3) (2023-06-13)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.1...@cardano-sdk/ogmios@0.12.2) (2023-06-12)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.12.0...@cardano-sdk/ogmios@0.12.1) (2023-06-06)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.12.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.11.3...@cardano-sdk/ogmios@0.12.0) (2023-06-05)

### ⚠ BREAKING CHANGES

* hoist Cardano.Percent to util package

### Code Refactoring

* hoist Cardano.Percent to util package ([e4da0e3](https://github.com/input-output-hk/cardano-js-sdk/commit/e4da0e3851a4bdfd503c1f195c5ba1455ea6675b))

## [0.11.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.11.2...@cardano-sdk/ogmios@0.11.3) (2023-06-01)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.11.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.11.1...@cardano-sdk/ogmios@0.11.2) (2023-05-24)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.11.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.11.0...@cardano-sdk/ogmios@0.11.1) (2023-05-22)

**Note:** Version bump only for package @cardano-sdk/ogmios

## [0.11.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.10.0...@cardano-sdk/ogmios@0.11.0) (2023-05-02)

### ⚠ BREAKING CHANGES

- - auxiliaryDataHash is now included in the TxBody core type.

* networkId is now included in the TxBody core type.
* auxiliaryData no longer contains the optional hash field.
* auxiliaryData no longer contains the optional body field.

### Features

- add healthCheck$ to ObservableCardanoNode ([df35035](https://github.com/input-output-hk/cardano-js-sdk/commit/df3503597832939e6dc9c7ec953d24b3d709c723))
- **ogmios:** log successful transaction submission with info level ([a7d98f4](https://github.com/input-output-hk/cardano-js-sdk/commit/a7d98f40dbbccca8276a029a10c5e5e9d42ec76e))
- **ogmios:** ogmios TxSubmit client now uses a long-running ws connection ([36ee96c](https://github.com/input-output-hk/cardano-js-sdk/commit/36ee96c580f79a4f2759fa9bc87a69bf088e5ed9))
- transaction body core type now includes the auxiliaryDataHash and networkId fields ([8b92b01](https://github.com/input-output-hk/cardano-js-sdk/commit/8b92b0190083a2b956ae1e188121414428f6663b))

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))

## [0.10.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.9.0...@cardano-sdk/ogmios@0.10.0) (2023-03-13)

### ⚠ BREAKING CHANGES

- add new Address types that implement CIP-19 natively
- core type for address string reprensetation 'Address' renamed to PaymentAddress

### Features

- add inputSource in transactions ([7ed99d5](https://github.com/input-output-hk/cardano-js-sdk/commit/7ed99d5a12cf8667114c76ecde0cbdc3cfbc3887))
- add new Address types that implement CIP-19 natively ([a892176](https://github.com/input-output-hk/cardano-js-sdk/commit/a8921760b714b090bb6c15d6b4696e2dd0b2fdc5))

### Code Refactoring

- core type for address string reprensetation 'Address' renamed to PaymentAddress ([4287463](https://github.com/input-output-hk/cardano-js-sdk/commit/42874633de6069510efdc57323f61140d22ed203))

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.8.0...@cardano-sdk/ogmios@0.9.0) (2023-03-01)

### Features

- **ogmios:** add OgmiosObservableCardanoNode ([b1c7785](https://github.com/input-output-hk/cardano-js-sdk/commit/b1c7785c2b7cd554dc1adf9cf90db5897e4eaebc))
- **ogmios:** export ogmiosToCore.eraSummary ([412b674](https://github.com/input-output-hk/cardano-js-sdk/commit/412b674ffc82d38e94881fa248aa0d89d9693973))

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/ogmios@0.7.0...@cardano-sdk/ogmios@0.8.0) (2023-02-17)

### ⚠ BREAKING CHANGES

- - Bip32PublicKey removed from core and replaced by the Bip32PublicKeyHex type from the crypto package.

* Bip32PrivateKey removed from core and replaced by the Bip32PrivateKeyHex type from the crypto package.
* Ed25519PublicKey removed from core and replaced by the Ed25519PublicKeyHex type from the crypto package.
* Ed25519PrivateKey removed from core and replaced by the Ed25519PrivateKeyHex type from the crypto package.
* Ed25519KeyHash removed from core and replaced by the Ed25519KeyHashHex type from the the crypto package.
* Ed25519Signature removed from core and replaced by the Ed25519SignatureHex type from the crypto package.
* Hash32ByteBase16 removed from core and replaced by the Hash32ByteBase16 type from the crypto package.
* Hash28ByteBase16 removed from core and replaced by the Hash28ByteBase16 type from the crypto package.
* The KeyAgent interface now has a new field bip32Ed25519.
* The KeyAgentBase class and all its derived classes (InMemoryKeyAgent, LedgerKeyAgent and TrezorKeyAgent) must now be provided with a Bip32Ed25519 implementation on their constructors.
* Bip32Path type was removed from the key-management package and replaced by the Bip32Path from the crypto package.

- hoist Opaque types, hexBlob, Base64Blob and related utils
- CompactGenesis.slotLength type changed
  from `number` to `Seconds`
- EraSummary.parameters.slotLength type changed from number
  to Milliseconds
- - all provider constructors are updated to use standardized form of deps

### Features

- update CompactGenesis slotLength type to be Seconds ([82e63d6](https://github.com/input-output-hk/cardano-js-sdk/commit/82e63d6cacedbab5ecf8491dfd37749bfeddbc22))
- update EraSummary slotLength type to be Milliseconds ([fb1f1a2](https://github.com/input-output-hk/cardano-js-sdk/commit/fb1f1a2c4fb77d03e45f9255c182e9bc54583324))

### Code Refactoring

- hoist Opaque types, hexBlob, Base64Blob and related utils ([391a8f2](https://github.com/input-output-hk/cardano-js-sdk/commit/391a8f20d60607c4fb6ce8586b97ae96841f759b))
- refactor the SDK to use the new crypto package ([3b41320](https://github.com/input-output-hk/cardano-js-sdk/commit/3b41320e7971a231d50785733ff4cd0793418d3d))
- standardize provider dependencies ([05b37e6](https://github.com/input-output-hk/cardano-js-sdk/commit/05b37e6383a906152df457143c5a27341a11c341))

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
