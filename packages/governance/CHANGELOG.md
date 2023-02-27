# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.3.1-nightly.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/governance@0.3.1-nightly.1...@cardano-sdk/governance@0.3.1-nightly.2) (2023-02-27)

**Note:** Version bump only for package @cardano-sdk/governance

## [0.3.1-nightly.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/governance@0.3.1-nightly.0...@cardano-sdk/governance@0.3.1-nightly.1) (2023-02-21)

**Note:** Version bump only for package @cardano-sdk/governance

## [0.3.1-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/governance@0.3.0...@cardano-sdk/governance@0.3.1-nightly.0) (2023-02-18)

**Note:** Version bump only for package @cardano-sdk/governance

## [0.3.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/governance@0.2.1...@cardano-sdk/governance@0.3.0) (2023-02-17)

### ⚠ BREAKING CHANGES

- **governance:** Remove hardening from the definition of CIP-36 indices Purpose (1694) and CoinType (1815)
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

### Bug Fixes

- **governance:** remove double hardening from CIP-36 derivation indices ([9b16323](https://github.com/input-output-hk/cardano-js-sdk/commit/9b163237dd03f37ee5bcb5bb5d72949037b27f2a))

### Code Refactoring

- hoist Opaque types, hexBlob, Base64Blob and related utils ([391a8f2](https://github.com/input-output-hk/cardano-js-sdk/commit/391a8f20d60607c4fb6ce8586b97ae96841f759b))
- refactor the SDK to use the new crypto package ([3b41320](https://github.com/input-output-hk/cardano-js-sdk/commit/3b41320e7971a231d50785733ff4cd0793418d3d))

## [0.2.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/governance@0.2.0...@cardano-sdk/governance@0.2.1) (2022-12-22)

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))

## 0.2.0 (2022-11-04)

### ⚠ BREAKING CHANGES

- free CSL resources using freeable util
- lift key management and governance concepts to new packages

### Bug Fixes

- free CSL resources using freeable util ([5ce0056](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce0056fb108f7bccfbd9f8ef562b82277f3c613))

### Code Refactoring

- lift key management and governance concepts to new packages ([15cde5f](https://github.com/input-output-hk/cardano-js-sdk/commit/15cde5f9becff94dac17278cb45e3adcaac763b5))
