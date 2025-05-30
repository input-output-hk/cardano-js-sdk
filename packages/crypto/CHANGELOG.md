# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.3.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.2.3...@cardano-sdk/crypto@0.3.0) (2025-05-30)

### ⚠ BREAKING CHANGES

* add a new 'dependencies' parameter in Bip32Account ctor
* remove Hash28ByteBase16.fromEd25519KeyHashHex

### Features

* add support for injecting crypto functions for Bip32Account ([51a821d](https://github.com/input-output-hk/cardano-js-sdk/commit/51a821dffb0c65b3339a74771e8c6317966280b3))

### Code Refactoring

* make hex-encoded opaque string types assignable to HexBlob ([17c0a64](https://github.com/input-output-hk/cardano-js-sdk/commit/17c0a644960ce5931fb0991ecd4cad7faaceb438))

## [0.2.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.2.2...@cardano-sdk/crypto@0.2.3) (2025-02-24)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.2.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.2.1...@cardano-sdk/crypto@0.2.2) (2025-02-06)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.2.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.2.0...@cardano-sdk/crypto@0.2.1) (2025-01-31)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.2.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.32...@cardano-sdk/crypto@0.2.0) (2025-01-17)

### ⚠ BREAKING CHANGES

* The package now exports an async `ready` function that must be called before any of crypto related functions can be called
- Bip32PrivateKe async functions are all now sync
- Bip32PublicKey class async functions are all now sync
- Ed25519PrivateKey class async functions are all now sync
- Ed25519PublicKey class async functions are all now sync
- Bip32Ed25519 interface async functions are all now sync
- SodiumBip32Ed25519 cosntructor is now private
- SodiumBip32Ed25519 now has a new async factory method create

### Features

* remove async from crypto API ([91b7fa2](https://github.com/input-output-hk/cardano-js-sdk/commit/91b7fa29961cfb11fe7270aef259be19ac215f08))

## [0.1.32](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.31...@cardano-sdk/crypto@0.1.32) (2024-12-02)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.31](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.30...@cardano-sdk/crypto@0.1.31) (2024-11-18)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.30](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.29...@cardano-sdk/crypto@0.1.30) (2024-08-21)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.29](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.28...@cardano-sdk/crypto@0.1.29) (2024-07-31)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.28](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.27...@cardano-sdk/crypto@0.1.28) (2024-07-25)

### Bug Fixes

* esm build now works correctly when imported in modules ([ab46f4c](https://github.com/input-output-hk/cardano-js-sdk/commit/ab46f4cd7b1891a35ee8aa8f83e5b30e6bb7bada))

## [0.1.27](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.26...@cardano-sdk/crypto@0.1.27) (2024-07-22)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.26](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.25...@cardano-sdk/crypto@0.1.26) (2024-07-11)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.25](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.24...@cardano-sdk/crypto@0.1.25) (2024-06-20)

### Features

* remove async from fromBip39Entropy ([#1326](https://github.com/input-output-hk/cardano-js-sdk/issues/1326)) ([da736d3](https://github.com/input-output-hk/cardano-js-sdk/commit/da736d33a4e6c4f1ea3ce4c654bf0f8ba2e39247))

## [0.1.24](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.23...@cardano-sdk/crypto@0.1.24) (2024-06-14)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.23](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.22...@cardano-sdk/crypto@0.1.23) (2024-04-23)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.22](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.21...@cardano-sdk/crypto@0.1.22) (2024-03-26)

### Bug Fixes

* **crypto:** replace variable in keylength error message ([8fe30e7](https://github.com/input-output-hk/cardano-js-sdk/commit/8fe30e7afec160226e3151946981e82fcaad3a68))

## [0.1.21](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.20...@cardano-sdk/crypto@0.1.21) (2024-02-12)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.20](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.19...@cardano-sdk/crypto@0.1.20) (2024-01-25)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.19](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.18...@cardano-sdk/crypto@0.1.19) (2023-12-14)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.18](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.17...@cardano-sdk/crypto@0.1.18) (2023-12-07)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.17](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.16...@cardano-sdk/crypto@0.1.17) (2023-12-04)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.16](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.15...@cardano-sdk/crypto@0.1.16) (2023-11-29)

### Features

* **crypto:** add Bip32PublicKeyHex and Bip32PublicKey.hash() ([279d0e5](https://github.com/input-output-hk/cardano-js-sdk/commit/279d0e503334bb4bcfaead2a8521f8993d74dbb2))

## [0.1.15](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.14...@cardano-sdk/crypto@0.1.15) (2023-09-29)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.14](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.13...@cardano-sdk/crypto@0.1.14) (2023-09-20)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.13](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.12...@cardano-sdk/crypto@0.1.13) (2023-09-12)

### Features

* added Ed25519 EdDSA signature scheme to crypto package based on ([e97d58e](https://github.com/input-output-hk/cardano-js-sdk/commit/e97d58ed1d02feaefd90108cf683f83adba02e19))
* **crypto:** added BIP-32 key management and derivation to crypto package ([149e731](https://github.com/input-output-hk/cardano-js-sdk/commit/149e73119aceb2acabfff9a0922edc0df7bb054b))
* **crypto:** added libSodium based Bip32Ed25519 implementation ([47011d4](https://github.com/input-output-hk/cardano-js-sdk/commit/47011d4f4a21f91b1c566f7a6eef0b8157bfa87e))

## [0.1.12](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.11...@cardano-sdk/crypto@0.1.12) (2023-08-21)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.10...@cardano-sdk/crypto@0.1.11) (2023-08-15)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.9...@cardano-sdk/crypto@0.1.10) (2023-08-11)

### Features

* **crypto:** add Hash28ByteBase16.fromEd25519KeyHashHex ([baf45d6](https://github.com/input-output-hk/cardano-js-sdk/commit/baf45d625c7a8eb5b484140c997f9dcb0649beea))

## [0.1.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.8...@cardano-sdk/crypto@0.1.9) (2023-07-04)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.7...@cardano-sdk/crypto@0.1.8) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.6...@cardano-sdk/crypto@0.1.7) (2023-06-28)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.5...@cardano-sdk/crypto@0.1.6) (2023-06-05)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.4...@cardano-sdk/crypto@0.1.5) (2023-05-22)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.3...@cardano-sdk/crypto@0.1.4) (2023-05-02)

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))

## [0.1.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.2...@cardano-sdk/crypto@0.1.3) (2023-03-13)

**Note:** Version bump only for package @cardano-sdk/crypto

## [0.1.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/crypto@0.1.1...@cardano-sdk/crypto@0.1.2) (2023-03-01)

**Note:** Version bump only for package @cardano-sdk/crypto

## 0.1.1 (2023-02-17)

### Features

- **crypto:** added crypto package to the SDK ([030753d](https://github.com/input-output-hk/cardano-js-sdk/commit/030753d9f62b984b2d31f2e7e793b3929137d314))
