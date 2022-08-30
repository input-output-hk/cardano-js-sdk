# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/blockfrost@0.4.0...@cardano-sdk/blockfrost@0.5.0) (2022-08-30)


### ⚠ BREAKING CHANGES

* rm TxAlonzo.implicitCoin
* replace `NetworkInfoProvider.timeSettings` with `eraSummaries`
* logger is now required

### Features

* replace `NetworkInfoProvider.timeSettings` with `eraSummaries` ([58f6fc7](https://github.com/input-output-hk/cardano-js-sdk/commit/58f6fc7c5ace703583c36f95d3d6962483ad924d))


### Bug Fixes

* **blockfrost:** avoid  cip 25 mapping for AssetInfo.TokenMetadata ([9f7b914](https://github.com/input-output-hk/cardano-js-sdk/commit/9f7b9142feadc404d7ae39e3ebfd6ef1496f81ce))


### Code Refactoring

* logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))
* rm TxAlonzo.implicitCoin ([167d205](https://github.com/input-output-hk/cardano-js-sdk/commit/167d205dd15c857b229f968ab53a6e52e5504d3f))



## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/blockfrost@0.4.0) (2022-07-25)

## 0.3.0 (2022-06-24)


### ⚠ BREAKING CHANGES

* remove transactions and blocks methods from blockfrost wallet provider
* move stakePoolStats from wallet provider to stake pool provider
* move jsonToMetadatum from blockfrost package to core.ProviderUtil
* remove TimeSettingsProvider and NetworkInfo.currentEpoch
* split up WalletProvider.utxoDelegationAndRewards
* rename some WalletProvider functions
* validate the correct Ed25519KeyHash length (28 bytes)
* **core:** change WalletProvider.rewardsHistory return type to Map
* make blockfrost API instance a parameter of the providers
* Given transaction submission is really an independent behaviour,
as evidenced by microservices such as the HTTP submission API,
it's more flexible modelled as an independent provider.
* change MetadatumMap type to allow any metadatum as key
* rename AssetInfo metadata->tokenMetadata
* move asset info type from Cardano to Asset
* rename AssetMetadata->TokenMetadata, update fields
* **blockfrost:** update blockHeader fields to new core type
* **blockfrost:** use hex-encoded asset name

### Features

* add optional 'sinceBlock' argument to queryTransactionsByAddresses ([94fdd65](https://github.com/input-output-hk/cardano-js-sdk/commit/94fdd65e0f5b7901081d847eb619a88a1211402c))
* add Provider interface, use as base for TxSubmitProvider ([e155ed4](https://github.com/input-output-hk/cardano-js-sdk/commit/e155ed4efcd1338a54099d1a9034ccbeddeef1cc))
* add WalletProvider.genesisParameters ([1d824fc](https://github.com/input-output-hk/cardano-js-sdk/commit/1d824fc4c7ded176eb045a253b406d6aa31b016a))
* add WalletProvider.queryBlocksByHashes ([f0431b7](https://github.com/input-output-hk/cardano-js-sdk/commit/f0431b7398c9525f50c0b803748cf2fb6195a36f))
* add WalletProvider.rewardsHistory ([d84c980](https://github.com/input-output-hk/cardano-js-sdk/commit/d84c98086a8cb49de47a2ffd78448899cb47036b))
* **blockfrost:** add blockfrostAssetProvider ([8b5acbc](https://github.com/input-output-hk/cardano-js-sdk/commit/8b5acbcfa96b9fa04f43a8747727b75e8d139bd1))
* **blockfrost:** fetch tx metadata, update blockfrost sdk to 2.0.2 ([f5c16a6](https://github.com/input-output-hk/cardano-js-sdk/commit/f5c16a629465df6b4c4db4bb4470420d860b1c7b))
* **blockfrost:** implement TxBodyAlonzo.implicitCoin ([99d9b41](https://github.com/input-output-hk/cardano-js-sdk/commit/99d9b416dd173fe595c868c67e8e838e4cad9127))
* **blockfrost:** wrap submitTx error in UnknownTxSubmissionError ([8244f6b](https://github.com/input-output-hk/cardano-js-sdk/commit/8244f6b814b4483e3d0c279573f3ee360e358134))
* **core:** add cslToCore.txInputs, make ProtocolParamsRequiredByWallet fields required ([d67097e](https://github.com/input-output-hk/cardano-js-sdk/commit/d67097ee1fe4c38bd5b37c40795c4737e9a19f68))
* extend NetworkInfo interface ([7b40bca](https://github.com/input-output-hk/cardano-js-sdk/commit/7b40bca2a34c80e9f746339939ed5ce9412e52e9))


### Bug Fixes

* **blockfrost:** add e2e test for getAsset, fix it to call blockfrost method on api obj ([10a79bc](https://github.com/input-output-hk/cardano-js-sdk/commit/10a79bc951ea7442f0526e0a84010adb4491deb5))
* **blockfrost:** add support to genesis delegate as slot leader ([ab8766f](https://github.com/input-output-hk/cardano-js-sdk/commit/ab8766f40a270f9db74526185dc3b929900a080a))
* **blockfrost:** added e2e test and fix for collaterals ([c53263e](https://github.com/input-output-hk/cardano-js-sdk/commit/c53263eb44088fc5e254564df49354efd790d8a8))
* **blockfrost:** do not re-fetch protocol parameters for every tx ([3748065](https://github.com/input-output-hk/cardano-js-sdk/commit/37480659aabda979892c5bfa2c7c54af111249fb))
* **blockfrost:** ensure tx metadata number type aligns with core ([ad0eafd](https://github.com/input-output-hk/cardano-js-sdk/commit/ad0eafdeb0953f96ea201b1d0f9a10080ca2b71e))
* **blockfrost:** interpret 404s in Blockfrost provider and optimise batching ([a795e4c](https://github.com/input-output-hk/cardano-js-sdk/commit/a795e4c70464ad0bbed714b69e826ee3f11be92c))
* **blockfrost:** refactored BlockfrostToCore ([112a1c2](https://github.com/input-output-hk/cardano-js-sdk/commit/112a1c21387c2bd819d7cbfccbd40073b40091a4))
* **blockfrost:** set correct testnet network magic ([b0db9dd](https://github.com/input-output-hk/cardano-js-sdk/commit/b0db9dd687bb4f1692d37d4cc43cb1e73372ed69))
* **blockfrost:** sort certificates by cert_index ([8a04a27](https://github.com/input-output-hk/cardano-js-sdk/commit/8a04a27514ec2f7dbf74b1962f992d47074f9e88))
* change stakepool metadata extVkey field type to bech32 string ([ec523a7](https://github.com/input-output-hk/cardano-js-sdk/commit/ec523a78e62ba30c4297ccd71eb6070dbd58acc3))
* **cip2:** remove hardcoded value in minimum cost selection constraint ([ad6d133](https://github.com/input-output-hk/cardano-js-sdk/commit/ad6d133a0ba1f865bf2ae1ca3f46b8e6f918502b))
* resolve issues preventing to make a delegation tx ([7429f46](https://github.com/input-output-hk/cardano-js-sdk/commit/7429f466763342b08b6bed44f23d3bf24dbf92f2))
* validate the correct Ed25519KeyHash length (28 bytes) ([0e0b592](https://github.com/input-output-hk/cardano-js-sdk/commit/0e0b592e2b4b0689f592076cd79dfaac88b43c57))


### Code Refactoring

* **blockfrost:** update blockHeader fields to new core type ([2a20818](https://github.com/input-output-hk/cardano-js-sdk/commit/2a20818507ec44e9d4aff2647a8095aa92a7a5b9))
* **blockfrost:** use hex-encoded asset name ([41f3039](https://github.com/input-output-hk/cardano-js-sdk/commit/41f30394c53bd7e16728ae1e3862e659822253f9))
* change MetadatumMap type to allow any metadatum as key ([48c33e5](https://github.com/input-output-hk/cardano-js-sdk/commit/48c33e552406cce35ea19d720451a1ba641ff51b))
* **core:** change WalletProvider.rewardsHistory return type to Map ([07ace58](https://github.com/input-output-hk/cardano-js-sdk/commit/07ace5887e9fed02f5ccb8090594022cd3df28d9))
* extract tx submit into own provider ([1d7ac73](https://github.com/input-output-hk/cardano-js-sdk/commit/1d7ac7393fbd669f08b516c4067883d982f2e711))
* make blockfrost API instance a parameter of the providers ([52b2bda](https://github.com/input-output-hk/cardano-js-sdk/commit/52b2bda4574cb9c7cacf2e3e02ced5ada2c58dd3))
* move asset info type from Cardano to Asset ([212b670](https://github.com/input-output-hk/cardano-js-sdk/commit/212b67041598cbcc2c2cf4f5678928943de7aa29))
* move jsonToMetadatum from blockfrost package to core.ProviderUtil ([adeb02c](https://github.com/input-output-hk/cardano-js-sdk/commit/adeb02cdbb1401ff4e9c43d28263357d6f27b0d6))
* move stakePoolStats from wallet provider to stake pool provider ([52d71a7](https://github.com/input-output-hk/cardano-js-sdk/commit/52d71a70700b05902cca6205fe01a63f811ba5af))
* remove TimeSettingsProvider and NetworkInfo.currentEpoch ([4a8f72f](https://github.com/input-output-hk/cardano-js-sdk/commit/4a8f72f57f699f7c0bf4a9a4b742fc0a3e4aa8ce))
* remove transactions and blocks methods from blockfrost wallet provider ([e4de136](https://github.com/input-output-hk/cardano-js-sdk/commit/e4de13650f0d387b8e7126077e8721f353af8c85))
* rename AssetInfo metadata->tokenMetadata ([f064f37](https://github.com/input-output-hk/cardano-js-sdk/commit/f064f372b3d7273c24d78695ceac7254fa55e51f))
* rename AssetMetadata->TokenMetadata, update fields ([a83b897](https://github.com/input-output-hk/cardano-js-sdk/commit/a83b89748ec7efe7dcdbb849ab4b369dd49e5fcc))
* rename some WalletProvider functions ([72ad875](https://github.com/input-output-hk/cardano-js-sdk/commit/72ad875ca8e9c3b65c23794a95ca4110cf34a034))
* split up WalletProvider.utxoDelegationAndRewards ([18f5a57](https://github.com/input-output-hk/cardano-js-sdk/commit/18f5a571cb9d581007182b39d2c68b38491c70e6))

### 0.1.5 (2021-10-27)


### Features

* add WalletProvider.transactionDetails, add address to TxIn ([889a39b](https://github.com/input-output-hk/cardano-js-sdk/commit/889a39b1feb988144dd2249c6c47f91e8096fd48))
* **cardano-graphql:** implement CardanoGraphQLStakePoolSearchProvider (wip) ([80deda6](https://github.com/input-output-hk/cardano-js-sdk/commit/80deda6963a0c07b2f0b24a0a5465c488305d83c))


### Bug Fixes

* **blockfrost:** early return from tallyPools function ([2ab1afc](https://github.com/input-output-hk/cardano-js-sdk/commit/2ab1afcce3f7b02b17352a8abe82b5adb17d8d52))
* **blockfrost:** invalid handling of timestamp ([eed927c](https://github.com/input-output-hk/cardano-js-sdk/commit/eed927ce579426eef38a15797d2223e8df21a40f))

### 0.1.3 (2021-10-05)

### 0.1.2 (2021-09-30)

### 0.1.1 (2021-09-30)


### Features

* add CardanoProvider.networkInfo ([1596ac2](https://github.com/input-output-hk/cardano-js-sdk/commit/1596ac27b3fa3494f784db37831f85e06a8e0e03))
* add CardanoProvider.stakePoolStats ([c25e570](https://github.com/input-output-hk/cardano-js-sdk/commit/c25e5704be13a9c259fa399e35a3771caad58d38))
* add maxTxSize to `ProtocolParametersRequiredByWallet` ([a9a5d16](https://github.com/input-output-hk/cardano-js-sdk/commit/a9a5d16db18fbf2a4cbbad1ad1cdf3f42ef891f9))
* add Provider.ledgerTip ([0e7d224](https://github.com/input-output-hk/cardano-js-sdk/commit/0e7d224a8b3315991785a1a6393d60f35b757e6a))
* **blockfrost:** create new provider called blockfrost ([b8bd72f](https://github.com/input-output-hk/cardano-js-sdk/commit/b8bd72ffc91769e525400a898cf8e7a749b7d610))
* **cip-30:** create cip-30 package ([266e719](https://github.com/input-output-hk/cardano-js-sdk/commit/266e719d8c0b8550e05ff4d8da199a4575c0664e))
* **core|blockfrost:** modify utxo method on provider to return delegations & rewards ([e0a1bf0](https://github.com/input-output-hk/cardano-js-sdk/commit/e0a1bf020c54d66d2c7920e21dc1369cfc912cbf))
* **core:** add `currentWalletProtocolParameters` method to `CardanoProvider` ([af741c0](https://github.com/input-output-hk/cardano-js-sdk/commit/af741c073c48f7f5ad2f065fd50a48af741c133c))
* create in-memory-key-manager package ([a819e5e](https://github.com/input-output-hk/cardano-js-sdk/commit/a819e5e2161a0cd6bd45c61825957efa810530d3))


### Bug Fixes

* add missing yarn script, and rename ([840135f](https://github.com/input-output-hk/cardano-js-sdk/commit/840135f7d100c9a00ff410147758ee7d02112897))
* blockfrost types ([4f77001](https://github.com/input-output-hk/cardano-js-sdk/commit/4f77001f5f6264bd6dd254c4e0ef0a8a14cfb820))
