# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.10.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.9.0...@cardano-sdk/cardano-services@0.10.0) (2023-03-13)

### ⚠ BREAKING CHANGES

- **cardano-services:** rename http-server to provider-server
- core type for address string reprensetation 'Address' renamed to PaymentAddress

### Features

- add inputSource in transactions ([7ed99d5](https://github.com/input-output-hk/cardano-js-sdk/commit/7ed99d5a12cf8667114c76ecde0cbdc3cfbc3887))
- adds caching stake pools metric from blockfrost ([d2de0a4](https://github.com/input-output-hk/cardano-js-sdk/commit/d2de0a4efa8f443fb4b63da9a6322eeaa099d09e))
- **cardano-services:** HTTP server /ready endpoint ([e613306](https://github.com/input-output-hk/cardano-js-sdk/commit/e613306d1eba64eaab638d68319db1154e414756))
- **cardano-services:** support disabling stake pool APY metric, for performance benefits ([18e1dfb](https://github.com/input-output-hk/cardano-js-sdk/commit/18e1dfba661705f0e36f5255f7a3a182952c40ed))
- rewards history limit default ([8c32be8](https://github.com/input-output-hk/cardano-js-sdk/commit/8c32be88a9edd3ed82a34c75d33a7a428ecc3b7c))
- **util-dev:** add DockerUtil (hoisted from cardano-services tests) ([ccb86ab](https://github.com/input-output-hk/cardano-js-sdk/commit/ccb86ab3ad8f0ae3c73a3c36173b1f76c0704f6d))

### Bug Fixes

- **cardano-services:** fixes how collaterals are handled in stake pools related queries ([d4a4158](https://github.com/input-output-hk/cardano-js-sdk/commit/d4a4158e94cedd090a5df569a0aa3c2ec2425c2f))
- **cardano-services:** fixes the total ada computation formula ([c63df83](https://github.com/input-output-hk/cardano-js-sdk/commit/c63df8377b867a5e477f81e54a21c5f4a74c3c93))
- **cardano-services:** fixes the type of blocks created and delegats in stake pools search api ([b76ed1e](https://github.com/input-output-hk/cardano-js-sdk/commit/b76ed1e6fb678843d8bfc08b22c46b439f311ec2))

### Code Refactoring

- **cardano-services:** rename http-server to provider-server ([7b58748](https://github.com/input-output-hk/cardano-js-sdk/commit/7b587480edda5a9f36796ac577fd56baa6d4ee11))
- core type for address string reprensetation 'Address' renamed to PaymentAddress ([4287463](https://github.com/input-output-hk/cardano-js-sdk/commit/42874633de6069510efdc57323f61140d22ed203))

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.8.0...@cardano-sdk/cardano-services@0.9.0) (2023-03-01)

### ⚠ BREAKING CHANGES

- **cardano-services:** simplify program args interface
- **cardano-services:** move API URL, build info, enable metrics into common

### Features

- **cardano-services:** add schema for StakePoolMetrics to OpenAPI spec ([959a2f0](https://github.com/input-output-hk/cardano-js-sdk/commit/959a2f02a069fe6f7de7dade658fd054cf37f41a))
- **cardano-services:** remove CLI terminal clear ([97c5a0c](https://github.com/input-output-hk/cardano-js-sdk/commit/97c5a0ca555c993b6349250851239484c1cf834f))

### Code Refactoring

- **cardano-services:** move API URL, build info, enable metrics into common ([c67e550](https://github.com/input-output-hk/cardano-js-sdk/commit/c67e550981df62532f2b8c2f2f28b4a9e88e9de5))
- **cardano-services:** simplify program args interface ([eb6ceb3](https://github.com/input-output-hk/cardano-js-sdk/commit/eb6ceb394a2e9525b65933bda1a5800eaa1cc652))

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.7.0...@cardano-sdk/cardano-services@0.8.0) (2023-02-17)

### ⚠ BREAKING CHANGES

- **cardano-services:** makes genesis data a dependency for providers which need it
- reworks stake pool epoch rewards fields to be ledger compliant
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
- CompactGenesis.slotLength type changed
  from `number` to `Seconds`
- **cardano-services:** Nested `narHash`, `path` and `sourceInfo` under top level `extra` property of BUILD_INFO
- - all provider constructors are updated to use standardized form of deps

### Features

- **cardano-services:** adds dev version of mainnet preprod and preview docker compose ([107ea57](https://github.com/input-output-hk/cardano-js-sdk/commit/107ea574a4932d0e7d402bbbc15be5a0999cd779))
- **cardano-services:** changes the way tx metadatum are read from db, from json to raw bytes ([ca9a110](https://github.com/input-output-hk/cardano-js-sdk/commit/ca9a1107ed89d1f18d68c79bf598b2dd3db8989e))
- **cardano-services:** include healthCheck response as detail in Provider.Unhealthy errors ([16d008d](https://github.com/input-output-hk/cardano-js-sdk/commit/16d008dfa31661c76543f8704292a283c41dd38b))
- **cardano-services:** upgrade /meta endpoint ([e9c3a5b](https://github.com/input-output-hk/cardano-js-sdk/commit/e9c3a5b74a2cc1f69c53f562af8a5b4e693bd20a))
- update CompactGenesis slotLength type to be Seconds ([82e63d6](https://github.com/input-output-hk/cardano-js-sdk/commit/82e63d6cacedbab5ecf8491dfd37749bfeddbc22))

### Bug Fixes

- **cardano-service:** fixes a division by zero in stake pools query ([caa4aac](https://github.com/input-output-hk/cardano-js-sdk/commit/caa4aac213be9c40d572d280ccaac62f67ab80a9))
- **cardano-services:** cache TTL validator ([012b6c5](https://github.com/input-output-hk/cardano-js-sdk/commit/012b6c55456b5c7501940186c3783bd8643b4cd5))
- **cardano-services:** fixes a bug excluding some pools from queries filtering by pledge meet ([9f71a99](https://github.com/input-output-hk/cardano-js-sdk/commit/9f71a9989b47e317e2019a38b6ef27e51dd47935))
- **cardano-services:** fixes a bug on stake pool saturation compute also causing a wrong sort ([4e66060](https://github.com/input-output-hk/cardano-js-sdk/commit/4e660601d6b6b0d22dc6ce635e130f4b19cd73df))
- **cardano-services:** fixes epoch rewards of stake pool query to have the right number of elements ([c7bf65e](https://github.com/input-output-hk/cardano-js-sdk/commit/c7bf65e869bf38c1ff258e626c483cc690f67049))
- **cardano-services:** fixes tx_id format in logged messages ([a4116d7](https://github.com/input-output-hk/cardano-js-sdk/commit/a4116d73b4c594d71a69e5a615293bbe2c2c4b86))
- **cardano-services:** makes rewards epoch length the one from genesis for all epochs but current ([90880cf](https://github.com/input-output-hk/cardano-js-sdk/commit/90880cf1be445808b2ca39b3bcd4757bef0f9981))
- **cardano-services:** stake pool query by metrics results no longer exceedes total count ([adceaa2](https://github.com/input-output-hk/cardano-js-sdk/commit/adceaa25bc459fb68ff48cc326ccee2e3d3b33fc))
- **cardano-services:** stake pool search cached results now correctly handle rewards history limit ([62eefd9](https://github.com/input-output-hk/cardano-js-sdk/commit/62eefd9788e3770e80ed779ea280d4448b9efc18))
- fixes a minor bug in stake pool query sort by name ([5eb3aa5](https://github.com/input-output-hk/cardano-js-sdk/commit/5eb3aa52faed5add00fa63f74094033a8fb28fa0))
- fixes the computation of apy ([6ea2474](https://github.com/input-output-hk/cardano-js-sdk/commit/6ea2474026cdf85436811fab07a847ae9bf0a27b))
- unmemoize slot epoch calc in core package ([2dc6af4](https://github.com/input-output-hk/cardano-js-sdk/commit/2dc6af44906f1b61323a69c3e840834f2c86930f))

### Performance Improvements

- **cardano-services:** remove type validations ([551ddad](https://github.com/input-output-hk/cardano-js-sdk/commit/551ddad4fa6e2161e6ed5f9aece3191d5777522e))

### Code Refactoring

- **cardano-services:** makes genesis data a dependency for providers which need it ([d4c7e24](https://github.com/input-output-hk/cardano-js-sdk/commit/d4c7e249ebbce4ec5d52304565b032905e0286cc))
- hoist Opaque types, hexBlob, Base64Blob and related utils ([391a8f2](https://github.com/input-output-hk/cardano-js-sdk/commit/391a8f20d60607c4fb6ce8586b97ae96841f759b))
- refactor the SDK to use the new crypto package ([3b41320](https://github.com/input-output-hk/cardano-js-sdk/commit/3b41320e7971a231d50785733ff4cd0793418d3d))
- reworks stake pool epoch rewards fields to be ledger compliant ([a9ff583](https://github.com/input-output-hk/cardano-js-sdk/commit/a9ff583d26fe427c2816ab286bb3ae4aeacc9301))
- standardize provider dependencies ([05b37e6](https://github.com/input-output-hk/cardano-js-sdk/commit/05b37e6383a906152df457143c5a27341a11c341))

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.6.0...@cardano-sdk/cardano-services@0.7.0) (2022-12-22)

### ⚠ BREAKING CHANGES

- Alonzo transaction outputs will now contain a datumHash field, carrying the datum hash digest. However, they will also contain a datum field with the exact same value for backward compatibility reason. In Babbage however, transaction outputs will carry either datum or datumHash depending on the case; and datum will only contain inline datums.
- - replace KeyAgent.networkId with KeyAgent.chainId

* remove CardanoNetworkId type
* rename CardanoNetworkMagic->NetworkMagics
* add 'logger' to KeyAgentDependencies
* setupWallet now requires a Logger

- use titlecase for mainnet/testnet in NetworkId
- - rename `redeemer.scriptHash` to `redeemer.data` in core

* change the type from `Hash28ByteBase16` to `HexBlob`

- - BlockSize is now an OpaqueNumber rather than a type alias for number

* BlockNo is now an OpaqueNumber rather than a type alias for number
* EpochNo is now an OpaqueNumber rather than a type alias for number
* Slot is now an OpaqueNumber rather than a type alias for number
* Percentage is now an OpaqueNumber rather than a type alias for number

- rename era-specific types in core
- Even if the value of DB_CACHE_TTL was already interpreted in seconds
  rather than in minutes (despite the error in the description), it's default value is
  changed
- rename block types

* CompactBlock -> BlockInfo
* Block -> ExtendedBlockInfo

- hoist ogmiosToCore to ogmios package
- classify TxSubmission errors as variant of CardanoNode error

### Features

- add opaque numeric types to core package ([9ead8bd](https://github.com/input-output-hk/cardano-js-sdk/commit/9ead8bdb34b7ffc57c32f9ab18a6c6ca14af3fda))
- added new babbage era types in Transactions and Outputs ([0b1f2ff](https://github.com/input-output-hk/cardano-js-sdk/commit/0b1f2ffaad2edec281d206a6865cd1e6053d9826))
- adds projected tip to the db sync based providers's health check response ([eb76414](https://github.com/input-output-hk/cardano-js-sdk/commit/eb76414d5796d6009611ba848e8d5c5fdffa46e4))
- **cardano-services:** synchronizes epoch rollover detected by ledger tip ([0de53ae](https://github.com/input-output-hk/cardano-js-sdk/commit/0de53aeaa320a2d7eff9c2c0a7d9786e39e41e14))
- dbSyncUtxoProvider now returns the new Babbage fields in the UTXO when present ([82b271b](https://github.com/input-output-hk/cardano-js-sdk/commit/82b271b602b6075a561ed12529ca29ab558e303b))
- implement ogmiosToCore certificates mapping ([aef2e8d](https://github.com/input-output-hk/cardano-js-sdk/commit/aef2e8d64da9352c6aab206034950d64f44e9559))
- rename era-specific types in core ([c4955b1](https://github.com/input-output-hk/cardano-js-sdk/commit/c4955b1f3ae0992bb55b1c1461a1e449be0b6ef2))
- replace KeyAgent.networkId with KeyAgent.chainId ([e44dee0](https://github.com/input-output-hk/cardano-js-sdk/commit/e44dee054611636f34b0a66e27d7971af01e0296))

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
- **cardano-services:** asset with no name ([34f895f](https://github.com/input-output-hk/cardano-js-sdk/commit/34f895fa5e48e637eebafa7d4815044a63a8e020))
- **cardano-services:** fix possible APY calculation overflow on networks with fast epochs ([a226852](https://github.com/input-output-hk/cardano-js-sdk/commit/a226852eba79a29458feb30c1ff1ff0f43dc3cfc))
- **cardano-services:** tx submit provider init ([d75b61d](https://github.com/input-output-hk/cardano-js-sdk/commit/d75b61d7c9204c299cb4757048946486b80e3b95))
- ttl validation now uses seconds and no longer minutes as the cache itself ([f0eb80f](https://github.com/input-output-hk/cardano-js-sdk/commit/f0eb80f73e61ea48f10809fb3c329fb5c4022e6b))

### Code Refactoring

- change redeemer script hash to data ([a24bbb8](https://github.com/input-output-hk/cardano-js-sdk/commit/a24bbb80d57007352d64b5b99dbc7a19d4948208))
- classify TxSubmission errors as variant of CardanoNode error ([234305e](https://github.com/input-output-hk/cardano-js-sdk/commit/234305e28aefd3d9bd1736315bdf89ca31f7556f))
- use titlecase for mainnet/testnet in NetworkId ([252c589](https://github.com/input-output-hk/cardano-js-sdk/commit/252c589480d3e422b9021ea66a67af978fb80264))

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.5.0...@cardano-sdk/cardano-services@0.6.0) (2022-11-04)

### ⚠ BREAKING CHANGES

- **cardano-services:** support pools ext metadata
- support the complete set of protocol parameters
- make stake pools pagination a required arg
- add pagination in 'transactionsByAddresses'
- **cardano-services:** nftMetadataService returns null instead of
- **input-selection:** renamed cip2 package to input-selection
- hoist Cardano.util.{deserializeTx,metadatum}
- rework TxSubmitProvider to submit transactions as hex string instead of Buffer
- rework all provider signatures args from positional to a single object
- convert boolean args to support ENV counterparts, parse as booleans
- hoist hexString utils to util package

### Features

- add pagination in 'transactionsByAddresses' ([fc88afa](https://github.com/input-output-hk/cardano-js-sdk/commit/fc88afa9f006e9fc7b50b5a98665058a0d563e31))
- **cardano-services:** Add '/meta' endpoint for deployment information ([872bf9c](https://github.com/input-output-hk/cardano-js-sdk/commit/872bf9ca629e0d5a6289bd18b0deadad7c0d8cc9))
- **cardano-services:** add support for using a stub token metadata service ([6975156](https://github.com/input-output-hk/cardano-js-sdk/commit/6975156724ee0c3d35bccf28e5820bc4a81a5b87))
- **cardano-services:** adds log of incoming requests ([f302f9c](https://github.com/input-output-hk/cardano-js-sdk/commit/f302f9c656b9026b3b19a63a4ce818acea841a77))
- **cardano-services:** enhance metrics endpoint ([0fdbb85](https://github.com/input-output-hk/cardano-js-sdk/commit/0fdbb85777d1d8c79189843ad8c7936a42e22380))
- **cardano-services:** make search stake pool case insensitive ([7fb42a7](https://github.com/input-output-hk/cardano-js-sdk/commit/7fb42a7941ae7cf721e18719b81858b454cfb6b8))
- **cardano-services:** nftMetadataService returns null instead of ([7b87d1d](https://github.com/input-output-hk/cardano-js-sdk/commit/7b87d1ded0df482d29dd2b581a3baa9035f32d06))
- **cardano-services:** rewardAccounts limitation ([8ca6917](https://github.com/input-output-hk/cardano-js-sdk/commit/8ca6917f3de646bb9cf6f17c7ac5b4bd1940412d))
- **cardano-services:** support pools ext metadata ([0ac5451](https://github.com/input-output-hk/cardano-js-sdk/commit/0ac545179dac74101f978d62c968cc05898da08b))
- create common mock server util ([53bd4f7](https://github.com/input-output-hk/cardano-js-sdk/commit/53bd4f7de87406a8d3623c903847268e57d0ddeb))
- improve db health check query ([1595350](https://github.com/input-output-hk/cardano-js-sdk/commit/159535092033a745664c399ee1273da436fd3374))
- make stake pools pagination a required arg ([6cf8206](https://github.com/input-output-hk/cardano-js-sdk/commit/6cf8206be2162db7196794f7252e5cbb84b65c77))
- support the complete set of protocol parameters ([46d7aa9](https://github.com/input-output-hk/cardano-js-sdk/commit/46d7aa97230a666ca119c7de5ed0cf70b742d2a2))

### Bug Fixes

- **cardano-services:** cache total pools count ([fbd9ac5](https://github.com/input-output-hk/cardano-js-sdk/commit/fbd9ac5ad77f471259089391b8f27077bc924c0a))
- **cardano-services:** correct interval type and only clear if defined ([a23f384](https://github.com/input-output-hk/cardano-js-sdk/commit/a23f3846d85740675b57c14988ac08e35ee133b9))
- **cardano-services:** correct spelling mistakes ([a7b098f](https://github.com/input-output-hk/cardano-js-sdk/commit/a7b098ffa1fa2d47ba01e5dc15bc2c702013c835))
- **cardano-services:** filter available rewards balance by spendable_epoch>=tip ([4da325a](https://github.com/input-output-hk/cardano-js-sdk/commit/4da325ad39a2d7520f8f8c902e41eed916ac7a38))
- **cardano-services:** fix netinf prov possibly causing unhandled rejection on early called shutdown ([1107d4b](https://github.com/input-output-hk/cardano-js-sdk/commit/1107d4b52fc170a86520a4e8b823cfe7ddfc7b5a))
- **cardano-services:** fix some typos ([303497d](https://github.com/input-output-hk/cardano-js-sdk/commit/303497d4bbc70a2a6ea7566002ad260814284196))
- **cardano-services:** fixed an issue that was causing live stake and saturation values to be calculated incorrectly ([5e714e2](https://github.com/input-output-hk/cardano-js-sdk/commit/5e714e2c5af5a2761389cff8ca24b068252216b8))
- **cardano-services:** fixed an issue that was causing pool saturation to be always 0 ([82cab4d](https://github.com/input-output-hk/cardano-js-sdk/commit/82cab4dbe8ab3c8df13309770a953b30f957ebe3))
- **cardano-services:** fixed some not correctly exported symbols ([8c8950a](https://github.com/input-output-hk/cardano-js-sdk/commit/8c8950add7551b6ad4fec4fe50baec40e28b655d))
- **cardano-services:** handle CardanoTokenRegistry errors ([32a9b1f](https://github.com/input-output-hk/cardano-js-sdk/commit/32a9b1f4714cd556ef3bf2597b52a4d481efcc58))
- **cardano-services:** hash/update id model types ([142098c](https://github.com/input-output-hk/cardano-js-sdk/commit/142098ce8cbf74b50230bab85d438bf39b7b045b))
- **cardano-services:** total rewards is now being calculated correctly for current epoch ([6d4cf6c](https://github.com/input-output-hk/cardano-js-sdk/commit/6d4cf6c64ffb038b9e9ef56597ed0ce366ac1826))
- **cardano-services:** wrong source tx input id ([f6efe3b](https://github.com/input-output-hk/cardano-js-sdk/commit/f6efe3b2507761c4ef5ec7c5b9e8ec87ff2c5039))
- convert boolean args to support ENV counterparts, parse as booleans ([d14bd9d](https://github.com/input-output-hk/cardano-js-sdk/commit/d14bd9d8aeec64f04aab094e0aceb8dc5b803926))
- **core:** custom errors no longer hide inner error details ([9d0f51f](https://github.com/input-output-hk/cardano-js-sdk/commit/9d0f51fe4a3b8ae20c8e83b9209397cd99cc044b))
- remove nullability of Protocol Parameters ([f75859d](https://github.com/input-output-hk/cardano-js-sdk/commit/f75859d644c2a6c4d4844b179357ccab7db537bf))
- rollback ProtocolParametersRequiredByWallet type ([0cd8877](https://github.com/input-output-hk/cardano-js-sdk/commit/0cd887737cc5d4f8d920405c803f05f2c47e42f2))

**Note:** Version bump only for package @cardano-sdk/cardano-services

- **cardano-services:** order by block.id in ledger tip queries ([b985d3f](https://github.com/input-output-hk/cardano-js-sdk/commit/b985d3f09a870359e7a463088fd22a8054f2fff0))

## [0.6.0-nightly.17](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.6.0-nightly.16...@cardano-sdk/cardano-services@0.6.0-nightly.17) (2022-10-24)

- hoist Cardano.util.{deserializeTx,metadatum} ([a1d0754](https://github.com/input-output-hk/cardano-js-sdk/commit/a1d07549e7a5fccd36b9f75b9f713c0def8cb97f))
- hoist hexString utils to util package ([0c99d9d](https://github.com/input-output-hk/cardano-js-sdk/commit/0c99d9d37f23bb504d1ac2a530fbe78aa045db66))
- **input-selection:** renamed cip2 package to input-selection ([f4d6632](https://github.com/input-output-hk/cardano-js-sdk/commit/f4d6632d61c5b63bc15a64ec3962425f9ad2d6eb))
- rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))
- rework TxSubmitProvider to submit transactions as hex string instead of Buffer ([032a1b7](https://github.com/input-output-hk/cardano-js-sdk/commit/032a1b7a11941d52b5baf0d447b615c58a294068))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.4.0...@cardano-sdk/cardano-services@0.5.0) (2022-08-30)

### ⚠ BREAKING CHANGES

- consolidate cli & run entrypoints
- rm TxAlonzo.implicitCoin
- removed Ogmios schema package dependency
- replace `NetworkInfoProvider.timeSettings` with `eraSummaries`
- logger is now required
- contextLogger support
- **cardano-services:** make interface properties name more specific

### Features

- **cardano-services:** add db-sync asset http service ([fb254e5](https://github.com/input-output-hk/cardano-js-sdk/commit/fb254e5e8d6058f891cefb479456558fb3835dd0))
- **cardano-services:** add db-sync asset provider ([9763c59](https://github.com/input-output-hk/cardano-js-sdk/commit/9763c598ef5f1b3c95672424fb57647784024298))
- **cardano-services:** add support for secure db connection ([380a633](https://github.com/input-output-hk/cardano-js-sdk/commit/380a6338db024a8dd7ca960fb93ec4da7d3769b5))
- **cardano-services:** cache stake pool queries ([3b65972](https://github.com/input-output-hk/cardano-js-sdk/commit/3b65972b74d410312005c9c60d1b48c269b81aaa))
- **cardano-services:** root health check endpoint ([aff7c6a](https://github.com/input-output-hk/cardano-js-sdk/commit/aff7c6a2b277d24c067e9cec1a14ffd35e8afb17))
- **cardano-services:** uniform ttl parameter of in memory cache methods to be expressed in seconds ([670d0c1](https://github.com/input-output-hk/cardano-js-sdk/commit/670d0c12589a4385b72c445e5f332e195f3b8000))
- implement tx submit worker error handling ([55bc023](https://github.com/input-output-hk/cardano-js-sdk/commit/55bc023a255a27ecdcf19ee6a2e92cc37b0f3801))
- ogmios cardano node DNS resolution ([d132c9f](https://github.com/input-output-hk/cardano-js-sdk/commit/d132c9f52485086a5cf797217d48c816ae51d2b3))
- replace `NetworkInfoProvider.timeSettings` with `eraSummaries` ([58f6fc7](https://github.com/input-output-hk/cardano-js-sdk/commit/58f6fc7c5ace703583c36f95d3d6962483ad924d))

### Bug Fixes

- **cardano-services:** empty array and default condition for identifier filters - search stakePool ([43b8481](https://github.com/input-output-hk/cardano-js-sdk/commit/43b848141d66680001f7cf8efc56d14784077de7))
- **cardano-services:** fixed a division by 0 on APY calculation if epoch lenght is less than 1 day ([bb041cf](https://github.com/input-output-hk/cardano-js-sdk/commit/bb041cf9f36b3eefc38859a1260c9baf585593aa))
- **cardano-services:** initialize CardanoNode ([3c3a5ee](https://github.com/input-output-hk/cardano-js-sdk/commit/3c3a5ee9e6d7068981ed35fcf892992f215473b9))
- **cardano-services:** make HTTP services depend on provider interfaces, rather than classes ([1fef381](https://github.com/input-output-hk/cardano-js-sdk/commit/1fef3819d159e92af6d691d89b0e90a73d9f66ca))
- malformed string and add missing service to Docker defaults ([b40edf6](https://github.com/input-output-hk/cardano-js-sdk/commit/b40edf6f2aec7d654206725e38c88ab1f60d8222))

### Performance Improvements

- improve lovelace supply queries ([7964a2f](https://github.com/input-output-hk/cardano-js-sdk/commit/7964a2f4119c5ee9e8c81589781a8494967b81ee))

### Code Refactoring

- **cardano-services:** make interface properties name more specific ([854408d](https://github.com/input-output-hk/cardano-js-sdk/commit/854408dbf6cf5e7c80280ab104826d8309c801fa))
- consolidate cli & run entrypoints ([1452bfb](https://github.com/input-output-hk/cardano-js-sdk/commit/1452bfb4935129a37dbd83680d623dca081f3948))
- contextLogger support ([6d5da8e](https://github.com/input-output-hk/cardano-js-sdk/commit/6d5da8ec8bba2033ce378d2f0d9321fd758e7c90))
- logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))
- removed Ogmios schema package dependency ([4ed2408](https://github.com/input-output-hk/cardano-js-sdk/commit/4ed24087aa5646c6f68ba31c42fc3f8a317df3b9))
- rm TxAlonzo.implicitCoin ([167d205](https://github.com/input-output-hk/cardano-js-sdk/commit/167d205dd15c857b229f968ab53a6e52e5504d3f))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/cardano-services@0.4.0) (2022-07-25)

### ⚠ BREAKING CHANGES

- **cardano-services:** make interface properties name more specific
- **cardano-services:** remove static create
- **cardano-services:** service improvements

### Features

- add new `apy` sort field to stake pools ([161ccd8](https://github.com/input-output-hk/cardano-js-sdk/commit/161ccd83c318bb874e59c39cbb9fc1f9b94e3e32))
- **cardano-services:** add db-sync asset http service ([fb254e5](https://github.com/input-output-hk/cardano-js-sdk/commit/fb254e5e8d6058f891cefb479456558fb3835dd0))
- **cardano-services:** add db-sync asset provider ([9763c59](https://github.com/input-output-hk/cardano-js-sdk/commit/9763c598ef5f1b3c95672424fb57647784024298))
- **cardano-services:** add DbSyncNftMetadataService ([f667c0a](https://github.com/input-output-hk/cardano-js-sdk/commit/f667c0a41365eb658b6ec7e8fe9f74bb80aa5243))
- **cardano-services:** add token metadata provider ([040e0eb](https://github.com/input-output-hk/cardano-js-sdk/commit/040e0eb4e7e116724a759eb13d38b803863338c7))
- **cardano-services:** implements rabbitmq new interface ([a880367](https://github.com/input-output-hk/cardano-js-sdk/commit/a880367bb8044a45645dbd30772040ad9422dc59))
- **cardano-services:** service discovery via DNS ([4d4dd36](https://github.com/input-output-hk/cardano-js-sdk/commit/4d4dd36cd4cdf302efc4797821917bdb22974519))
- **cardano-services:** support loading secrets in run.ts for compatibility with existing pattern ([b9ece18](https://github.com/input-output-hk/cardano-js-sdk/commit/b9ece181b36022d2c7d732ef8342be47d9f9aad8))
- sort stake pools by fixed cost ([6e1d6e4](https://github.com/input-output-hk/cardano-js-sdk/commit/6e1d6e4179794aa92b7d3279e3534beb2ac29978))
- support any network by fetching time settings from the node ([08d9ed2](https://github.com/input-output-hk/cardano-js-sdk/commit/08d9ed2b6aa20cf4df2a063f046f4e5ca28c6bd5))

### Bug Fixes

- allow pool relay nullable fields in open api validation ([e7fe121](https://github.com/input-output-hk/cardano-js-sdk/commit/e7fe1215ee02e8672c269796e49f639268b02483))
- **cardano-services:** add missing ENV to run.ts ([13f8698](https://github.com/input-output-hk/cardano-js-sdk/commit/13f869899ba50390e8abe29424d742590be17ae1))
- **cardano-services:** make HTTP services depend on provider interfaces, rather than classes ([1fef381](https://github.com/input-output-hk/cardano-js-sdk/commit/1fef3819d159e92af6d691d89b0e90a73d9f66ca))
- **cardano-services:** stake pool healthcheck ([90e84ee](https://github.com/input-output-hk/cardano-js-sdk/commit/90e84eee1d3d50e043098f73b01d2d084f46f40f))

### Performance Improvements

- improve lovelace supply queries ([7964a2f](https://github.com/input-output-hk/cardano-js-sdk/commit/7964a2f4119c5ee9e8c81589781a8494967b81ee))

### Code Refactoring

- **cardano-services:** make interface properties name more specific ([854408d](https://github.com/input-output-hk/cardano-js-sdk/commit/854408dbf6cf5e7c80280ab104826d8309c801fa))
- **cardano-services:** remove static create ([7eddc2b](https://github.com/input-output-hk/cardano-js-sdk/commit/7eddc2b5aa44ba96b9fe50d599bc10fa80c0bff8))
- **cardano-services:** service improvements ([6eda4aa](https://github.com/input-output-hk/cardano-js-sdk/commit/6eda4aa5776db6658c3526e0a17a2554bf01c6b0))

## [0.6.0-nightly.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.6.0-nightly.9...@cardano-sdk/cardano-services@0.6.0-nightly.10) (2022-09-23)

### ⚠ BREAKING CHANGES

- hoist Cardano.util.{deserializeTx,metadatum}

### Bug Fixes

- **cardano-services:** fixed an issue that was causing pool saturation to be always 0 ([82cab4d](https://github.com/input-output-hk/cardano-js-sdk/commit/82cab4dbe8ab3c8df13309770a953b30f957ebe3))

### Code Refactoring

- hoist Cardano.util.{deserializeTx,metadatum} ([a1d0754](https://github.com/input-output-hk/cardano-js-sdk/commit/a1d07549e7a5fccd36b9f75b9f713c0def8cb97f))

## [0.6.0-nightly.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.6.0-nightly.8...@cardano-sdk/cardano-services@0.6.0-nightly.9) (2022-09-21)

**Note:** Version bump only for package @cardano-sdk/cardano-services

## [0.6.0-nightly.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.6.0-nightly.7...@cardano-sdk/cardano-services@0.6.0-nightly.8) (2022-09-20)

### Features

- **cardano-services:** make search stake pool case insensitive ([7fb42a7](https://github.com/input-output-hk/cardano-js-sdk/commit/7fb42a7941ae7cf721e18719b81858b454cfb6b8))

### Bug Fixes

- rollback ProtocolParametersRequiredByWallet type ([0cd8877](https://github.com/input-output-hk/cardano-js-sdk/commit/0cd887737cc5d4f8d920405c803f05f2c47e42f2))

## [0.6.0-nightly.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.6.0-nightly.6...@cardano-sdk/cardano-services@0.6.0-nightly.7) (2022-09-16)

### Bug Fixes

- **cardano-services:** cache total pools count ([fbd9ac5](https://github.com/input-output-hk/cardano-js-sdk/commit/fbd9ac5ad77f471259089391b8f27077bc924c0a))
- **cardano-services:** hash/update id model types ([142098c](https://github.com/input-output-hk/cardano-js-sdk/commit/142098ce8cbf74b50230bab85d438bf39b7b045b))

## [0.6.0-nightly.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/cardano-services@0.6.0-nightly.5...@cardano-sdk/cardano-services@0.6.0-nightly.6) (2022-09-15)

**Note:** Version bump only for package @cardano-sdk/cardano-services

### ⚠ BREAKING CHANGES

- move stakePoolStats from wallet provider to stake pool provider
- rename `StakePoolSearchProvider` to `StakePoolProvider`
- **cardano-services:** compress the multiple entrypoints into a single top-level set
- **cardano-services:** make TxSubmitHttpServer compatible with createHttpProvider<T>
- **cardano-graphql-services:** remove graphql concerns from services package, rename

### Features

- add ChainHistory http provider ([64aa7ae](https://github.com/input-output-hk/cardano-js-sdk/commit/64aa7aeff061aa2cf9bc6196347f6cf5b9c7f6be))
- add sort stake pools by saturation ([#270](https://github.com/input-output-hk/cardano-js-sdk/issues/270)) ([2a9abff](https://github.com/input-output-hk/cardano-js-sdk/commit/2a9abffae06fc462e1811430c0dc8dfa4520091c))
- add totalResultCount to StakePoolSearch response ([4265f6a](https://github.com/input-output-hk/cardano-js-sdk/commit/4265f6af60a92c93604b93167fd297530b6e01f8))
- add utxo http provider ([a55fcdb](https://github.com/input-output-hk/cardano-js-sdk/commit/a55fcdb08276c37a1852f0c39e5b0a78501ddf0b))
- **cardano-services:** add HttpServer.sendJSON ([c60bcf9](https://github.com/input-output-hk/cardano-js-sdk/commit/c60bcf9d7cf0cd1d0ad993939996d02f7be2af2f))
- **cardano-services:** add pool rewards to stake pool search ([f2ed680](https://github.com/input-output-hk/cardano-js-sdk/commit/f2ed680b3dd37c3aa7ced4c99b3e36cf1bd89f83))
- **cardano-services:** add query for stake pool epoch rewards ([7417896](https://github.com/input-output-hk/cardano-js-sdk/commit/74178962608abaf8b96a3b6f7fe09eea701cbfbf))
- **cardano-services:** add sort by order & field ([dd80375](https://github.com/input-output-hk/cardano-js-sdk/commit/dd8037523275ecd9ea13b695a5fff6515918d8a2))
- **cardano-services:** add stake pools metrics and open api validation ([2c010ee](https://github.com/input-output-hk/cardano-js-sdk/commit/2c010ee32f05f7f22968a70d19e965e21d49bdcb))
- **cardano-services:** added call chain of close method from HttpServer to HttpService to Provider ([aa44bdf](https://github.com/input-output-hk/cardano-js-sdk/commit/aa44bdf2304ae55ac0084efa85d72fea7b1f7445))
- **cardano-services:** adds tx submission via rabbitmq load test ([5f6a160](https://github.com/input-output-hk/cardano-js-sdk/commit/5f6a160b2b6724ab7d387229f6c4d3e73e43bdc8))
- **cardano-services:** create NetworkInfo service ([b003d49](https://github.com/input-output-hk/cardano-js-sdk/commit/b003d499b6fad289b8d9656c6293a4f23856b5ed))
- **cardano-services:** integrated in CLIs TxSubmitWorker from @cardano-sdk/rabbitmq ([56adf12](https://github.com/input-output-hk/cardano-js-sdk/commit/56adf12cd4dcd1e5144a67f2d4c2fca4ec9e1c93))
- **cardano-services:** log services HTTP server is using ([7da7802](https://github.com/input-output-hk/cardano-js-sdk/commit/7da7802aef5a93128dbe8eefc5e744631c0a8b8a))
- **cardano-services:** run multiple services from a single HTTP server ([35770e0](https://github.com/input-output-hk/cardano-js-sdk/commit/35770e0ee2767e4a9352c4ebbc09563c80be1f65))
- **cardano-services:** stake pool search http server ([c3dd013](https://github.com/input-output-hk/cardano-js-sdk/commit/c3dd0133843327906535ce2ac623482cf95dd397))
- create InMemoryCache ([a2bfcc6](https://github.com/input-output-hk/cardano-js-sdk/commit/a2bfcc62c25e71d78d07b961267d7ce9679b6cf4))
- rewards data ([5ce2ff0](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce2ff00856d362cf0e423ddadadb15cef764932))

### Bug Fixes

- **cardano-services:** added @cardano-sdk/rabbitmq dependency ([f561a1e](https://github.com/input-output-hk/cardano-js-sdk/commit/f561a1e49be3ecba7a0c16dac516c4ad0db7b30c))
- **cardano-services:** align exit codes on error ([ce8464f](https://github.com/input-output-hk/cardano-js-sdk/commit/ce8464fe4f2f3bb3853667bb95e366d2a7fa700b))
- **cardano-services:** change stake pool search response body data to match provider method ([d83d4af](https://github.com/input-output-hk/cardano-js-sdk/commit/d83d4afd1476edf1b36d50f607e0fb2b75854661))
- **cardano-services:** fix findPoolEpoch rewards, add rounding ([e386211](https://github.com/input-output-hk/cardano-js-sdk/commit/e386211f3b4f5307f2001bce792c24e1deba3182))
- **cardano-services:** fix findPoolsOwners query ([619b2b8](https://github.com/input-output-hk/cardano-js-sdk/commit/619b2b8dacdc1f7efa4bdae69c46f253f14df7c8))
- **cardano-services:** fix pools_delegated on pledgeMet query ([a68771a](https://github.com/input-output-hk/cardano-js-sdk/commit/a68771a36884dc03b3badd61162f5f86e0765ef4))
- **cardano-services:** fixed bin entry in package.json ([de9b89e](https://github.com/input-output-hk/cardano-js-sdk/commit/de9b89e0d6a0d624d9dbc91f4aea2a623597de74))
- **cardano-services:** health check api can now be called in get as well ([b68e90c](https://github.com/input-output-hk/cardano-js-sdk/commit/b68e90c9d194e707d6bd7397cb391735b248849a))
- **cardano-services:** resolve package.json path when cli is run with ts-node ([9c77218](https://github.com/input-output-hk/cardano-js-sdk/commit/9c77218c459834911286dfe95a44a140312fd76f))
- **cardano-services:** updates NetworkInfo OpenAPI spec to align with refactor ([626e8be](https://github.com/input-output-hk/cardano-js-sdk/commit/626e8be65e367d139b7444621355ac1918305673))
- division by zero error at pool rewards query ([#280](https://github.com/input-output-hk/cardano-js-sdk/issues/280)) ([116ed12](https://github.com/input-output-hk/cardano-js-sdk/commit/116ed128d488f211639f5648030e30cfa4855fcb))
- use ordering within UTxO query for reproducible results ([889b437](https://github.com/input-output-hk/cardano-js-sdk/commit/889b43773bdab51eb204ad3a7406b4ddb48000a4))

### Performance Improvements

- **cardano-services:** enhance cache get method ([99b2b9d](https://github.com/input-output-hk/cardano-js-sdk/commit/99b2b9db0e0f0a5e1171690ab519f1424e46c283))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/cardano-services@0.4.0) (2022-07-25)

### ⚠ BREAKING CHANGES

- **cardano-graphql-services:** remove graphql concerns from services package, rename ([71a939b](https://github.com/input-output-hk/cardano-js-sdk/commit/71a939b874296d86183d89fce7877c565630e921))

### Code Refactoring

- **cardano-services:** compress the multiple entrypoints into a single top-level set ([4c3c975](https://github.com/input-output-hk/cardano-js-sdk/commit/4c3c9750006eb987edd7eb5b1a0f9038fcb154d9))
- **cardano-services:** make TxSubmitHttpServer compatible with createHttpProvider<T> ([131f234](https://github.com/input-output-hk/cardano-js-sdk/commit/131f2349b2e54be4765a1db1505d2e7ac4504089))
- move stakePoolStats from wallet provider to stake pool provider ([52d71a7](https://github.com/input-output-hk/cardano-js-sdk/commit/52d71a70700b05902cca6205fe01a63f811ba5af))
- rename `StakePoolSearchProvider` to `StakePoolProvider` ([b432103](https://github.com/input-output-hk/cardano-js-sdk/commit/b43210348da7914664733f85f8be8999271a8667))
