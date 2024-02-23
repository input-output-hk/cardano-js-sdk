# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.11.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.11.5...@cardano-sdk/projection@0.11.6) (2024-02-23)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.11.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.11.4...@cardano-sdk/projection@0.11.5) (2024-02-12)

### Bug Fixes

* **projection:** do not throw when encountering a handle with invalid name ([726f945](https://github.com/input-output-hk/cardano-js-sdk/commit/726f945e25dd2eef67c37fbafff6e1863dcb11f2))

## [0.11.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.11.3...@cardano-sdk/projection@0.11.4) (2024-02-08)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.11.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.11.2...@cardano-sdk/projection@0.11.3) (2024-02-07)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.11.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.11.1...@cardano-sdk/projection@0.11.2) (2024-02-02)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.11.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.11.0...@cardano-sdk/projection@0.11.1) (2024-02-02)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.11.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.10.9...@cardano-sdk/projection@0.11.0) (2024-01-31)

### ⚠ BREAKING CHANGES

* typo stakeKeyCertficates renamed to stakeKeyCertificates

### Features

* use new conway certs in stake and delegation scenarios ([3a59317](https://github.com/input-output-hk/cardano-js-sdk/commit/3a5931702ab6aeb5a62b18d2834125ce6fbfc594))

## [0.10.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.10.8...@cardano-sdk/projection@0.10.9) (2024-01-25)

### Bug Fixes

* **projection:** log moving average speeds even if after a restart ([87559e2](https://github.com/input-output-hk/cardano-js-sdk/commit/87559e2041baaa1f1a402e1472816ce3a8c22d48))

## [0.10.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.10.7...@cardano-sdk/projection@0.10.8) (2024-01-17)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.10.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.10.6...@cardano-sdk/projection@0.10.7) (2024-01-05)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.10.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.10.5...@cardano-sdk/projection@0.10.6) (2023-12-21)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.10.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.10.4...@cardano-sdk/projection@0.10.5) (2023-12-20)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.10.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.10.3...@cardano-sdk/projection@0.10.4) (2023-12-14)

### Features

* include minted assets in cip67 mapper to ensure minted assets can be collected in withHandles mapper ([8e1b834](https://github.com/input-output-hk/cardano-js-sdk/commit/8e1b834181e909d4cb4c8608a29392716ae5a4b8))
* update Handle entity and HandleStore to save parent handles ([3fa3920](https://github.com/input-output-hk/cardano-js-sdk/commit/3fa3920088857d5019d732a036fc3a89b90d5ab3))

## [0.10.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.10.2...@cardano-sdk/projection@0.10.3) (2023-12-12)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.10.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.10.1...@cardano-sdk/projection@0.10.2) (2023-12-07)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.10.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.10.0...@cardano-sdk/projection@0.10.1) (2023-12-04)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.10.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.9.0...@cardano-sdk/projection@0.10.0) (2023-11-29)

### ⚠ BREAKING CHANGES

* stake registration and deregistration certificates now take a Credential instead of key hash

### Features

* stake registration and deregistration certificates now take a Credential instead of key hash ([49612f0](https://github.com/input-output-hk/cardano-js-sdk/commit/49612f0f313f357e7e2a7eed406852cbd2bb3dec))

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.8.3...@cardano-sdk/projection@0.9.0) (2023-10-19)

### ⚠ BREAKING CHANGES

* simplify StabilityWindowBuffer interface to just 'getBlock'
- Bootstrap.fromCardanoNode now requires Tip observable parameter

### Features

* do not write to stability window buffer til volatile ([b2244ea](https://github.com/input-output-hk/cardano-js-sdk/commit/b2244eac56352961c36ef9e80038aead47ee9e52))

## [0.8.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.8.2...@cardano-sdk/projection@0.8.3) (2023-10-12)

### Features

* **projection:** add helper to especifically store UTXO's with assets ([ca95728](https://github.com/input-output-hk/cardano-js-sdk/commit/ca95728ac54e31e13588eb94e235ffba75781a84))

## [0.8.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.8.1...@cardano-sdk/projection@0.8.2) (2023-10-09)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.8.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.8.0...@cardano-sdk/projection@0.8.1) (2023-09-29)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.7.4...@cardano-sdk/projection@0.8.0) (2023-09-20)

### ⚠ BREAKING CHANGES

* make withHandles 'logger' argument required
* withHandles now requires WithCIP67 props in
* rename Mappers.Handle type to HandleOwnership
* incompatible with previous revisions of cardano-services
- rename utxo and transactions PouchDB stores
- update type of Tx.witness.redeemers
- update type of Tx.witness.datums
- update type of TxOut.datum
- remove Cardano.Datum type

fix(cardano-services): correct chain history openApi endpoints path url to match version

### Features

* add address projection ([416e5f5](https://github.com/input-output-hk/cardano-js-sdk/commit/416e5f5edc112727d86e0905733f7f6c1c2fd4c5))
* add NFT metadata projection ([91fe7df](https://github.com/input-output-hk/cardano-js-sdk/commit/91fe7df50a37bce2ac8cba350fafe788a8174112))
* **projection:** add cip67.byAssetId ([060ac99](https://github.com/input-output-hk/cardano-js-sdk/commit/060ac99315ae3339d4e208f5578d587cf35a7dc2))
* **projection:** add withHandleMetadata mapper ([9fc4722](https://github.com/input-output-hk/cardano-js-sdk/commit/9fc47227d37e00718d39fb3027e93bf419ab5644))
* **projection:** ignore burn transactions when projecting cip25 metadata ([ab8bb29](https://github.com/input-output-hk/cardano-js-sdk/commit/ab8bb292d6a2065919d4ac9616ad501968e235d4))
* **projection:** map 'extra' data with Mappers.withNftMetadata ([892c2eb](https://github.com/input-output-hk/cardano-js-sdk/commit/892c2eb5f955cda5d0698a1c5e493e64845ce0af))
* update core types with deserialized PlutusData ([d8cc93b](https://github.com/input-output-hk/cardano-js-sdk/commit/d8cc93b520177c98224502aad39109a0cb524f3c))

### Bug Fixes

* correct cip68 handle name (without label) ([1711969](https://github.com/input-output-hk/cardano-js-sdk/commit/171196916244d0bcde83b18d509669c2c38a0d63))
* **projection:** infer incoming event type for withNftMetadata ([53cd873](https://github.com/input-output-hk/cardano-js-sdk/commit/53cd8739d94a4bbc8d856b046c7ce8db700a6561))
* **projection:** keep latest nft metadata ([3f8242a](https://github.com/input-output-hk/cardano-js-sdk/commit/3f8242a52d26775958a89517287dacbd4cae06f2))

### Code Refactoring

* make withHandles 'logger' argument required ([2267689](https://github.com/input-output-hk/cardano-js-sdk/commit/22676895735bde4399e284e60a8e4e7cf2d4a506))
* rename Mappers.Handle type to HandleOwnership ([4cb2f55](https://github.com/input-output-hk/cardano-js-sdk/commit/4cb2f551bc7c9ab883a3088a41c047dad866be92))

## [0.7.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.7.3...@cardano-sdk/projection@0.7.4) (2023-09-12)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.7.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.7.2...@cardano-sdk/projection@0.7.3) (2023-08-29)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.7.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.7.1...@cardano-sdk/projection@0.7.2) (2023-08-21)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.7.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.7.0...@cardano-sdk/projection@0.7.1) (2023-08-15)

### Features

* add a buffer after reading blocks from ogmios ([0095c80](https://github.com/input-output-hk/cardano-js-sdk/commit/0095c80346fb0f5ce7bfa7fe805c6b0e79ad1a35))

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.17...@cardano-sdk/projection@0.7.0) (2023-08-11)

### ⚠ BREAKING CHANGES

* replace Mappers.CertificatePointer with Cardano.Pointer

### Features

* **projection:** add 10k and 100k moving avgs speed and eta ([53f15d4](https://github.com/input-output-hk/cardano-js-sdk/commit/53f15d4b9895d50fd0c17f5bfdbd22c717d08c94))

### Code Refactoring

* replace Mappers.CertificatePointer with Cardano.Pointer ([cb7279e](https://github.com/input-output-hk/cardano-js-sdk/commit/cb7279e2a80d48ea870a625db47941f097dace34))

## [0.6.17](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.16...@cardano-sdk/projection@0.6.17) (2023-07-31)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.6.16](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.15...@cardano-sdk/projection@0.6.16) (2023-07-17)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.6.15](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.14...@cardano-sdk/projection@0.6.15) (2023-07-13)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.6.14](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.13...@cardano-sdk/projection@0.6.14) (2023-07-04)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.6.13](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.12...@cardano-sdk/projection@0.6.13) (2023-07-03)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.6.12](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.11...@cardano-sdk/projection@0.6.12) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.6.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.10...@cardano-sdk/projection@0.6.11) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.6.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.9...@cardano-sdk/projection@0.6.10) (2023-06-28)

### Bug Fixes

* unsupported character bug in handles projection ([4144ed2](https://github.com/input-output-hk/cardano-js-sdk/commit/4144ed2925f1c5b118c411ac5eedc3e4a62d3893))

## [0.6.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.8...@cardano-sdk/projection@0.6.9) (2023-06-23)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.6.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.7...@cardano-sdk/projection@0.6.8) (2023-06-20)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.6.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.6...@cardano-sdk/projection@0.6.7) (2023-06-13)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.6.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.5...@cardano-sdk/projection@0.6.6) (2023-06-12)

### Bug Fixes

* **projection:** filterProducedUtxoByAssetPolicyId now also filters out other assets ([57da14b](https://github.com/input-output-hk/cardano-js-sdk/commit/57da14b4488a019e8d18b9ceac7eac7f11f92558))

## [0.6.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.4...@cardano-sdk/projection@0.6.5) (2023-06-06)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.6.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.3...@cardano-sdk/projection@0.6.4) (2023-06-05)

### Features

* add handle projection ([1d3f4ca](https://github.com/input-output-hk/cardano-js-sdk/commit/1d3f4ca3cfa3f1dfb668847de58eba4d0402d48e))

## [0.6.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.2...@cardano-sdk/projection@0.6.3) (2023-06-01)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.6.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.1...@cardano-sdk/projection@0.6.2) (2023-05-24)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.6.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.6.0...@cardano-sdk/projection@0.6.1) (2023-05-22)

**Note:** Version bump only for package @cardano-sdk/projection

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.5.0...@cardano-sdk/projection@0.6.0) (2023-05-02)

### ⚠ BREAKING CHANGES

- remove one layer of projection abstraction
- **projection:** convert projectIntoSink into rxjs operator
- simplify projection Sink to be an operator
- **projection:** omit pool updates and retirements that do not take effect

### Features

- **cardano-services:** add projector service ([5a5b281](https://github.com/input-output-hk/cardano-js-sdk/commit/5a5b281690283995b9a20c61c337c621b919fb3c))
- **projection:** add stakePoolMetadata and stakePoolMetrics projection types ([ae85933](https://github.com/input-output-hk/cardano-js-sdk/commit/ae859332a959d1966c0b5eba19cc8f86f88e94b8))
- **projection:** add withEpochBoundary operator ([a646412](https://github.com/input-output-hk/cardano-js-sdk/commit/a64641270f55839d824733189f447f899ac8e3be))
- **projection:** add withMint mapper ([8986bfc](https://github.com/input-output-hk/cardano-js-sdk/commit/8986bfcd732842198681b1e292162f6182786a25))
- **projection:** add withUtxo and filterProducedUtxoByAddresses mappers ([bf3ea27](https://github.com/input-output-hk/cardano-js-sdk/commit/bf3ea27cfc9a3a0a0e55059a5a70f2daade8fcc2))
- **projection:** improve logging ([69a5c8b](https://github.com/input-output-hk/cardano-js-sdk/commit/69a5c8b7e5a1307b4b6a936ef327b14fbf7e65c7))
- **projection:** omit pool updates and retirements that do not take effect ([c76b1a1](https://github.com/input-output-hk/cardano-js-sdk/commit/c76b1a1a6dc6baddf4a90127a58b3682db83ef31))

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))

### Code Refactoring

- **projection:** convert projectIntoSink into rxjs operator ([490ca1b](https://github.com/input-output-hk/cardano-js-sdk/commit/490ca1b7f0f92e4fa84179ba3fb265ee68dee735))
- remove one layer of projection abstraction ([6a0eca9](https://github.com/input-output-hk/cardano-js-sdk/commit/6a0eca92d1b6507e7143bfb5a93974b59757d5c5))
- simplify projection Sink to be an operator ([d9c6826](https://github.com/input-output-hk/cardano-js-sdk/commit/d9c68265d63300d26eb73ca93f5ee8be7ff51a12))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.4.0...@cardano-sdk/projection@0.5.0) (2023-03-13)

### ⚠ BREAKING CHANGES

- **projection:** replace projectIntoSink 'sinks' prop with 'sinksFactory'
- **projection:** replace register/deregister with insert/del for withStakeKeys
- **projection:** replace StabilityWindowBuffer methods with a single `handleEvents`

### Features

- **projection:** export ProjectionsEvent and SinkEventType type utils ([0463c9d](https://github.com/input-output-hk/cardano-js-sdk/commit/0463c9dd70a9eda88238e524c36e3564ff37169d))
- **projection:** replace register/deregister with insert/del for withStakeKeys ([9386990](https://github.com/input-output-hk/cardano-js-sdk/commit/938699076b5ed67fecdb7663c26526ce7e80356a))
- send phase2 validation failed transactions as failed$ ([ef25825](https://github.com/input-output-hk/cardano-js-sdk/commit/ef2582532677aeee4b19e84adf1957f09631dd72))

### Code Refactoring

- **projection:** replace projectIntoSink 'sinks' prop with 'sinksFactory' ([8f15f6f](https://github.com/input-output-hk/cardano-js-sdk/commit/8f15f6f9fa09fea25df7d14ed10a64afcfa234c2))
- **projection:** replace StabilityWindowBuffer methods with a single `handleEvents` ([5c8d330](https://github.com/input-output-hk/cardano-js-sdk/commit/5c8d3303890c3c6b299b145cd906222d25cdceec))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.3.0...@cardano-sdk/projection@0.4.0) (2023-03-01)

### ⚠ BREAKING CHANGES

- **projection:** rename exported namespaces to start with Uppercase
- **projection:** improve design by using ObservableCardanoNode
- add ChainSyncRollBackward.point

### Features

- **projection:** optimize InMemoryStabilityWindowBuffer to keep a maximum of 'k' blocks ([c28ed60](https://github.com/input-output-hk/cardano-js-sdk/commit/c28ed60308825804460387b522de9be72a270750))

### Code Refactoring

- add ChainSyncRollBackward.point ([4f61a6d](https://github.com/input-output-hk/cardano-js-sdk/commit/4f61a6d960adb85f762c09fb61d1a461e907cd72))
- **projection:** improve design by using ObservableCardanoNode ([9f54088](https://github.com/input-output-hk/cardano-js-sdk/commit/9f54088fb256f79e8da2c838b1244e92618f25b2))
- **projection:** rename exported namespaces to start with Uppercase ([4ea9c93](https://github.com/input-output-hk/cardano-js-sdk/commit/4ea9c931950585110901b23907a25ee6e9b61f75))

## [0.3.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.2.0...@cardano-sdk/projection@0.3.0) (2023-02-17)

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

- EraSummary.parameters.slotLength type changed from number
  to Milliseconds
- **projection:** Change how rollbacks are handled:

* Operators are now using 'UnifiedProjectorEvent', where both
  RollForward and RollBackward events have 'block'
* Replace `withRolledBackEvents` with `withRolledBackBlock`,
  which emits rolled back blocks one by one,

Remove `withStabilityWindow` and add 'withNetworkInfo' instead.
Update some operator signatures to not require any arguments.

### Features

- **projection:** add projection and sink modules ([61d4b83](https://github.com/input-output-hk/cardano-js-sdk/commit/61d4b8397e638e092d7eb49fada4bd425bc90274))
- update EraSummary slotLength type to be Milliseconds ([fb1f1a2](https://github.com/input-output-hk/cardano-js-sdk/commit/fb1f1a2c4fb77d03e45f9255c182e9bc54583324))

### Bug Fixes

- **projection:** stake key register/deregister now cancels each other out ([026bd06](https://github.com/input-output-hk/cardano-js-sdk/commit/026bd0682e7656e8b0ec2b8f36c240d856407a52))
- **util-rxjs:** rework blockingWithLatestFrom ([3d9e41c](https://github.com/input-output-hk/cardano-js-sdk/commit/3d9e41cbc309557fdc080587b7394de654a115ee))

### Code Refactoring

- refactor the SDK to use the new crypto package ([3b41320](https://github.com/input-output-hk/cardano-js-sdk/commit/3b41320e7971a231d50785733ff4cd0793418d3d))

## 0.2.0 (2022-12-22)

### ⚠ BREAKING CHANGES

- - BlockSize is now an OpaqueNumber rather than a type alias for number

* BlockNo is now an OpaqueNumber rather than a type alias for number
* EpochNo is now an OpaqueNumber rather than a type alias for number
* Slot is now an OpaqueNumber rather than a type alias for number
* Percentage is now an OpaqueNumber rather than a type alias for number

- rename era-specific types in core

### Features

- add opaque numeric types to core package ([9ead8bd](https://github.com/input-output-hk/cardano-js-sdk/commit/9ead8bdb34b7ffc57c32f9ab18a6c6ca14af3fda))
- initial projection implementation ([8a93d8d](https://github.com/input-output-hk/cardano-js-sdk/commit/8a93d8d427eb947b6f34566f8a694fcedfe0e59f))
- rename era-specific types in core ([c4955b1](https://github.com/input-output-hk/cardano-js-sdk/commit/c4955b1f3ae0992bb55b1c1461a1e449be0b6ef2))

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
