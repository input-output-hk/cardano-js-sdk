# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.5.1-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cip30@0.5.0...@cardano-sdk/cip30@0.5.1-nightly.0) (2022-09-14)

**Note:** Version bump only for package @cardano-sdk/cip30





## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cip30@0.4.0...@cardano-sdk/cip30@0.5.0) (2022-08-30)


### ⚠ BREAKING CHANGES

* logger is now required

### Features

* implement cip30 getCollateral ([878f021](https://github.com/input-output-hk/cardano-js-sdk/commit/878f021d3620a4842a1629b442ae12a2acd1bf94))


### Code Refactoring

* logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))



## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/cip30@0.4.0) (2022-07-25)

## 0.3.0 (2022-06-24)


### ⚠ BREAKING CHANGES

* **cip30:** synchronize creation of PersistentAuthenticator
* revert 7076fc2ae987948e2c52b696666842ddb67af5d7
* rm cip30 dependency on web-extension
* **wallet:** clean up ObservableWallet interface so it can be easily exposed remotely
* require to explicitly specify exposed api property names (security reasons)
* hoist cip30 mapping of ObservableWallet to cip30 pkg
* rework cip30 to use web extension messaging ports
* rename uiWallet->webExtensionWalletClient

### Features

* add cip30 getCollateral method (not implemented) ([2f20255](https://github.com/input-output-hk/cardano-js-sdk/commit/2f202550d8187a5e053afac6490d76df7bffa3f5))
* **cip30:** add extension ID prop ([f4bbd2d](https://github.com/input-output-hk/cardano-js-sdk/commit/f4bbd2d224c90dec8a535236dd013d9fc2b7df22))
* **cip30:** add missing networkId method to api ([bff6958](https://github.com/input-output-hk/cardano-js-sdk/commit/bff6958e45201743b8421dc5f9656e6514522f04))
* **cip30:** add tests for multi-dapp connections, update mapping tests ([8119511](https://github.com/input-output-hk/cardano-js-sdk/commit/81195110f31dff1c9cb62dab03f139cc6e04fe8c))
* **cip30:** implement ApiError{InternalError} ([8d9ed3f](https://github.com/input-output-hk/cardano-js-sdk/commit/8d9ed3fa252bc1e8a66b4e5d2cbd21dc5942f23c))
* **cip30:** initial wallet mapping to cip30api ([66aa6d5](https://github.com/input-output-hk/cardano-js-sdk/commit/66aa6d5b7cc5836dfa6f947af3df86e62318960c))
* **cip30:** removed dependency on window ([20b6af9](https://github.com/input-output-hk/cardano-js-sdk/commit/20b6af9bd9b717632c18971c658966298629e553))
* **cip30:** replace window.localStorage with webextension-polyfill storage ([86e0123](https://github.com/input-output-hk/cardano-js-sdk/commit/86e0123f7c3b357d560ab5aff350b8404b19662c))
* **cip30:** update public api definition ([2a5e2a5](https://github.com/input-output-hk/cardano-js-sdk/commit/2a5e2a52a13ae4793de3db857bff399eb990a3af))
* **cip30:** updated imports + jsdoc tags ([6b734f4](https://github.com/input-output-hk/cardano-js-sdk/commit/6b734f49a058858b693a2cf4193bb3d70faa6006))
* require to explicitly specify exposed api property names (security reasons) ([f1a0aa4](https://github.com/input-output-hk/cardano-js-sdk/commit/f1a0aa4129705920ea5a734448fea6b99efbdcb4))


### Bug Fixes

* check walletName in cip30 messages ([966b362](https://github.com/input-output-hk/cardano-js-sdk/commit/966b36233c7946ee13418100c7d96bf156e3c526))
* **cip30:** make handleMessages more resilient ([67e316e](https://github.com/input-output-hk/cardano-js-sdk/commit/67e316ed583b335a5400842a250ca04965d8e66b))
* **cip30:** remove dangling dependency ([8c5274f](https://github.com/input-output-hk/cardano-js-sdk/commit/8c5274fa7e2b82448359b40ccef1495f040c2648)), closes [#194](https://github.com/input-output-hk/cardano-js-sdk/issues/194)
* correct cip30 getUtxos return type ([9ddc5af](https://github.com/input-output-hk/cardano-js-sdk/commit/9ddc5afb57dc0d74b7c11a350c948c4fdd4b06e7))


### Code Refactoring

* **cip30:** synchronize creation of PersistentAuthenticator ([fb5dd1b](https://github.com/input-output-hk/cardano-js-sdk/commit/fb5dd1b9c05eda035dcbd6651ad71c0cc3eae5f2))
* hoist cip30 mapping of ObservableWallet to cip30 pkg ([7076fc2](https://github.com/input-output-hk/cardano-js-sdk/commit/7076fc2ae987948e2c52b696666842ddb67af5d7))
* rename uiWallet->webExtensionWalletClient ([c4ebdea](https://github.com/input-output-hk/cardano-js-sdk/commit/c4ebdeab881be7f6cfd0ff3d3428bcb8e04529a7))
* revert 7076fc2ae987948e2c52b696666842ddb67af5d7 ([b30183e](https://github.com/input-output-hk/cardano-js-sdk/commit/b30183e4852606e38c1d5b55dd9dc51ed138fc29))
* rework cip30 to use web extension messaging ports ([837dc9d](https://github.com/input-output-hk/cardano-js-sdk/commit/837dc9da1c19df340953c47381becfe07f02a0c9))
* rm cip30 dependency on web-extension ([77f8642](https://github.com/input-output-hk/cardano-js-sdk/commit/77f8642ebaac3b2615d082184d22a96f4cf86d42))
* **wallet:** clean up ObservableWallet interface so it can be easily exposed remotely ([249b5b0](https://github.com/input-output-hk/cardano-js-sdk/commit/249b5b0ac12a0c8d8dbca00e11f9b288ba7aaf0a))

### 0.1.5 (2021-10-27)

### 0.1.3 (2021-10-05)

### 0.1.2 (2021-09-30)

### 0.1.1 (2021-09-30)


### Features

* **cip-30:** create cip-30 package ([266e719](https://github.com/input-output-hk/cardano-js-sdk/commit/266e719d8c0b8550e05ff4d8da199a4575c0664e))
* **cip30:** create Messaging bridge for WalletAPi ([c3d0515](https://github.com/input-output-hk/cardano-js-sdk/commit/c3d0515d8bd649b5395d38dd311e04d6381b2b63))


### Bug Fixes

* add missing yarn script, and rename ([840135f](https://github.com/input-output-hk/cardano-js-sdk/commit/840135f7d100c9a00ff410147758ee7d02112897))
