# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## 0.1.0 (2021-09-30)


### Features

* add `deriveAddress` and `stakeKey` to the `KeyManager` ([b5ae13b](https://github.com/input-output-hk/cardano-js-sdk/commit/b5ae13b8472519b5a1dde5d9cfa0c64ad7638d07))
* add CardanoProvider.networkInfo ([1596ac2](https://github.com/input-output-hk/cardano-js-sdk/commit/1596ac27b3fa3494f784db37831f85e06a8e0e03))
* add CardanoProvider.stakePoolStats ([c25e570](https://github.com/input-output-hk/cardano-js-sdk/commit/c25e5704be13a9c259fa399e35a3771caad58d38))
* **blockfrost:** create new provider called blockfrost ([b8bd72f](https://github.com/input-output-hk/cardano-js-sdk/commit/b8bd72ffc91769e525400a898cf8e7a749b7d610))
* **cardano-graphql-provider:** create cardano-graphql-provider package ([096225f](https://github.com/input-output-hk/cardano-js-sdk/commit/096225f571aa1b5def660a2bdccfd5bad3d1ef12))
* **cip-30:** create cip-30 package ([266e719](https://github.com/input-output-hk/cardano-js-sdk/commit/266e719d8c0b8550e05ff4d8da199a4575c0664e))
* **cip2:** implement defaultSelectionConstraints ([f93e3f1](https://github.com/input-output-hk/cardano-js-sdk/commit/f93e3f1fd860a477f81975ad415d38c3c93c65d9))
* **cip2:** initial implementation of RoundRobinRandomImprove ([17080e2](https://github.com/input-output-hk/cardano-js-sdk/commit/17080e2ee37ed5b3f51affef8dc834ae3943219f))
* **cip30:** create Messaging bridge for WalletAPi ([c3d0515](https://github.com/input-output-hk/cardano-js-sdk/commit/c3d0515d8bd649b5395d38dd311e04d6381b2b63))
* **core|blockfrost:** modify utxo method on provider to return delegations & rewards ([e0a1bf0](https://github.com/input-output-hk/cardano-js-sdk/commit/e0a1bf020c54d66d2c7920e21dc1369cfc912cbf))
* **core:** add `currentWalletProtocolParameters` method to `CardanoProvider` ([af741c0](https://github.com/input-output-hk/cardano-js-sdk/commit/af741c073c48f7f5ad2f065fd50a48af741c133c))
* **core:** add utils originally used in cip2 package ([2314c4f](https://github.com/input-output-hk/cardano-js-sdk/commit/2314c4f4c19bb7ffeadf98ec2a74399cf7722335))
* create in-memory-key-manager package ([a819e5e](https://github.com/input-output-hk/cardano-js-sdk/commit/a819e5e2161a0cd6bd45c61825957efa810530d3))
* **wallet:** add SingleAddressWallet ([5021dde](https://github.com/input-output-hk/cardano-js-sdk/commit/5021dde20e3dbf08c2fa5dff6f244400a9e7dfa3))
* **wallet:** add UTxO repository and in-memory implementation ([1dc98c3](https://github.com/input-output-hk/cardano-js-sdk/commit/1dc98c3da4660b7f1fa58475948f8cf0f98566e3))
* **wallet:** createTransactionInternals ([1aa7032](https://github.com/input-output-hk/cardano-js-sdk/commit/1aa7032421940ef85aa9eb3d0251a79caaaa19d8))


### Bug Fixes

* add missing yarn script, and rename ([840135f](https://github.com/input-output-hk/cardano-js-sdk/commit/840135f7d100c9a00ff410147758ee7d02112897))
* blockfrost types ([4f77001](https://github.com/input-output-hk/cardano-js-sdk/commit/4f77001f5f6264bd6dd254c4e0ef0a8a14cfb820))
* **cardano-graphql-db-sync:** typescript types of graphql responses ([32ab96f](https://github.com/input-output-hk/cardano-js-sdk/commit/32ab96fb609eeb2788cfd75fa15798c441397ca5))
* **cardano-serialization-lib:** load browser variant of cardano-serialization-lib ([dc367e5](https://github.com/input-output-hk/cardano-js-sdk/commit/dc367e5dd64444d5e1c7209227e3d78797c14fe3))
* **cip2:** add fee to selection skeleton ([36e93bc](https://github.com/input-output-hk/cardano-js-sdk/commit/36e93bccb8f5426022631f409b85aa2fe4ea7470))
* **cip2:** change token bundle size constraint arg to CSL.MultiAsset ([4bde8e8](https://github.com/input-output-hk/cardano-js-sdk/commit/4bde8e8fde11908d4295f3f53918faed255f1ba0))
* **cip2:** compute selection limit constraint with actual fee instead of max u64 ([eee4f5e](https://github.com/input-output-hk/cardano-js-sdk/commit/eee4f5e035a20fb61b151d294213978fd8f39302))
* **cip2:** ensure there are no empty change bundles, add some test info to README ([8f3f20b](https://github.com/input-output-hk/cardano-js-sdk/commit/8f3f20ba8de812895844fad0d09eb63104114a83))
* **cip2:** exclude fee from change bundles ([16d7c26](https://github.com/input-output-hk/cardano-js-sdk/commit/16d7c267df0b9f70d1e2ba1afd03e531282686fd))
* **core:** handle values without assets ([e2862b7](https://github.com/input-output-hk/cardano-js-sdk/commit/e2862b7e54ae1ce8eb6b2b2d2e8eb694136ab5ce))
* getBlocks invalid return ([98f495d](https://github.com/input-output-hk/cardano-js-sdk/commit/98f495de0f5e6701b842eaa4567dc8b47d739b27))
* pack and publish scripts ([992993e](https://github.com/input-output-hk/cardano-js-sdk/commit/992993eee5c05b1f64c811795a46d9c34b7d01f6))
* use cardano-node-ogmios in Docker compose file ([300742b](https://github.com/input-output-hk/cardano-js-sdk/commit/300742bf25d51a2f3c964ef8c783b4d983d55d80))
* use isomorphic CSL in InMemoryKeyManager ([7db40cb](https://github.com/input-output-hk/cardano-js-sdk/commit/7db40cb9664659f0c123dfe4da40d06942860483))
* **wallet:** add tx outputs for change, refactor to use update cip2 interface ([3f07d5c](https://github.com/input-output-hk/cardano-js-sdk/commit/3f07d5c7c716ce3e928596c4736be59ca55d4b11))
