# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

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
