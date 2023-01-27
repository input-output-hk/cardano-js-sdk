# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.3.0-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.2.1-nightly.0...@cardano-sdk/projection@0.3.0-nightly.0) (2023-01-27)

### ⚠ BREAKING CHANGES

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

## [0.2.1-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/projection@0.2.0...@cardano-sdk/projection@0.2.1-nightly.0) (2022-12-24)

**Note:** Version bump only for package @cardano-sdk/projection

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
