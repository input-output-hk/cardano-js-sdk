# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.5.1-nightly.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/core@0.5.0...@cardano-sdk/core@0.5.1-nightly.0) (2022-08-31)

**Note:** Version bump only for package @cardano-sdk/core





## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/core@0.4.0...@cardano-sdk/core@0.5.0) (2022-08-30)


### ⚠ BREAKING CHANGES

* rm TxAlonzo.implicitCoin
* removed Ogmios schema package dependency
* **core:** added native script type and serialization functions.
* replace `NetworkInfoProvider.timeSettings` with `eraSummaries`
* logger is now required
* update min utxo computation to be Babbage-compatible

### Features

* **core:** added native script type and serialization functions. ([51b46c8](https://github.com/input-output-hk/cardano-js-sdk/commit/51b46c83909ce0f978ea81d1542315eab707d511))
* **core:** export cslUtil MIN_I64 and MAX_I64 consts ([618eef0](https://github.com/input-output-hk/cardano-js-sdk/commit/618eef04e7c9d2e27d2b0c5a9f1a172d340abde4))
* extend HealthCheckResponse ([2e6d0a3](https://github.com/input-output-hk/cardano-js-sdk/commit/2e6d0a3d2067ce8538886f1a9d0d55fab7647ae9))
* replace `NetworkInfoProvider.timeSettings` with `eraSummaries` ([58f6fc7](https://github.com/input-output-hk/cardano-js-sdk/commit/58f6fc7c5ace703583c36f95d3d6962483ad924d))


### Bug Fixes

* update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))


### Code Refactoring

* logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))
* removed Ogmios schema package dependency ([4ed2408](https://github.com/input-output-hk/cardano-js-sdk/commit/4ed24087aa5646c6f68ba31c42fc3f8a317df3b9))
* rm TxAlonzo.implicitCoin ([167d205](https://github.com/input-output-hk/cardano-js-sdk/commit/167d205dd15c857b229f968ab53a6e52e5504d3f))



## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/core@0.4.0) (2022-07-25)


### ⚠ BREAKING CHANGES

* update min utxo computation to be Babbage-compatible

### Features

* add new `apy` sort field to stake pools ([161ccd8](https://github.com/input-output-hk/cardano-js-sdk/commit/161ccd83c318bb874e59c39cbb9fc1f9b94e3e32))
* **core:** accept common ipfs hash without protocol for nft metadata uri ([f1878e3](https://github.com/input-output-hk/cardano-js-sdk/commit/f1878e39b63800d451db1f97624f041f4f424567))
* **core:** added Ed25519PrivateKey to keys ([db1f42c](https://github.com/input-output-hk/cardano-js-sdk/commit/db1f42c9d21115e43a1581de077b5f4f9c84ca43))
* **core:** adds util to get a tx from its body ([f680720](https://github.com/input-output-hk/cardano-js-sdk/commit/f680720f8bd6610871aad587e4a198de9190e229))
* sort stake pools by fixed cost ([6e1d6e4](https://github.com/input-output-hk/cardano-js-sdk/commit/6e1d6e4179794aa92b7d3279e3534beb2ac29978))
* support any network by fetching time settings from the node ([08d9ed2](https://github.com/input-output-hk/cardano-js-sdk/commit/08d9ed2b6aa20cf4df2a063f046f4e5ca28c6bd5))


### Bug Fixes

* update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))

## 0.3.0 (2022-06-24)


### ⚠ BREAKING CHANGES

* remove transactions and blocks methods from blockfrost wallet provider
* move stakePoolStats from wallet provider to stake pool provider
* rename `StakePoolSearchProvider` to `StakePoolProvider`
* add serializable object key transformation support
* move jsonToMetadatum from blockfrost package to core.ProviderUtil
* delete nftMetadataProvider and remove it from AssetTracker
* **core:** changes value sent and received inspectors
* remove TimeSettingsProvider and NetworkInfo.currentEpoch
* split up WalletProvider.utxoDelegationAndRewards
* rename some WalletProvider functions
* makeTxIn.address required, add NewTxIn that has no address
* **core:** rm epoch? from core certificate types
* **core:** set tx body scriptIntegrityHash to correct length (32 byte)
* validate the correct Ed25519KeyHash length (28 bytes)
* **core:** remove PoolRegistrationCertificate.poolId
* **core:** make StakeDelegationCertificate.epoch optional
* change TimeSettings interface from fn to obj
* **core:** nest errors under TxSubmissionErrors object
* **core:** change WalletProvider.rewardsHistory return type to Map
* Given transaction submission is really an independent behaviour,
as evidenced by microservices such as the HTTP submission API,
it's more flexible modelled as an independent provider.
* change MetadatumMap type to allow any metadatum as key
* rename AssetInfo metadata->tokenMetadata
* **core:** support T | T[] where appropriate in metadatumToCip25
* move asset info type from Cardano to Asset
* rename AssetMetadata->TokenMetadata, update fields
* update ogmios to 5.1.0
* **core:** add support to genesis delegate as slot leader
* **core:** add support for base58-encoded addresses
* **core:** move StakePool.metadata under PoolParameters
* **core:** align Tip and PartialBlockHeader types
* **core:** change type of Asset.name to AssetName
* **core:** remove AssetMintOrBurn.action in favor of using negative qty for burn

### Features

* add ChainHistory http provider ([64aa7ae](https://github.com/input-output-hk/cardano-js-sdk/commit/64aa7aeff061aa2cf9bc6196347f6cf5b9c7f6be))
* add optional 'sinceBlock' argument to queryTransactionsByAddresses ([94fdd65](https://github.com/input-output-hk/cardano-js-sdk/commit/94fdd65e0f5b7901081d847eb619a88a1211402c))
* add Provider interface, use as base for TxSubmitProvider ([e155ed4](https://github.com/input-output-hk/cardano-js-sdk/commit/e155ed4efcd1338a54099d1a9034ccbeddeef1cc))
* add sort stake pools by saturation ([#270](https://github.com/input-output-hk/cardano-js-sdk/issues/270)) ([2a9abff](https://github.com/input-output-hk/cardano-js-sdk/commit/2a9abffae06fc462e1811430c0dc8dfa4520091c))
* add StakePool.status and a few other minor improvements to StakePool types ([1405d05](https://github.com/input-output-hk/cardano-js-sdk/commit/1405d05ca29bac3863178512a73d3a67ee4b7af5))
* add totalResultCount to StakePoolSearch response ([4265f6a](https://github.com/input-output-hk/cardano-js-sdk/commit/4265f6af60a92c93604b93167fd297530b6e01f8))
* add utxo http provider ([a55fcdb](https://github.com/input-output-hk/cardano-js-sdk/commit/a55fcdb08276c37a1852f0c39e5b0a78501ddf0b))
* add WalletProvider.genesisParameters ([1d824fc](https://github.com/input-output-hk/cardano-js-sdk/commit/1d824fc4c7ded176eb045a253b406d6aa31b016a))
* add WalletProvider.queryBlocksByHashes ([f0431b7](https://github.com/input-output-hk/cardano-js-sdk/commit/f0431b7398c9525f50c0b803748cf2fb6195a36f))
* add WalletProvider.rewardsHistory ([d84c980](https://github.com/input-output-hk/cardano-js-sdk/commit/d84c98086a8cb49de47a2ffd78448899cb47036b))
* **blockfrost:** fetch tx metadata, update blockfrost sdk to 2.0.2 ([f5c16a6](https://github.com/input-output-hk/cardano-js-sdk/commit/f5c16a629465df6b4c4db4bb4470420d860b1c7b))
* **cardano-services:** stake pool search http server ([c3dd013](https://github.com/input-output-hk/cardano-js-sdk/commit/c3dd0133843327906535ce2ac623482cf95dd397))
* **core:** add 'activating' stakepool status, change certificate enum values to match type names ([59129b5](https://github.com/input-output-hk/cardano-js-sdk/commit/59129b5101a5c8fdc7face33357939db968b2924))
* **core:** add 'bytesToHex', 'HexBlob' and 'castHexBlob' utils ([dc33f15](https://github.com/input-output-hk/cardano-js-sdk/commit/dc33f153288255b256453209433f08dae1a22291))
* **core:** add BigIntMath.max, export Cardano.RewardAccount type ([bc14ec8](https://github.com/input-output-hk/cardano-js-sdk/commit/bc14ec8d61854f218d861dc01750030d11f8b336))
* **core:** add Bip32PublicKey and Bip32PrivateKey types, export Witness.Signatures type ([999c33f](https://github.com/input-output-hk/cardano-js-sdk/commit/999c33f03e82f302c68ce8b1685bfc6e44e1621e))
* **core:** add coreToCsl.tokenMap ([e864228](https://github.com/input-output-hk/cardano-js-sdk/commit/e86422822faa2d1ddf72d5eed1956b34dcdfef7f))
* **core:** add coreToCsl.txAuxiliaryData ([8686610](https://github.com/input-output-hk/cardano-js-sdk/commit/8686610d776471c96fdc1969b946edd8d26eff23))
* **core:** add coreToCsl.txMint ([16261c6](https://github.com/input-output-hk/cardano-js-sdk/commit/16261c6958dffd59f1cc0c330ffb657ff86e9be3))
* **core:** add cslToCore.txInputs, make ProtocolParamsRequiredByWallet fields required ([d67097e](https://github.com/input-output-hk/cardano-js-sdk/commit/d67097ee1fe4c38bd5b37c40795c4737e9a19f68))
* **core:** add cslToCore.utxo ([d497928](https://github.com/input-output-hk/cardano-js-sdk/commit/d497928628a1aaa980898bccb2da98d2c6a19747))
* **core:** add Date support for serializableObject ([d6dc693](https://github.com/input-output-hk/cardano-js-sdk/commit/d6dc693781202d808becbceacd45dd5e1dba6619))
* **core:** add metadatum parsing utils ([51a57ab](https://github.com/input-output-hk/cardano-js-sdk/commit/51a57ab3aebfb67aec1ed5080912cfc0ed68fe40))
* **core:** add optional 'options' argument to StakePoolSearchProvider.queryStakePools ([6ae18a6](https://github.com/input-output-hk/cardano-js-sdk/commit/6ae18a6915d771baef6d7104dfaf0f1054f93be8))
* **core:** add ProviderFailure.Unhealthy ([98fb4a7](https://github.com/input-output-hk/cardano-js-sdk/commit/98fb4a7ac85b0b1bde8977e1c8b6035e7d484cbf))
* **core:** add ProviderUtil.withProviderErrors ([d5bad75](https://github.com/input-output-hk/cardano-js-sdk/commit/d5bad75a78ea1b5dc1741b30f37d8422298449c8))
* **core:** add serializable obj support for custom transformed field discriminator key ([63cf354](https://github.com/input-output-hk/cardano-js-sdk/commit/63cf3549ad84c59c2561e15d633f9757f4a53016))
* **core:** add SerializationFailures: InvalidType, Overflow ([cd262a7](https://github.com/input-output-hk/cardano-js-sdk/commit/cd262a7ec8b58b3e73771b3677db0788636f66dd))
* **core:** add slot time computation util ([17fc677](https://github.com/input-output-hk/cardano-js-sdk/commit/17fc677e1b75579c8ee08d5c6c4d710b41aa7907))
* **core:** add slotEpochCalc util ([d190853](https://github.com/input-output-hk/cardano-js-sdk/commit/d190853a026bc9dd7d98451e5e8afcd4077e997b))
* **core:** add SlotEpochInfoCalc ([c0d3145](https://github.com/input-output-hk/cardano-js-sdk/commit/c0d3145355561472c616fedcaea34adde6300617))
* **core:** add StakePool.epochRewards and estimateStakePoolAPY util ([ff69031](https://github.com/input-output-hk/cardano-js-sdk/commit/ff69031b19b5d902b8bb54e7440ccd334aa68b71))
* **core:** add TimeSettingsProvider type ([602fa88](https://github.com/input-output-hk/cardano-js-sdk/commit/602fa88d04567fb8b7ea00917ccaea56b438f032))
* **core:** add util to create AssetId from PolicyId and AssetName ([aef3345](https://github.com/input-output-hk/cardano-js-sdk/commit/aef334546d53be746608129a96fc5032d67cd1c0))
* **core:** add utils for custom string types, safer pool id types ([bd430f6](https://github.com/input-output-hk/cardano-js-sdk/commit/bd430f6d1db5ff3c1f3a78317b68811eb4794b6e))
* **core:** added optional close method to Provider ([69b49cc](https://github.com/input-output-hk/cardano-js-sdk/commit/69b49cc6e7730ea4e1387085dbca3c6db8aee309))
* **core:** cslToCore stake delegation certificate ([1703828](https://github.com/input-output-hk/cardano-js-sdk/commit/1703828583ea9c14fcb9aabf7d92590fc0c06b0b))
* **core:** export NativeScriptType ([92707b6](https://github.com/input-output-hk/cardano-js-sdk/commit/92707b680069b96af4c8cebd7aaf5aa32327b300))
* **core:** export TxSubmissionError type and its variants ([d562a61](https://github.com/input-output-hk/cardano-js-sdk/commit/d562a619b97ae3f8b3d5e92f2f4cb3b4bd6a73ca))
* **core:** extend StakePoolQueryOptions with sort ([9a5d3ba](https://github.com/input-output-hk/cardano-js-sdk/commit/9a5d3ba7bd299dbb5a2fed6aa45cbd6497feda2a))
* **core:** hoist computeImplicitCoin from wallet package ([d991f73](https://github.com/input-output-hk/cardano-js-sdk/commit/d991f73982af48f18386077614693a78d2c420bf))
* **core:** initial cslToCore.newTx implementation ([52835f2](https://github.com/input-output-hk/cardano-js-sdk/commit/52835f279381e79422b1a6761cabc3a6b6144961))
* **core:** introduces transaction inspection utility ([a887733](https://github.com/input-output-hk/cardano-js-sdk/commit/a887733267339cfcade9efae9aec240b2f70d388))
* **core:** isAddressWithin + isOutgoing address utils ([65003b5](https://github.com/input-output-hk/cardano-js-sdk/commit/65003b5314900e15f5842bb9518b35a69b6931b8))
* **core:** partial support for legacy base58 addresses ([0f4cb28](https://github.com/input-output-hk/cardano-js-sdk/commit/0f4cb2835efc9baf8a0e2d7921da59fe70fae1d7))
* **core:** partial support for ShelleyGenesis PoolId ([51bcfb6](https://github.com/input-output-hk/cardano-js-sdk/commit/51bcfb6ae4357477735dbaccd6c40d2c18a28d8e))
* **core:** txSubmissionError util ([1f8dc0f](https://github.com/input-output-hk/cardano-js-sdk/commit/1f8dc0f7ebd3219dbcaaef595262b96813ea67bc))
* create InMemoryCache ([a2bfcc6](https://github.com/input-output-hk/cardano-js-sdk/commit/a2bfcc62c25e71d78d07b961267d7ce9679b6cf4))
* extend NetworkInfo interface ([7b40bca](https://github.com/input-output-hk/cardano-js-sdk/commit/7b40bca2a34c80e9f746339939ed5ce9412e52e9))
* rewards data ([5ce2ff0](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce2ff00856d362cf0e423ddadadb15cef764932))
* **wallet:** add signed certificate inspector ([e58ce48](https://github.com/input-output-hk/cardano-js-sdk/commit/e58ce488ac34bde325d2cebacef13b1ac0bdd2d9))


### Bug Fixes

* **blockfrost:** interpret 404s in Blockfrost provider and optimise batching ([a795e4c](https://github.com/input-output-hk/cardano-js-sdk/commit/a795e4c70464ad0bbed714b69e826ee3f11be92c))
* change stakepool metadata extVkey field type to bech32 string ([ec523a7](https://github.com/input-output-hk/cardano-js-sdk/commit/ec523a78e62ba30c4297ccd71eb6070dbd58acc3))
* **core:** add support for base58-encoded addresses ([b3dc768](https://github.com/input-output-hk/cardano-js-sdk/commit/b3dc7680cbc44c2864d4ea6476e28ae9bbbcc9ab))
* **core:** add support to genesis delegate as slot leader ([d1c098c](https://github.com/input-output-hk/cardano-js-sdk/commit/d1c098cc4dcd34421336cc0516d0a2a59ff355e1))
* **core:** consider empty string a hex value ([3d55224](https://github.com/input-output-hk/cardano-js-sdk/commit/3d552242fb7c9fe5fdf35a9d728b53ae16070432))
* **core:** correct metadata length check ([5394bed](https://github.com/input-output-hk/cardano-js-sdk/commit/5394bedc6cf5db819e74a8de98094fc55bc836fd))
* **core:** export Address module from root ([2a1d775](https://github.com/input-output-hk/cardano-js-sdk/commit/2a1d7758d740b1cbea1339fdd25b3b4ac40ba7a3))
* **core:** finalize cslToCore tx metadata conversion ([eb5740f](https://github.com/input-output-hk/cardano-js-sdk/commit/eb5740ff00b288cfcc6769997e911dc150c16d90))
* **core:** finalize cslToCore.newTx ([2cc40aa](https://github.com/input-output-hk/cardano-js-sdk/commit/2cc40aa0cb065513ba195c0bfb256a3fc8eb7162))
* **core:** remove duplicated insert when assets from the same policy are present in the token map ([7466bac](https://github.com/input-output-hk/cardano-js-sdk/commit/7466bacd7b6feadc56fb77fb71ea44db4f9702a8))
* **core:** set tx body scriptIntegrityHash to correct length (32 byte) ([37822ce](https://github.com/input-output-hk/cardano-js-sdk/commit/37822ce14093ee6e7849fe9c72bd70f86d576a79))
* **core:** support T | T[] where appropriate in metadatumToCip25 ([1a873ec](https://github.com/input-output-hk/cardano-js-sdk/commit/1a873ec182c901813feae8244c86c0346bb70022))
* **core:** throw serialization error for invalid metadata fields ([d67debb](https://github.com/input-output-hk/cardano-js-sdk/commit/d67debb96781474eed775e524fabb3ee48827ea3))
* **core:** tx error mapping fix ([#210](https://github.com/input-output-hk/cardano-js-sdk/issues/210)) ([a03edcd](https://github.com/input-output-hk/cardano-js-sdk/commit/a03edcd806b9038d060ac772b35fccc5819a53ac))
* resolve issues preventing to make a delegation tx ([7429f46](https://github.com/input-output-hk/cardano-js-sdk/commit/7429f466763342b08b6bed44f23d3bf24dbf92f2))
* rm imports from @cardano-sdk/*/src/* ([3fdead3](https://github.com/input-output-hk/cardano-js-sdk/commit/3fdead3ae381a3efb98299b9881c6a964461b7db))
* validate the correct Ed25519KeyHash length (28 bytes) ([0e0b592](https://github.com/input-output-hk/cardano-js-sdk/commit/0e0b592e2b4b0689f592076cd79dfaac88b43c57))


### Miscellaneous Chores

* update ogmios to 5.1.0 ([973bf9e](https://github.com/input-output-hk/cardano-js-sdk/commit/973bf9e6b74f51167f8a1c45560eaabd37bb8525))


### Code Refactoring

* add serializable object key transformation support ([32e422e](https://github.com/input-output-hk/cardano-js-sdk/commit/32e422e83f723a41521193d9cf4206a538fbcb43))
* change MetadatumMap type to allow any metadatum as key ([48c33e5](https://github.com/input-output-hk/cardano-js-sdk/commit/48c33e552406cce35ea19d720451a1ba641ff51b))
* change TimeSettings interface from fn to obj ([bc3b22d](https://github.com/input-output-hk/cardano-js-sdk/commit/bc3b22d55071f85073c54dcf47c535912bedb512))
* **core:** align Tip and PartialBlockHeader types ([a5d5e49](https://github.com/input-output-hk/cardano-js-sdk/commit/a5d5e494cbc65ce61c84decab228acbeb40ef1d5))
* **core:** change type of Asset.name to AssetName ([ced96ed](https://github.com/input-output-hk/cardano-js-sdk/commit/ced96ed100c06afc855ab0bc526180ba5f5152ce))
* **core:** change WalletProvider.rewardsHistory return type to Map ([07ace58](https://github.com/input-output-hk/cardano-js-sdk/commit/07ace5887e9fed02f5ccb8090594022cd3df28d9))
* **core:** changes value sent and received inspectors ([bdecf31](https://github.com/input-output-hk/cardano-js-sdk/commit/bdecf31b5e316c99e526b2555fa3713842258d79))
* **core:** make StakeDelegationCertificate.epoch optional ([3c6155b](https://github.com/input-output-hk/cardano-js-sdk/commit/3c6155b0bc5da5f9724c5604ee19eb9082b4af8f))
* **core:** move StakePool.metadata under PoolParameters ([9a9ac26](https://github.com/input-output-hk/cardano-js-sdk/commit/9a9ac26e3e0cedc10fc80810af11b9d4e0a36467))
* **core:** nest errors under TxSubmissionErrors object ([6e61857](https://github.com/input-output-hk/cardano-js-sdk/commit/6e618570957a655d856f45e4e52d17bf3b164def))
* **core:** remove AssetMintOrBurn.action in favor of using negative qty for burn ([993f53a](https://github.com/input-output-hk/cardano-js-sdk/commit/993f53aed4c192a57ca26526c3ddd879befbd796))
* **core:** remove PoolRegistrationCertificate.poolId ([c73ac29](https://github.com/input-output-hk/cardano-js-sdk/commit/c73ac29e7120cd7fc57a1f262244e20c26cae78a))
* **core:** rm epoch? from core certificate types ([cc904a1](https://github.com/input-output-hk/cardano-js-sdk/commit/cc904a1b2ee5002b71c8f94bddc50db0effb52ad))
* delete nftMetadataProvider and remove it from AssetTracker ([2904cc3](https://github.com/input-output-hk/cardano-js-sdk/commit/2904cc32a60734e2972425c96c67a2a590c7d2cb))
* extract tx submit into own provider ([1d7ac73](https://github.com/input-output-hk/cardano-js-sdk/commit/1d7ac7393fbd669f08b516c4067883d982f2e711))
* makeTxIn.address required, add NewTxIn that has no address ([83cd354](https://github.com/input-output-hk/cardano-js-sdk/commit/83cd3546840f936af5e0cde0e43d54f924602400))
* move asset info type from Cardano to Asset ([212b670](https://github.com/input-output-hk/cardano-js-sdk/commit/212b67041598cbcc2c2cf4f5678928943de7aa29))
* move jsonToMetadatum from blockfrost package to core.ProviderUtil ([adeb02c](https://github.com/input-output-hk/cardano-js-sdk/commit/adeb02cdbb1401ff4e9c43d28263357d6f27b0d6))
* move stakePoolStats from wallet provider to stake pool provider ([52d71a7](https://github.com/input-output-hk/cardano-js-sdk/commit/52d71a70700b05902cca6205fe01a63f811ba5af))
* remove TimeSettingsProvider and NetworkInfo.currentEpoch ([4a8f72f](https://github.com/input-output-hk/cardano-js-sdk/commit/4a8f72f57f699f7c0bf4a9a4b742fc0a3e4aa8ce))
* remove transactions and blocks methods from blockfrost wallet provider ([e4de136](https://github.com/input-output-hk/cardano-js-sdk/commit/e4de13650f0d387b8e7126077e8721f353af8c85))
* rename `StakePoolSearchProvider` to `StakePoolProvider` ([b432103](https://github.com/input-output-hk/cardano-js-sdk/commit/b43210348da7914664733f85f8be8999271a8667))
* rename AssetInfo metadata->tokenMetadata ([f064f37](https://github.com/input-output-hk/cardano-js-sdk/commit/f064f372b3d7273c24d78695ceac7254fa55e51f))
* rename AssetMetadata->TokenMetadata, update fields ([a83b897](https://github.com/input-output-hk/cardano-js-sdk/commit/a83b89748ec7efe7dcdbb849ab4b369dd49e5fcc))
* rename some WalletProvider functions ([72ad875](https://github.com/input-output-hk/cardano-js-sdk/commit/72ad875ca8e9c3b65c23794a95ca4110cf34a034))
* split up WalletProvider.utxoDelegationAndRewards ([18f5a57](https://github.com/input-output-hk/cardano-js-sdk/commit/18f5a571cb9d581007182b39d2c68b38491c70e6))

### 0.1.5 (2021-10-27)


### Features

* add WalletProvider.transactionDetails, add address to TxIn ([889a39b](https://github.com/input-output-hk/cardano-js-sdk/commit/889a39b1feb988144dd2249c6c47f91e8096fd48))
* **cardano-graphql:** generate graphql client from shema+operations ([9632eb4](https://github.com/input-output-hk/cardano-js-sdk/commit/9632eb40263cabc0eea8ff813180be90af63eacb))
* **cardano-graphql:** generate graphql schema from ts code ([a3e90ad](https://github.com/input-output-hk/cardano-js-sdk/commit/a3e90ad8e5c790ea250bc779b7e10f4657cdccbd))
* **cardano-graphql:** implement CardanoGraphQLStakePoolSearchProvider (wip) ([80deda6](https://github.com/input-output-hk/cardano-js-sdk/commit/80deda6963a0c07b2f0b24a0a5465c488305d83c))
* **cardano-graphql:** initial implementation of StakePoolSearchClient ([8f4f72a](https://github.com/input-output-hk/cardano-js-sdk/commit/8f4f72af7f6ca61b025f2d98e2edf24108b6e38c))
* **core:** add cslToOgmios.txIn ([5bb937e](https://github.com/input-output-hk/cardano-js-sdk/commit/5bb937e277e3fd23991db2cff1c1ec574904e048))
* **core:** add cslUtil.bytewiseEquals ([1851eb4](https://github.com/input-output-hk/cardano-js-sdk/commit/1851eb4749f8cc43c11acec30377ea5c2f42671a))
* **core:** add NotImplementedError ([5344969](https://github.com/input-output-hk/cardano-js-sdk/commit/534496926a6034f4cea401efa0bb23622b1cb3e6))
* **core:** isAddress util ([3f53e79](https://github.com/input-output-hk/cardano-js-sdk/commit/3f53e79f08fd0fd10764c3c648e356d368398df5))

### 0.1.3 (2021-10-05)

### 0.1.2 (2021-09-30)

### 0.1.1 (2021-09-30)


### Features

* add CardanoProvider.networkInfo ([1596ac2](https://github.com/input-output-hk/cardano-js-sdk/commit/1596ac27b3fa3494f784db37831f85e06a8e0e03))
* add CardanoProvider.stakePoolStats ([c25e570](https://github.com/input-output-hk/cardano-js-sdk/commit/c25e5704be13a9c259fa399e35a3771caad58d38))
* add core package with Genesis type defs ([d480373](https://github.com/input-output-hk/cardano-js-sdk/commit/d4803733d7e7bd10658e7c95615f6c0a240850ed))
* add maxTxSize to `ProtocolParametersRequiredByWallet` ([a9a5d16](https://github.com/input-output-hk/cardano-js-sdk/commit/a9a5d16db18fbf2a4cbbad1ad1cdf3f42ef891f9))
* add Provider.ledgerTip ([0e7d224](https://github.com/input-output-hk/cardano-js-sdk/commit/0e7d224a8b3315991785a1a6393d60f35b757e6a))
* **blockfrost:** create new provider called blockfrost ([b8bd72f](https://github.com/input-output-hk/cardano-js-sdk/commit/b8bd72ffc91769e525400a898cf8e7a749b7d610))
* **cardano-graphql-provider:** create cardano-graphql-provider package ([096225f](https://github.com/input-output-hk/cardano-js-sdk/commit/096225f571aa1b5def660a2bdccfd5bad3d1ef12))
* **cardano-serialization-lib:** add Ogmios to CardanoWasm translator ([0bb2077](https://github.com/input-output-hk/cardano-js-sdk/commit/0bb2077f8b2c3a90520dd989b667aef88ddcd30f))
* **cip-30:** create cip-30 package ([266e719](https://github.com/input-output-hk/cardano-js-sdk/commit/266e719d8c0b8550e05ff4d8da199a4575c0664e))
* **core|blockfrost:** modify utxo method on provider to return delegations & rewards ([e0a1bf0](https://github.com/input-output-hk/cardano-js-sdk/commit/e0a1bf020c54d66d2c7920e21dc1369cfc912cbf))
* **core:** add `currentWalletProtocolParameters` method to `CardanoProvider` ([af741c0](https://github.com/input-output-hk/cardano-js-sdk/commit/af741c073c48f7f5ad2f065fd50a48af741c133c))
* **core:** add utils originally used in cip2 package ([2314c4f](https://github.com/input-output-hk/cardano-js-sdk/commit/2314c4f4c19bb7ffeadf98ec2a74399cf7722335))
* create in-memory-key-manager package ([a819e5e](https://github.com/input-output-hk/cardano-js-sdk/commit/a819e5e2161a0cd6bd45c61825957efa810530d3))
* **wallet:** createTransactionInternals ([1aa7032](https://github.com/input-output-hk/cardano-js-sdk/commit/1aa7032421940ef85aa9eb3d0251a79caaaa19d8))


### Bug Fixes

* add missing yarn script, and rename ([840135f](https://github.com/input-output-hk/cardano-js-sdk/commit/840135f7d100c9a00ff410147758ee7d02112897))
* **core:** handle values without assets ([e2862b7](https://github.com/input-output-hk/cardano-js-sdk/commit/e2862b7e54ae1ce8eb6b2b2d2e8eb694136ab5ce))
