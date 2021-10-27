# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [0.1.5](https://github.com/input-output-hk/cardano-js-sdk/compare/0.1.4...0.1.5) (2021-10-27)


### Features

* add WalletProvider.transactionDetails, add address to TxIn ([889a39b](https://github.com/input-output-hk/cardano-js-sdk/commit/889a39b1feb988144dd2249c6c47f91e8096fd48))
* **cardano-graphql:** dgraph integration ([e1195e9](https://github.com/input-output-hk/cardano-js-sdk/commit/e1195e9cd9da84d49fb4160d5e2c69f134afdcac))
* **cardano-graphql:** generate graphql client from shema+operations ([9632eb4](https://github.com/input-output-hk/cardano-js-sdk/commit/9632eb40263cabc0eea8ff813180be90af63eacb))
* **cardano-graphql:** generate graphql schema from ts code ([a3e90ad](https://github.com/input-output-hk/cardano-js-sdk/commit/a3e90ad8e5c790ea250bc779b7e10f4657cdccbd))
* **cardano-graphql:** implement CardanoGraphQLStakePoolSearchProvider (wip) ([80deda6](https://github.com/input-output-hk/cardano-js-sdk/commit/80deda6963a0c07b2f0b24a0a5465c488305d83c))
* **cardano-graphql:** implement search stake pools via dgraph schema ([5487db8](https://github.com/input-output-hk/cardano-js-sdk/commit/5487db818c8a91c8648836d13febfd150392d390))
* **cardano-graphql:** initial implementation of StakePoolSearchClient ([8f4f72a](https://github.com/input-output-hk/cardano-js-sdk/commit/8f4f72af7f6ca61b025f2d98e2edf24108b6e38c))
* **core:** isAddress util ([3f53e79](https://github.com/input-output-hk/cardano-js-sdk/commit/3f53e79f08fd0fd10764c3c648e356d368398df5))
* **util-dev:** add createStubStakePoolSearchProvider ([2e0906b](https://github.com/input-output-hk/cardano-js-sdk/commit/2e0906bc19acdf91b805e1eb647e88aa33ed1b7b))


### Bug Fixes

* **blockfrost:** early return from tallyPools function ([2ab1afc](https://github.com/input-output-hk/cardano-js-sdk/commit/2ab1afcce3f7b02b17352a8abe82b5adb17d8d52))
* **blockfrost:** invalid handling of timestamp ([eed927c](https://github.com/input-output-hk/cardano-js-sdk/commit/eed927ce579426eef38a15797d2223e8df21a40f))
* **wallet:** make txTracker not optional to ensure it's the same as UtxoRepository uses ([653b8d9](https://github.com/input-output-hk/cardano-js-sdk/commit/653b8d90409e79e6624f01368ebb73f61aac1aeb))

### [0.1.4](https://github.com/input-output-hk/cardano-js-sdk/compare/0.1.3...0.1.4) (2021-10-14)


### Features

* **cip2:** add support for implicit coin ([47f6bd2](https://github.com/input-output-hk/cardano-js-sdk/commit/47f6bd2ee714ff9b6b9d8d311f2b3526f88a1a2b))
* **core:** add cslToOgmios.txIn ([5bb937e](https://github.com/input-output-hk/cardano-js-sdk/commit/5bb937e277e3fd23991db2cff1c1ec574904e048))
* **core:** add cslUtil.bytewiseEquals ([1851eb4](https://github.com/input-output-hk/cardano-js-sdk/commit/1851eb4749f8cc43c11acec30377ea5c2f42671a))
* **core:** add NotImplementedError ([5344969](https://github.com/input-output-hk/cardano-js-sdk/commit/534496926a6034f4cea401efa0bb23622b1cb3e6))
* **util-dev:** add flushPromises util ([19eb508](https://github.com/input-output-hk/cardano-js-sdk/commit/19eb508af9c5364f9db604cfe4705857cd62f720))
* **wallet:** add balance interface ([48a820f](https://github.com/input-output-hk/cardano-js-sdk/commit/48a820f57d50ec320d2f80ce236371e95ae5aeff))
* **wallet:** add SingleAddressWallet.balance ([01cda8f](https://github.com/input-output-hk/cardano-js-sdk/commit/01cda8fa6c6ba611a571cc5184a2cb8684f3941c))
* **wallet:** add support for transaction certs and withdrawals ([d8842b0](https://github.com/input-output-hk/cardano-js-sdk/commit/d8842b0ff2f64b0f6899113d4d61d2aefda569ad))
* **wallet:** add utility to create withdrawal ([c49f782](https://github.com/input-output-hk/cardano-js-sdk/commit/c49f7822b58c25a6d7d928f19790d4e45730ef60))
* **wallet:** add UtxoRepository.availableRewards and fix availableUtxo sync ([4f9b13f](https://github.com/input-output-hk/cardano-js-sdk/commit/4f9b13fe043d2c700db4f454bb6454dd4e5e62f4))
* **wallet:** add UtxoRepositoryEvent.Changed ([42e0753](https://github.com/input-output-hk/cardano-js-sdk/commit/42e07535fd6c3f4d1adbe38ee41edfc04a13865c))
* **wallet:** implement BalanceTracker, refactor tests: move all test mocks under ./mocks ([28746ca](https://github.com/input-output-hk/cardano-js-sdk/commit/28746ca214a485bbceb0aae932e6ce3e156eb849))
* **wallet:** implement UTxO lock/unlock functionality, fix utxo sync ([3b6a935](https://github.com/input-output-hk/cardano-js-sdk/commit/3b6a935a440beb961ea6b555bce753ed05a92cdd))
* **wallet:** utilities to create pool certificates, pass implicit coin to input selection ([b5bfbc8](https://github.com/input-output-hk/cardano-js-sdk/commit/b5bfbc8dd850bae20f104df1f5d440dd3940ebb6))


### Bug Fixes

* **wallet:** lock utxo right after submitting, run input selection with availableUtxo set ([0008368](https://github.com/input-output-hk/cardano-js-sdk/commit/0008368293f9dac705fdcbd7e240e0e88046f7e8))

### [0.1.3](https://github.com/input-output-hk/cardano-js-sdk/compare/0.1.2...0.1.3) (2021-10-05)


### Features

* **wallet:** add SingleAddressWallet.name ([7eb4e78](https://github.com/input-output-hk/cardano-js-sdk/commit/7eb4e78cb557c92da038d91b3e4507d873d46818))

### [0.1.2](https://github.com/input-output-hk/cardano-js-sdk/compare/0.1.1...0.1.2) (2021-09-30)


### Bug Fixes

* add missing dependencies ([2d3bfbc](https://github.com/input-output-hk/cardano-js-sdk/commit/2d3bfbc3f8d5fdce3be64835c57304b540e05811))

### 0.1.1 (2021-09-30)


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
