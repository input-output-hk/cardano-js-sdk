# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.9.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/dapp-connector@0.9.2...@cardano-sdk/dapp-connector@0.9.3) (2023-06-01)

**Note:** Version bump only for package @cardano-sdk/dapp-connector

## [0.9.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/dapp-connector@0.9.1...@cardano-sdk/dapp-connector@0.9.2) (2023-05-24)

**Note:** Version bump only for package @cardano-sdk/dapp-connector

## [0.9.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/dapp-connector@0.9.0...@cardano-sdk/dapp-connector@0.9.1) (2023-05-22)

**Note:** Version bump only for package @cardano-sdk/dapp-connector

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/dapp-connector@0.8.0...@cardano-sdk/dapp-connector@0.9.0) (2023-05-02)

### ⚠ BREAKING CHANGES

- update WalletApi.getUtxos return type from `undefined` to `null`

### Bug Fixes

- cip30 getUtxos(amount) now returns `null` when wallet has insufficient balance ([9b550eb](https://github.com/input-output-hk/cardano-js-sdk/commit/9b550eb4e9ef4f7a1432defb155bebe4b2ec2c34))
- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/dapp-connector@0.7.1...@cardano-sdk/dapp-connector@0.8.0) (2023-03-13)

### ⚠ BREAKING CHANGES

- core type for address string reprensetation 'Address' renamed to PaymentAddress

### Code Refactoring

- core type for address string reprensetation 'Address' renamed to PaymentAddress ([4287463](https://github.com/input-output-hk/cardano-js-sdk/commit/42874633de6069510efdc57323f61140d22ed203))

## [0.7.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/dapp-connector@0.7.0...@cardano-sdk/dapp-connector@0.7.1) (2023-03-01)

**Note:** Version bump only for package @cardano-sdk/dapp-connector

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/dapp-connector@0.6.1...@cardano-sdk/dapp-connector@0.7.0) (2023-02-17)

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

### Code Refactoring

- hoist Opaque types, hexBlob, Base64Blob and related utils ([391a8f2](https://github.com/input-output-hk/cardano-js-sdk/commit/391a8f20d60607c4fb6ce8586b97ae96841f759b))
- refactor the SDK to use the new crypto package ([3b41320](https://github.com/input-output-hk/cardano-js-sdk/commit/3b41320e7971a231d50785733ff4cd0793418d3d))

## [0.6.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/dapp-connector@0.6.0...@cardano-sdk/dapp-connector@0.6.1) (2022-12-22)

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
- cip30 wallet has to accept hex encoded address ([d5a748a](https://github.com/input-output-hk/cardano-js-sdk/commit/d5a748a74289c7ec703066a8eca11637e3a84734))

## 0.6.0 (2022-11-04)

### ⚠ BREAKING CHANGES

- free CSL resources using freeable util
- **dapp-connector:** renamed cip30 package to dapp-connector

### Bug Fixes

- free CSL resources using freeable util ([5ce0056](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce0056fb108f7bccfbd9f8ef562b82277f3c613))

### Code Refactoring

- **dapp-connector:** renamed cip30 package to dapp-connector ([cb4411d](https://github.com/input-output-hk/cardano-js-sdk/commit/cb4411da916b263ad8a6d85e0bdaffcfe21646c5))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/dapp-connector@0.4.0...@cardano-sdk/dapp-connector@0.5.0) (2022-08-30)

### ⚠ BREAKING CHANGES

- logger is now required

### Features

- implement dapp-connector getCollateral ([878f021](https://github.com/input-output-hk/cardano-js-sdk/commit/878f021d3620a4842a1629b442ae12a2acd1bf94))

### Code Refactoring

- logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/dapp-connector@0.4.0) (2022-07-25)

## 0.3.0 (2022-06-24)

### ⚠ BREAKING CHANGES

- **dapp-connector:** synchronize creation of PersistentAuthenticator
- revert 7076fc2ae987948e2c52b696666842ddb67af5d7
- rm dapp-connector dependency on web-extension
- **wallet:** clean up ObservableWallet interface so it can be easily exposed remotely
- require to explicitly specify exposed api property names (security reasons)
- hoist dapp-connector mapping of ObservableWallet to dapp-connector pkg
- rework dapp-connector to use web extension messaging ports
- rename uiWallet->webExtensionWalletClient

### Features

- add dapp-connector getCollateral method (not implemented) ([2f20255](https://github.com/input-output-hk/cardano-js-sdk/commit/2f202550d8187a5e053afac6490d76df7bffa3f5))
- **dapp-connector:** add extension ID prop ([f4bbd2d](https://github.com/input-output-hk/cardano-js-sdk/commit/f4bbd2d224c90dec8a535236dd013d9fc2b7df22))
- **dapp-connector:** add missing networkId method to api ([bff6958](https://github.com/input-output-hk/cardano-js-sdk/commit/bff6958e45201743b8421dc5f9656e6514522f04))
- **dapp-connector:** add tests for multi-dapp connections, update mapping tests ([8119511](https://github.com/input-output-hk/cardano-js-sdk/commit/81195110f31dff1c9cb62dab03f139cc6e04fe8c))
- **dapp-connector:** implement ApiError{InternalError} ([8d9ed3f](https://github.com/input-output-hk/cardano-js-sdk/commit/8d9ed3fa252bc1e8a66b4e5d2cbd21dc5942f23c))
- **dapp-connector:** initial wallet mapping to dapp-connectorapi ([66aa6d5](https://github.com/input-output-hk/cardano-js-sdk/commit/66aa6d5b7cc5836dfa6f947af3df86e62318960c))
- **dapp-connector:** removed dependency on window ([20b6af9](https://github.com/input-output-hk/cardano-js-sdk/commit/20b6af9bd9b717632c18971c658966298629e553))
- **dapp-connector:** replace window.localStorage with webextension-polyfill storage ([86e0123](https://github.com/input-output-hk/cardano-js-sdk/commit/86e0123f7c3b357d560ab5aff350b8404b19662c))
- **dapp-connector:** update public api definition ([2a5e2a5](https://github.com/input-output-hk/cardano-js-sdk/commit/2a5e2a52a13ae4793de3db857bff399eb990a3af))
- **dapp-connector:** updated imports + jsdoc tags ([6b734f4](https://github.com/input-output-hk/cardano-js-sdk/commit/6b734f49a058858b693a2cf4193bb3d70faa6006))
- require to explicitly specify exposed api property names (security reasons) ([f1a0aa4](https://github.com/input-output-hk/cardano-js-sdk/commit/f1a0aa4129705920ea5a734448fea6b99efbdcb4))

### Bug Fixes

- check walletName in dapp-connector messages ([966b362](https://github.com/input-output-hk/cardano-js-sdk/commit/966b36233c7946ee13418100c7d96bf156e3c526))
- **dapp-connector:** make handleMessages more resilient ([67e316e](https://github.com/input-output-hk/cardano-js-sdk/commit/67e316ed583b335a5400842a250ca04965d8e66b))
- **dapp-connector:** remove dangling dependency ([8c5274f](https://github.com/input-output-hk/cardano-js-sdk/commit/8c5274fa7e2b82448359b40ccef1495f040c2648)), closes [#194](https://github.com/input-output-hk/cardano-js-sdk/issues/194)
- correct dapp-connector getUtxos return type ([9ddc5af](https://github.com/input-output-hk/cardano-js-sdk/commit/9ddc5afb57dc0d74b7c11a350c948c4fdd4b06e7))

### Code Refactoring

- **dapp-connector:** synchronize creation of PersistentAuthenticator ([fb5dd1b](https://github.com/input-output-hk/cardano-js-sdk/commit/fb5dd1b9c05eda035dcbd6651ad71c0cc3eae5f2))
- hoist dapp-connector mapping of ObservableWallet to dapp-connector pkg ([7076fc2](https://github.com/input-output-hk/cardano-js-sdk/commit/7076fc2ae987948e2c52b696666842ddb67af5d7))
- rename uiWallet->webExtensionWalletClient ([c4ebdea](https://github.com/input-output-hk/cardano-js-sdk/commit/c4ebdeab881be7f6cfd0ff3d3428bcb8e04529a7))
- revert 7076fc2ae987948e2c52b696666842ddb67af5d7 ([b30183e](https://github.com/input-output-hk/cardano-js-sdk/commit/b30183e4852606e38c1d5b55dd9dc51ed138fc29))
- rework dapp-connector to use web extension messaging ports ([837dc9d](https://github.com/input-output-hk/cardano-js-sdk/commit/837dc9da1c19df340953c47381becfe07f02a0c9))
- rm dapp-connector dependency on web-extension ([77f8642](https://github.com/input-output-hk/cardano-js-sdk/commit/77f8642ebaac3b2615d082184d22a96f4cf86d42))
- **wallet:** clean up ObservableWallet interface so it can be easily exposed remotely ([249b5b0](https://github.com/input-output-hk/cardano-js-sdk/commit/249b5b0ac12a0c8d8dbca00e11f9b288ba7aaf0a))

### 0.1.5 (2021-10-27)

### 0.1.3 (2021-10-05)

### 0.1.2 (2021-09-30)

### 0.1.1 (2021-09-30)

### Features

- **cip-30:** create cip-30 package ([266e719](https://github.com/input-output-hk/cardano-js-sdk/commit/266e719d8c0b8550e05ff4d8da199a4575c0664e))
- **dapp-connector:** create Messaging bridge for WalletAPi ([c3d0515](https://github.com/input-output-hk/cardano-js-sdk/commit/c3d0515d8bd649b5395d38dd311e04d6381b2b63))

### Bug Fixes

- add missing yarn script, and rename ([840135f](https://github.com/input-output-hk/cardano-js-sdk/commit/840135f7d100c9a00ff410147758ee7d02112897))
