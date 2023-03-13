# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

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
