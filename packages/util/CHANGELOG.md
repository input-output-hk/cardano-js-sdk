# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.9.0-nightly.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.9.0-nightly.0...@cardano-sdk/util@0.9.0-nightly.1) (2023-03-31)

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))

## [0.9.0-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.8.3-nightly.1...@cardano-sdk/util@0.9.0-nightly.0) (2023-03-24)

### ⚠ BREAKING CHANGES

- - stack property of returned errors was removed

### Features

- **util:** adds an util to resolve all promises contained within an object ([db58ad4](https://github.com/input-output-hk/cardano-js-sdk/commit/db58ad4fca9ba9257375bd20e43c74a6b2a8cf39))

### Code Refactoring

- the TxSubmit endpoint no longer adds the stack trace when returning domain errors ([f018f30](https://github.com/input-output-hk/cardano-js-sdk/commit/f018f30caea1c9cf764a419431ac642b98733bb9))

## [0.8.3-nightly.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.8.3-nightly.0...@cardano-sdk/util@0.8.3-nightly.1) (2023-03-22)

**Note:** Version bump only for package @cardano-sdk/util

## [0.8.3-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.8.2...@cardano-sdk/util@0.8.3-nightly.0) (2023-03-14)

**Note:** Version bump only for package @cardano-sdk/util

## [0.8.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.8.1...@cardano-sdk/util@0.8.2) (2023-03-13)

**Note:** Version bump only for package @cardano-sdk/util

## [0.8.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.8.0...@cardano-sdk/util@0.8.1) (2023-03-01)

### Features

- **util:** add WithLogger type ([6a2d79f](https://github.com/input-output-hk/cardano-js-sdk/commit/6a2d79f557d244b7e34f66dc76f0843ac7a5c3ae))

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.7.0...@cardano-sdk/util@0.8.0) (2023-02-17)

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

### Features

- **util:** added a new custom error for handling invalid arguments ([74f9a15](https://github.com/input-output-hk/cardano-js-sdk/commit/74f9a15346338612647add5ac9e90a150d84548a))

### Bug Fixes

- **cardano-services:** updated http provider error handling ([#514](https://github.com/input-output-hk/cardano-js-sdk/issues/514)) ([33a4867](https://github.com/input-output-hk/cardano-js-sdk/commit/33a48670490fa998cef0196eb71492103105dcf7))

### Code Refactoring

- hoist Opaque types, hexBlob, Base64Blob and related utils ([391a8f2](https://github.com/input-output-hk/cardano-js-sdk/commit/391a8f20d60607c4fb6ce8586b97ae96841f759b))
- refactor the SDK to use the new crypto package ([3b41320](https://github.com/input-output-hk/cardano-js-sdk/commit/3b41320e7971a231d50785733ff4cd0793418d3d))

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.6.0...@cardano-sdk/util@0.7.0) (2022-12-22)

### ⚠ BREAKING CHANGES

- create a new CML scope for every call of BuildTx in selection constraints

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
- create a new CML scope for every call of BuildTx in selection constraints ([6818ae4](https://github.com/input-output-hk/cardano-js-sdk/commit/6818ae443dd53ac4786ce161f02aef5635433678))
- **util:** fixes util-dev version in dev dependencies ([6c165bf](https://github.com/input-output-hk/cardano-js-sdk/commit/6c165bf9f11159324850d9f7624c02bec9be60e1))

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.5.0...@cardano-sdk/util@0.6.0) (2022-11-04)

### ⚠ BREAKING CHANGES

- lift deepEquals to util package in preparation for further wallet decomposition
- hoist hexString utils to util package

### Features

- **util:** managed scope and util for handling freeable objects ([7f03a53](https://github.com/input-output-hk/cardano-js-sdk/commit/7f03a536b7aa504b022846f7786068806df83c12))
- **util:** typescript DeepPartial utility type ([824e7aa](https://github.com/input-output-hk/cardano-js-sdk/commit/824e7aa8906ad7c3ce5a93770ffc7ed09651da68))

### Bug Fixes

- added missing contraints ([7b351ca](https://github.com/input-output-hk/cardano-js-sdk/commit/7b351cada06b9c5ae2f379d02614e05259f7147a))
- **util:** a websocket closed error is now correctly handled as a network error ([6aa00a1](https://github.com/input-output-hk/cardano-js-sdk/commit/6aa00a10fc21eac13da557d6c7c1de40c3f30b66))

### Code Refactoring

- hoist hexString utils to util package ([0c99d9d](https://github.com/input-output-hk/cardano-js-sdk/commit/0c99d9d37f23bb504d1ac2a530fbe78aa045db66))
- lift deepEquals to util package in preparation for further wallet decomposition ([c935a77](https://github.com/input-output-hk/cardano-js-sdk/commit/c935a77c0bb895ee85b885e8da57ed7de3786e36))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.4.0...@cardano-sdk/util@0.5.0) (2022-08-30)

### ⚠ BREAKING CHANGES

- contextLogger support

### Features

- **util:** expose isConnectionError check ([c9c8bdb](https://github.com/input-output-hk/cardano-js-sdk/commit/c9c8bdbffb16208d2f7aea135ab61dd7dae0be92))

### Code Refactoring

- contextLogger support ([6d5da8e](https://github.com/input-output-hk/cardano-js-sdk/commit/6d5da8ec8bba2033ce378d2f0d9321fd758e7c90))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/util@0.4.0) (2022-07-25)

### Bug Fixes

- **util:** add Set serialization support ([237913f](https://github.com/input-output-hk/cardano-js-sdk/commit/237913f685ee5ae2d5cd7353a92ada8d9f9ff82b))
- **util:** correctly deserialize Set items ([adf458d](https://github.com/input-output-hk/cardano-js-sdk/commit/adf458d150c398ce9589821ef40703c2da5685f7))

## 0.3.0 (2022-06-24)
