# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.15.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.15.0...@cardano-sdk/util@0.15.1) (2024-04-23)

**Note:** Version bump only for package @cardano-sdk/util

## [0.15.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.14.5...@cardano-sdk/util@0.15.0) (2024-01-25)

### ⚠ BREAKING CHANGES

* replace fromSerializableObj getErrorPrototype with errorTypes

### Code Refactoring

* replace fromSerializableObj getErrorPrototype with errorTypes ([7a9770c](https://github.com/input-output-hk/cardano-js-sdk/commit/7a9770cc318a0149d2d623eca5c42e8c0699983e))

## [0.14.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.14.4...@cardano-sdk/util@0.14.5) (2023-12-07)

**Note:** Version bump only for package @cardano-sdk/util

## [0.14.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.14.3...@cardano-sdk/util@0.14.4) (2023-12-04)

**Note:** Version bump only for package @cardano-sdk/util

## [0.14.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.14.2...@cardano-sdk/util@0.14.3) (2023-11-29)

**Note:** Version bump only for package @cardano-sdk/util

## [0.14.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.14.1...@cardano-sdk/util@0.14.2) (2023-09-29)

**Note:** Version bump only for package @cardano-sdk/util

## [0.14.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.14.0...@cardano-sdk/util@0.14.1) (2023-09-20)

### Bug Fixes

* **util:** deserialize bytes as Uint8Array instead of Buffer ([78460d3](https://github.com/input-output-hk/cardano-js-sdk/commit/78460d36c6c7b75815b0d5fce1303b5dde91f3b6))

## [0.14.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.13.2...@cardano-sdk/util@0.14.0) (2023-08-21)

### ⚠ BREAKING CHANGES

* **util:** shallowArrayEquals was removed

### Code Refactoring

* **util:** removed shallowArrayEquals ([f869896](https://github.com/input-output-hk/cardano-js-sdk/commit/f869896ecd29f662b4494da48e872382b07e4e6c))

## [0.13.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.13.1...@cardano-sdk/util@0.13.2) (2023-08-15)

**Note:** Version bump only for package @cardano-sdk/util

## [0.13.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.13.0...@cardano-sdk/util@0.13.1) (2023-08-11)

**Note:** Version bump only for package @cardano-sdk/util

## [0.13.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.12.1...@cardano-sdk/util@0.13.0) (2023-07-04)

### ⚠ BREAKING CHANGES

* added change address resolver to the round robin input selector

### Features

* added change address resolver to the round robin input selector ([ef654ca](https://github.com/input-output-hk/cardano-js-sdk/commit/ef654ca7a7c3217b68360e1d4bee3296e5fc4f0e))

## [0.12.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.12.0...@cardano-sdk/util@0.12.1) (2023-06-29)

### Bug Fixes

* **util:** add ServerNotReady to list of connection errors ([c7faf01](https://github.com/input-output-hk/cardano-js-sdk/commit/c7faf01194561b2941c42c4a74517de0a5a9f7d9))

## [0.12.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.11.0...@cardano-sdk/util@0.12.0) (2023-06-28)

### ⚠ BREAKING CHANGES

* moved strictEquals, sameArrayItems, shallowArrayEquals to util package

### Code Refactoring

* move generic equals methods to util package ([6b5dbd3](https://github.com/input-output-hk/cardano-js-sdk/commit/6b5dbd3382eda3fb58901619438caf946a559715))

## [0.11.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.10.0...@cardano-sdk/util@0.11.0) (2023-06-05)

### ⚠ BREAKING CHANGES

* hoist Cardano.Percent to util package

### Features

* **util:** get percentage from parts ([d8570e1](https://github.com/input-output-hk/cardano-js-sdk/commit/d8570e17babae00cc82e94b3e624804b63b86de6))

### Code Refactoring

* hoist Cardano.Percent to util package ([e4da0e3](https://github.com/input-output-hk/cardano-js-sdk/commit/e4da0e3851a4bdfd503c1f195c5ba1455ea6675b))

## [0.10.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.9.0...@cardano-sdk/util@0.10.0) (2023-05-22)

### ⚠ BREAKING CHANGES

* **util-dev:** remove createStubLogger util

### Features

* **util-dev:** remove createStubLogger util ([de06e4e](https://github.com/input-output-hk/cardano-js-sdk/commit/de06e4e46877116f7ceb1f04df920a351dd4724d))
* **util:** export isPromise util ([cc0b3b0](https://github.com/input-output-hk/cardano-js-sdk/commit/cc0b3b0e10ef4eaf763bea085976669f8be72ed5))
* **util:** transformObj util ([40f4b0d](https://github.com/input-output-hk/cardano-js-sdk/commit/40f4b0db82d2495f31da1f0d5e090858688a8115))

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/util@0.8.2...@cardano-sdk/util@0.9.0) (2023-05-02)

### ⚠ BREAKING CHANGES

- hoist patchObject from util-dev to util package
- simplify projection Sink to be an operator
- - stack property of returned errors was removed

### Features

- **util:** adds an util to resolve all promises contained within an object ([db58ad4](https://github.com/input-output-hk/cardano-js-sdk/commit/db58ad4fca9ba9257375bd20e43c74a6b2a8cf39))

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))

### Code Refactoring

- hoist patchObject from util-dev to util package ([bea7e03](https://github.com/input-output-hk/cardano-js-sdk/commit/bea7e035ebdcd7241b6f3cc8feb5fbcfdb90fa46))
- simplify projection Sink to be an operator ([d9c6826](https://github.com/input-output-hk/cardano-js-sdk/commit/d9c68265d63300d26eb73ca93f5ee8be7ff51a12))
- the TxSubmit endpoint no longer adds the stack trace when returning domain errors ([f018f30](https://github.com/input-output-hk/cardano-js-sdk/commit/f018f30caea1c9cf764a419431ac642b98733bb9))

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
