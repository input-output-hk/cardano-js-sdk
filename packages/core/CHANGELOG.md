# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.12.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/core@0.12.0...@cardano-sdk/core@0.12.1) (2023-05-24)

**Note:** Version bump only for package @cardano-sdk/core

## [0.12.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/core@0.11.0...@cardano-sdk/core@0.12.0) (2023-05-22)

### ⚠ BREAKING CHANGES

* hoist createTransactionInternals to tx-construction
- hoist outputValidator to tx-construction
- hoist txBuilder types to tx-construction
- rename ObservableWalletTxOutputBuilder to TxOutputBuilder
- move Delegatee, StakeKeyStatus and RewardAccount types from wallet to tx-construction
- removed PrepareTx, createTxPreparer and PrepareTxDependencies
- OutputValidatorContext was renamed to WalletOutputValidatorContext

### Features

* added two new utility functions to extract policy id and asset name from asset id ([b4af015](https://github.com/input-output-hk/cardano-js-sdk/commit/b4af015d26b7c08c8b295ffcba6142caca49f6a8))
* **core:** added the function PoolId.toKeyHash to extract the hash from a bech32 encoded pool id ([004e5a6](https://github.com/input-output-hk/cardano-js-sdk/commit/004e5a646de9ba91caec49d59f3a73c13ae4b35b))
* **util-dev:** add stubProviders ([6d5d99c](https://github.com/input-output-hk/cardano-js-sdk/commit/6d5d99c80894a4b126647272f490d9e2c472d818))

### Code Refactoring

* move tx build utils from wallet to tx-construction ([48072ce](https://github.com/input-output-hk/cardano-js-sdk/commit/48072ce35968820b10fcf0b9ed4441f00ac6fb8b))

## [0.11.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/core@0.10.0...@cardano-sdk/core@0.11.0) (2023-05-02)

### ⚠ BREAKING CHANGES

- - auxiliaryDataHash is now included in the TxBody core type.

* networkId is now included in the TxBody core type.
* auxiliaryData no longer contains the optional hash field.
* auxiliaryData no longer contains the optional body field.

- **core:** - NFT metadata image is type 'Uri'

* NFT metadata description is type 'string'
* NFT metadata file src is type 'Uri'
* NFT metadata file name is optional

- rename AssetInfo 'quantity' to 'supply'
- - `TokenMetadata` has new mandatory property `assetId`

* `DbSyncAssetProvider` constructor requires new
  `DbSyncAssetProviderProp` object as first positional argument
* `createAssetsService` accepts an array of assetIds instead of a
  single assetId

- - stack property of returned errors was removed
- **core:** - parseAssetId was moved from util.assetId.ts to coreToCml.ts

* createAssetId was moved from util.assetId.ts to cmlToCore.ts

### Features

- add CORS headers config in provider server ([25010cf](https://github.com/input-output-hk/cardano-js-sdk/commit/25010cf752bf31c46268e8ea31f78b00583f9032))
- add healthCheck$ to ObservableCardanoNode ([df35035](https://github.com/input-output-hk/cardano-js-sdk/commit/df3503597832939e6dc9c7ec953d24b3d709c723))
- added new Transaction class that can convert between CBOR and the Core Tx type ([cc9a80c](https://github.com/input-output-hk/cardano-js-sdk/commit/cc9a80c17f1c0f46124b0c04c597a7ff96e517d3))
- **cardano-services:** metadata fetching logic ([3647598](https://github.com/input-output-hk/cardano-js-sdk/commit/36475984368426f50323322da622f0af4c5d046b))
- **core:** add createEpochSlotsCalc that computes 1st and last slot # of the epoch ([266b951](https://github.com/input-output-hk/cardano-js-sdk/commit/266b951f23a898ad226f82c491138660094149b6))
- **core:** add optional 'reason' property to HealthCheckResponse ([985448c](https://github.com/input-output-hk/cardano-js-sdk/commit/985448c30d85b767588c7524ddeb147c27320608))
- **core:** replaced borc library with a native typescript implementation of the CBOR format ([39b6ceb](https://github.com/input-output-hk/cardano-js-sdk/commit/39b6ceb718fed0ea1827933e983e10080083ca9f))
- support assets fetching by ids ([8ed208a](https://github.com/input-output-hk/cardano-js-sdk/commit/8ed208a7a060c6999294c1f53266d6452adb278d))
- transaction body core type now includes the auxiliaryDataHash and networkId fields ([8b92b01](https://github.com/input-output-hk/cardano-js-sdk/commit/8b92b0190083a2b956ae1e188121414428f6663b))

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))
- **core:** correct cmlToCore.utxo return type (tuple) ([495a22e](https://github.com/input-output-hk/cardano-js-sdk/commit/495a22e471eb3d8412a056e1901089e9bfdd7977))
- **core:** invalid NFT model and CIP-25 validation ([0d9b77a](https://github.com/input-output-hk/cardano-js-sdk/commit/0d9b77ae1851e5ea1386c94e9e32e3fbdfeed201))
- **core:** nft metadata files src in base64 ([b7811c7](https://github.com/input-output-hk/cardano-js-sdk/commit/b7811c736c0c3e74809b5d24a81bd620e26b6a47))
- **core:** nft metadata images in base64 encoding format ([27876ed](https://github.com/input-output-hk/cardano-js-sdk/commit/27876ed0fcfb9eb00e9b6238081359558de967fa))
- tx metadata memory leak ([a5dc8ec](https://github.com/input-output-hk/cardano-js-sdk/commit/a5dc8ec4b18dc7170a58a217dd69a65b6189e1f1))

### Code Refactoring

- **core:** move parseAssetId and createAssetId from util.assetId to coreToCml and cmlToCore ([d649e02](https://github.com/input-output-hk/cardano-js-sdk/commit/d649e023ab98598ff093afcb3b36d052969335bb))
- rename AssetInfo 'quantity' to 'supply' ([6e28df4](https://github.com/input-output-hk/cardano-js-sdk/commit/6e28df412797974b8ce6f6deb0c3346ff5938a05))
- the TxSubmit endpoint no longer adds the stack trace when returning domain errors ([f018f30](https://github.com/input-output-hk/cardano-js-sdk/commit/f018f30caea1c9cf764a419431ac642b98733bb9))

## [0.10.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/core@0.9.0...@cardano-sdk/core@0.10.0) (2023-03-13)

### ⚠ BREAKING CHANGES

- upgrade resolveInputAddress to resolveInput
- added optional isValid field to Transaction object
- add new Address types that implement CIP-19 natively
- core type for address string reprensetation 'Address' renamed to PaymentAddress

### Features

- add inputSource in transactions ([7ed99d5](https://github.com/input-output-hk/cardano-js-sdk/commit/7ed99d5a12cf8667114c76ecde0cbdc3cfbc3887))
- add new Address types that implement CIP-19 natively ([a892176](https://github.com/input-output-hk/cardano-js-sdk/commit/a8921760b714b090bb6c15d6b4696e2dd0b2fdc5))
- added optional isValid field to Transaction object ([f722ae8](https://github.com/input-output-hk/cardano-js-sdk/commit/f722ae8075744a6ca61df1c2c077131cbd0ecf3b))
- rewards history limit default ([8c32be8](https://github.com/input-output-hk/cardano-js-sdk/commit/8c32be88a9edd3ed82a34c75d33a7a428ecc3b7c))
- send phase2 validation failed transactions as failed$ ([ef25825](https://github.com/input-output-hk/cardano-js-sdk/commit/ef2582532677aeee4b19e84adf1957f09631dd72))
- upgrade resolveInputAddress to resolveInput ([fcfa035](https://github.com/input-output-hk/cardano-js-sdk/commit/fcfa035a3498f675945dafcc82b8f05c08318dd8))

### Code Refactoring

- core type for address string reprensetation 'Address' renamed to PaymentAddress ([4287463](https://github.com/input-output-hk/cardano-js-sdk/commit/42874633de6069510efdc57323f61140d22ed203))

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/core@0.8.0...@cardano-sdk/core@0.9.0) (2023-03-01)

### ⚠ BREAKING CHANGES

- add ChainSyncRollBackward.point

### Features

- **core:** add ObservableCardanoNode interface ([56ec469](https://github.com/input-output-hk/cardano-js-sdk/commit/56ec4695235715f114314c8963dfd0bc888d766a))

### Bug Fixes

- **core:** update @emurgo/cip14-js import style ([33013c5](https://github.com/input-output-hk/cardano-js-sdk/commit/33013c56eaf24edd9d85781fb3f41a95837059da))

### Code Refactoring

- add ChainSyncRollBackward.point ([4f61a6d](https://github.com/input-output-hk/cardano-js-sdk/commit/4f61a6d960adb85f762c09fb61d1a461e907cd72))

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/core@0.7.0...@cardano-sdk/core@0.8.0) (2023-02-17)

### ⚠ BREAKING CHANGES

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
- EraSummary.parameters.slotLength type changed from number
  to Milliseconds
- Types coming from time.ts should be imported directly
  from core package instead of using the `Cardano.util` namespace.
- **core:** add ChainSyncEvent.requestNext
- - all provider constructors are updated to use standardized form of deps

### Features

- **core:** add ChainSyncEvent.requestNext ([484fced](https://github.com/input-output-hk/cardano-js-sdk/commit/484fced69079f004141ae9eb9c5129328d4cbc01))
- **core:** add OpaqueString types for TxCBOR and TxBodyCBOR with some utility functions ([f408baa](https://github.com/input-output-hk/cardano-js-sdk/commit/f408baa25b330134f1502e460eb41ec2d46dcb58))
- **core:** add support for '{policyId}.{assetName}' format when parsing AssetId ([eb49a0a](https://github.com/input-output-hk/cardano-js-sdk/commit/eb49a0a310a1d6c1c58a56b4f79b7139c2ee44ee))
- **core:** adds support for cip-0025 version 2 ([be21a75](https://github.com/input-output-hk/cardano-js-sdk/commit/be21a75898e15bea252489f50e82286434f73929))
- update CompactGenesis slotLength type to be Seconds ([82e63d6](https://github.com/input-output-hk/cardano-js-sdk/commit/82e63d6cacedbab5ecf8491dfd37749bfeddbc22))
- update EraSummary slotLength type to be Milliseconds ([fb1f1a2](https://github.com/input-output-hk/cardano-js-sdk/commit/fb1f1a2c4fb77d03e45f9255c182e9bc54583324))

### Bug Fixes

- **core:** omit NFT meta files with invalid format ([ef783fb](https://github.com/input-output-hk/cardano-js-sdk/commit/ef783fba6e95a7085f21565ec445ba4dbf7a5ecc))
- fixes the computation of apy ([6ea2474](https://github.com/input-output-hk/cardano-js-sdk/commit/6ea2474026cdf85436811fab07a847ae9bf0a27b))
- unmemoize slot epoch calc in core package ([2dc6af4](https://github.com/input-output-hk/cardano-js-sdk/commit/2dc6af44906f1b61323a69c3e840834f2c86930f))

### Code Refactoring

- hoist Opaque types, hexBlob, Base64Blob and related utils ([391a8f2](https://github.com/input-output-hk/cardano-js-sdk/commit/391a8f20d60607c4fb6ce8586b97ae96841f759b))
- hoist time.ts out of Cardano namespace ([666701c](https://github.com/input-output-hk/cardano-js-sdk/commit/666701c40cb49a9b3865e1d8bd0d36e7cc8c325c))
- refactor the SDK to use the new crypto package ([3b41320](https://github.com/input-output-hk/cardano-js-sdk/commit/3b41320e7971a231d50785733ff4cd0793418d3d))
- reworks stake pool epoch rewards fields to be ledger compliant ([a9ff583](https://github.com/input-output-hk/cardano-js-sdk/commit/a9ff583d26fe427c2816ab286bb3ae4aeacc9301))
- standardize provider dependencies ([05b37e6](https://github.com/input-output-hk/cardano-js-sdk/commit/05b37e6383a906152df457143c5a27341a11c341))

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/core@0.6.0...@cardano-sdk/core@0.7.0) (2022-12-22)

### ⚠ BREAKING CHANGES

- Alonzo transaction outputs will now contain a datumHash field, carrying the datum hash digest. However, they will also contain a datum field with the exact same value for backward compatibility reason. In Babbage however, transaction outputs will carry either datum or datumHash depending on the case; and datum will only contain inline datums.
- - replace KeyAgent.networkId with KeyAgent.chainId

* remove CardanoNetworkId type
* rename CardanoNetworkMagic->NetworkMagics
* add 'logger' to KeyAgentDependencies
* setupWallet now requires a Logger

- use titlecase for mainnet/testnet in NetworkId
- moved testnetEraSummaries to util-dev package
- - rename `redeemer.scriptHash` to `redeemer.data` in core

* change the type from `Hash28ByteBase16` to `HexBlob`

- - make `TxBodyAlonzo.validityInterval` an optional field aligned with Ogmios schema
- **core:** - rename `Cardano.NativeScriptKind.RequireMOf` to `Cardano.NativeScriptKind.RequireNOf`
- - BlockSize is now an OpaqueNumber rather than a type alias for number

* BlockNo is now an OpaqueNumber rather than a type alias for number
* EpochNo is now an OpaqueNumber rather than a type alias for number
* Slot is now an OpaqueNumber rather than a type alias for number
* Percentage is now an OpaqueNumber rather than a type alias for number

- rename era-specific types in core
- rename block types

* CompactBlock -> BlockInfo
* Block -> ExtendedBlockInfo

- hoist ogmiosToCore to ogmios package
- classify TxSubmission errors as variant of CardanoNode error

### Features

- add opaque numeric types to core package ([9ead8bd](https://github.com/input-output-hk/cardano-js-sdk/commit/9ead8bdb34b7ffc57c32f9ab18a6c6ca14af3fda))
- added new babbage era types in Transactions and Outputs ([0b1f2ff](https://github.com/input-output-hk/cardano-js-sdk/commit/0b1f2ffaad2edec281d206a6865cd1e6053d9826))
- **core:** add missing tx props conversions ([6e9a962](https://github.com/input-output-hk/cardano-js-sdk/commit/6e9a962ff8911ada35a86b927af6650b300174c2))
- **core:** add preview and preprod network magics ([676c576](https://github.com/input-output-hk/cardano-js-sdk/commit/676c5769fa744d5fa1fb7a6a4af152cc73347710))
- **core:** added utility function to create pool ids from verification key hashes ([318c784](https://github.com/input-output-hk/cardano-js-sdk/commit/318c7847a3b432382f62c11640922b8af606432f))
- **core:** adds optional projected tip to the health cheak response interface ([ea59ed7](https://github.com/input-output-hk/cardano-js-sdk/commit/ea59ed748761e5d4edaf1a255ae43df2fdd27092))
- **core:** memoizes computation slot nr to epoch nr ([40fe907](https://github.com/input-output-hk/cardano-js-sdk/commit/40fe90748d03e72724a549dc01cec0821945a819))
- dbSyncUtxoProvider now returns the new Babbage fields in the UTXO when present ([82b271b](https://github.com/input-output-hk/cardano-js-sdk/commit/82b271b602b6075a561ed12529ca29ab558e303b))
- implement ogmiosToCore certificates mapping ([aef2e8d](https://github.com/input-output-hk/cardano-js-sdk/commit/aef2e8d64da9352c6aab206034950d64f44e9559))
- initial projection implementation ([8a93d8d](https://github.com/input-output-hk/cardano-js-sdk/commit/8a93d8d427eb947b6f34566f8a694fcedfe0e59f))
- **ogmios:** complete Ogmios tx to core mapping ([bcac56b](https://github.com/input-output-hk/cardano-js-sdk/commit/bcac56bbf943110703696e0854b2af2f5e2b1737))
- rename era-specific types in core ([c4955b1](https://github.com/input-output-hk/cardano-js-sdk/commit/c4955b1f3ae0992bb55b1c1461a1e449be0b6ef2))
- replace KeyAgent.networkId with KeyAgent.chainId ([e44dee0](https://github.com/input-output-hk/cardano-js-sdk/commit/e44dee054611636f34b0a66e27d7971af01e0296))

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
- cip30 wallet has to accept hex encoded address ([d5a748a](https://github.com/input-output-hk/cardano-js-sdk/commit/d5a748a74289c7ec703066a8eca11637e3a84734))
- **core:** correct hash types in genesis key delegation certificate ([10d1f2b](https://github.com/input-output-hk/cardano-js-sdk/commit/10d1f2b5eda4831e87042cbb4c945d8a62aaa6a4))
- **core:** correctly serialize/deserialize transactions with no validity interval ([5e6e3eb](https://github.com/input-output-hk/cardano-js-sdk/commit/5e6e3eb37743a54c174d82f973b26c2ed1d1e057))
- **core:** fixed a small memory leak when pasring byron era addresses ([16727e4](https://github.com/input-output-hk/cardano-js-sdk/commit/16727e435d318059e2d2749420aa5e40d1d4198d))
- **core:** native script type name ([bc62f8b](https://github.com/input-output-hk/cardano-js-sdk/commit/bc62f8bf8af18c9f34acf2072806a303927265c0))
- fixed an issue that was preveting TxOuts with byron addresses to be deserialized correctly ([65356d5](https://github.com/input-output-hk/cardano-js-sdk/commit/65356d5d07375f5b90c25aca4f1965e35edee747))
- **input-selection:** fixed recursive use of CSL object ([ac39e77](https://github.com/input-output-hk/cardano-js-sdk/commit/ac39e775bb08b36c28593b960a0deda78f680c4d))

### Code Refactoring

- change redeemer script hash to data ([a24bbb8](https://github.com/input-output-hk/cardano-js-sdk/commit/a24bbb80d57007352d64b5b99dbc7a19d4948208))
- classify TxSubmission errors as variant of CardanoNode error ([234305e](https://github.com/input-output-hk/cardano-js-sdk/commit/234305e28aefd3d9bd1736315bdf89ca31f7556f))
- make tx validityInterval an optional ([fa1c487](https://github.com/input-output-hk/cardano-js-sdk/commit/fa1c4877bb64f0e2584950a27861cf16e727cadd))
- moved testnetEraSummaries to util-dev package ([5ad0514](https://github.com/input-output-hk/cardano-js-sdk/commit/5ad0514846dd2d186eb04c29821d987c6409a5c2))
- use titlecase for mainnet/testnet in NetworkId ([252c589](https://github.com/input-output-hk/cardano-js-sdk/commit/252c589480d3e422b9021ea66a67af978fb80264))

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/core@0.5.0...@cardano-sdk/core@0.6.0) (2022-11-04)

### ⚠ BREAKING CHANGES

- support the complete set of protocol parameters
- free CSL resources using freeable util
- make stake pools pagination a required arg
- add pagination in 'transactionsByAddresses'
- **core:** metadatumToCip25 returns `null` instead of `undefined`
  when metadata does not exist or couldn't be extracted
- hoist Cardano.util.{deserializeTx,metadatum}
- hoist core Address namespace to Cardano.util
- hoist some core.Cardano.util._ to core._
- **wallet:** compute stability window slots count
- rename `TxInternals` to `TxBodyWithHash`
- hoist InputResolver types to core package, in preparation for lifting key management
- hoist TxInternals to core package, in preparation for lifting key management
- rework TxSubmitProvider to submit transactions as hex string instead of Buffer
- rework all provider signatures args from positional to a single object

### Features

- add pagination in 'transactionsByAddresses' ([fc88afa](https://github.com/input-output-hk/cardano-js-sdk/commit/fc88afa9f006e9fc7b50b5a98665058a0d563e31))
- added signing options with extra signers to the transaction finalize method ([514b718](https://github.com/input-output-hk/cardano-js-sdk/commit/514b718825af93965739ec5f890f6be2aacf4f48))
- **core:** added a new inspector for extracting minting and burning information from transactions ([a9289f3](https://github.com/input-output-hk/cardano-js-sdk/commit/a9289f3798e7e8cfc8a46b096414f7e219dd619b))
- **core:** added a new inspector for extracting pool registration/retirements information from transactions ([e186ba3](https://github.com/input-output-hk/cardano-js-sdk/commit/e186ba360b2d6e55b708f6033a8cd5269d127b66))
- **core:** added a new inspector for extracting transaction metadata ([d7e1402](https://github.com/input-output-hk/cardano-js-sdk/commit/d7e1402b57cc11b6544c2ecabaf5dcbb46e51525))
- **core:** added several utility functions to derive some of the information requiered for the use of native scripts native scripts: ([3b757ba](https://github.com/input-output-hk/cardano-js-sdk/commit/3b757ba77e163b44136227ae2a8fa59600b4474f))
- **core:** define extended metadata types ([dad253d](https://github.com/input-output-hk/cardano-js-sdk/commit/dad253dbc5e83699061f0dbff22839a515de2aa5))
- **core:** improved custom errors to correctly handle errors from fs package or of type string ([5ea3eac](https://github.com/input-output-hk/cardano-js-sdk/commit/5ea3eac801762a881892ad2267d5a72884c3c1e7))
- **core:** ogmios to core translation of block type ([b077cb7](https://github.com/input-output-hk/cardano-js-sdk/commit/b077cb71ea77bebf50629066e86825db8e519af0))
- **core:** return null for no metadata from metadatumToCip25 ([b9343e4](https://github.com/input-output-hk/cardano-js-sdk/commit/b9343e49d2f0fa582be9f150aa42e04a3d3c0bfa))
- improve db health check query ([1595350](https://github.com/input-output-hk/cardano-js-sdk/commit/159535092033a745664c399ee1273da436fd3374))
- make stake pools pagination a required arg ([6cf8206](https://github.com/input-output-hk/cardano-js-sdk/commit/6cf8206be2162db7196794f7252e5cbb84b65c77))
- support the complete set of protocol parameters ([46d7aa9](https://github.com/input-output-hk/cardano-js-sdk/commit/46d7aa97230a666ca119c7de5ed0cf70b742d2a2))
- **wallet:** compute stability window slots count ([34b77d3](https://github.com/input-output-hk/cardano-js-sdk/commit/34b77d3379d41ac701214970e70656296136526e))

### Bug Fixes

- added missing contraints ([7b351ca](https://github.com/input-output-hk/cardano-js-sdk/commit/7b351cada06b9c5ae2f379d02614e05259f7147a))
- **core:** cleaned up several CSL objects that were leaking ([a99610b](https://github.com/input-output-hk/cardano-js-sdk/commit/a99610bbccaecf3834fe0132309e0379bbf78cd7))
- **core:** coreToCsl converts datum in txOut function ([cc62055](https://github.com/input-output-hk/cardano-js-sdk/commit/cc62055bd667e9da9b5b7abf8da322d5313a1b73))
- **core:** custom errors no longer hide inner error details ([9d0f51f](https://github.com/input-output-hk/cardano-js-sdk/commit/9d0f51fe4a3b8ae20c8e83b9209397cd99cc044b))
- **core:** handle skipped testnet eras when configured for auto-upgrade ([47fe7c1](https://github.com/input-output-hk/cardano-js-sdk/commit/47fe7c1d33576359175db1000a67ae08736254a7))
- **core:** narrow down BootstrapWitness types & fix CSL conversion ([0e8694b](https://github.com/input-output-hk/cardano-js-sdk/commit/0e8694b6e2b99d09ce8696ca2b88234e78381458))
- **core:** subtractTokenMaps shouldn't change first element ([3851166](https://github.com/input-output-hk/cardano-js-sdk/commit/38511660fa1fa9f28f7d5eddcce57310dc4b913e))
- **core:** update hardcoded testnetEraSummaries with correct start of shelley era ([8489da9](https://github.com/input-output-hk/cardano-js-sdk/commit/8489da9da98e90e9e3a2198ee19b662ed3475772))
- free CSL resources using freeable util ([5ce0056](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce0056fb108f7bccfbd9f8ef562b82277f3c613))
- remove nullability of Protocol Parameters ([f75859d](https://github.com/input-output-hk/cardano-js-sdk/commit/f75859d644c2a6c4d4844b179357ccab7db537bf))
- rollback ProtocolParametersRequiredByWallet type ([0cd8877](https://github.com/input-output-hk/cardano-js-sdk/commit/0cd887737cc5d4f8d920405c803f05f2c47e42f2))

### Code Refactoring

- hoist Cardano.util.{deserializeTx,metadatum} ([a1d0754](https://github.com/input-output-hk/cardano-js-sdk/commit/a1d07549e7a5fccd36b9f75b9f713c0def8cb97f))
- hoist core Address namespace to Cardano.util ([c0af6c3](https://github.com/input-output-hk/cardano-js-sdk/commit/c0af6c333420b4305f021a50bbdf25317b85554f))
- hoist InputResolver types to core package, in preparation for lifting key management ([aaf430e](https://github.com/input-output-hk/cardano-js-sdk/commit/aaf430efefcc5c87f1acfaf227f4aec11fc8db8a))
- hoist some core.Cardano.util._ to core._ ([5c18c7b](https://github.com/input-output-hk/cardano-js-sdk/commit/5c18c7be146578991753c081ab4da0adae9b3f88))
- hoist TxInternals to core package, in preparation for lifting key management ([f5510f3](https://github.com/input-output-hk/cardano-js-sdk/commit/f5510f340d592998b3194dd303bd14b184a0a3e3))
- rename `TxInternals` to `TxBodyWithHash` ([77567aa](https://github.com/input-output-hk/cardano-js-sdk/commit/77567aab56395ded6d9b0ba7488aacc2d3f856a0))
- rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))
- rework TxSubmitProvider to submit transactions as hex string instead of Buffer ([032a1b7](https://github.com/input-output-hk/cardano-js-sdk/commit/032a1b7a11941d52b5baf0d447b615c58a294068))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/core@0.4.0...@cardano-sdk/core@0.5.0) (2022-08-30)

### ⚠ BREAKING CHANGES

- rm TxAlonzo.implicitCoin
- removed Ogmios schema package dependency
- **core:** added native script type and serialization functions.
- replace `NetworkInfoProvider.timeSettings` with `eraSummaries`
- logger is now required
- update min utxo computation to be Babbage-compatible

### Features

- **core:** added native script type and serialization functions. ([51b46c8](https://github.com/input-output-hk/cardano-js-sdk/commit/51b46c83909ce0f978ea81d1542315eab707d511))
- **core:** export cslUtil MIN_I64 and MAX_I64 consts ([618eef0](https://github.com/input-output-hk/cardano-js-sdk/commit/618eef04e7c9d2e27d2b0c5a9f1a172d340abde4))
- extend HealthCheckResponse ([2e6d0a3](https://github.com/input-output-hk/cardano-js-sdk/commit/2e6d0a3d2067ce8538886f1a9d0d55fab7647ae9))
- replace `NetworkInfoProvider.timeSettings` with `eraSummaries` ([58f6fc7](https://github.com/input-output-hk/cardano-js-sdk/commit/58f6fc7c5ace703583c36f95d3d6962483ad924d))

### Bug Fixes

- update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))

### Code Refactoring

- logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))
- removed Ogmios schema package dependency ([4ed2408](https://github.com/input-output-hk/cardano-js-sdk/commit/4ed24087aa5646c6f68ba31c42fc3f8a317df3b9))
- rm TxAlonzo.implicitCoin ([167d205](https://github.com/input-output-hk/cardano-js-sdk/commit/167d205dd15c857b229f968ab53a6e52e5504d3f))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/core@0.4.0) (2022-07-25)

### ⚠ BREAKING CHANGES

- update min utxo computation to be Babbage-compatible

### Features

- add new `apy` sort field to stake pools ([161ccd8](https://github.com/input-output-hk/cardano-js-sdk/commit/161ccd83c318bb874e59c39cbb9fc1f9b94e3e32))
- **core:** accept common ipfs hash without protocol for nft metadata uri ([f1878e3](https://github.com/input-output-hk/cardano-js-sdk/commit/f1878e39b63800d451db1f97624f041f4f424567))
- **core:** added Ed25519PrivateKey to keys ([db1f42c](https://github.com/input-output-hk/cardano-js-sdk/commit/db1f42c9d21115e43a1581de077b5f4f9c84ca43))
- **core:** adds util to get a tx from its body ([f680720](https://github.com/input-output-hk/cardano-js-sdk/commit/f680720f8bd6610871aad587e4a198de9190e229))
- sort stake pools by fixed cost ([6e1d6e4](https://github.com/input-output-hk/cardano-js-sdk/commit/6e1d6e4179794aa92b7d3279e3534beb2ac29978))
- support any network by fetching time settings from the node ([08d9ed2](https://github.com/input-output-hk/cardano-js-sdk/commit/08d9ed2b6aa20cf4df2a063f046f4e5ca28c6bd5))

### Bug Fixes

- update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))

## 0.3.0 (2022-06-24)

### ⚠ BREAKING CHANGES

- remove transactions and blocks methods from blockfrost wallet provider
- move stakePoolStats from wallet provider to stake pool provider
- rename `StakePoolSearchProvider` to `StakePoolProvider`
- add serializable object key transformation support
- move jsonToMetadatum from blockfrost package to core.ProviderUtil
- delete nftMetadataProvider and remove it from AssetTracker
- **core:** changes value sent and received inspectors
- remove TimeSettingsProvider and NetworkInfo.currentEpoch
- split up WalletProvider.utxoDelegationAndRewards
- rename some WalletProvider functions
- makeTxIn.address required, add NewTxIn that has no address
- **core:** rm epoch? from core certificate types
- **core:** set tx body scriptIntegrityHash to correct length (32 byte)
- validate the correct Ed25519KeyHash length (28 bytes)
- **core:** remove PoolRegistrationCertificate.poolId
- **core:** make StakeDelegationCertificate.epoch optional
- change TimeSettings interface from fn to obj
- **core:** nest errors under TxSubmissionErrors object
- **core:** change WalletProvider.rewardsHistory return type to Map
- Given transaction submission is really an independent behaviour,
  as evidenced by microservices such as the HTTP submission API,
  it's more flexible modelled as an independent provider.
- change MetadatumMap type to allow any metadatum as key
- rename AssetInfo metadata->tokenMetadata
- **core:** support T | T[] where appropriate in metadatumToCip25
- move asset info type from Cardano to Asset
- rename AssetMetadata->TokenMetadata, update fields
- update ogmios to 5.1.0
- **core:** add support to genesis delegate as slot leader
- **core:** add support for base58-encoded addresses
- **core:** move StakePool.metadata under PoolParameters
- **core:** align Tip and PartialBlockHeader types
- **core:** change type of Asset.name to AssetName
- **core:** remove AssetMintOrBurn.action in favor of using negative qty for burn

### Features

- add ChainHistory http provider ([64aa7ae](https://github.com/input-output-hk/cardano-js-sdk/commit/64aa7aeff061aa2cf9bc6196347f6cf5b9c7f6be))
- add optional 'sinceBlock' argument to queryTransactionsByAddresses ([94fdd65](https://github.com/input-output-hk/cardano-js-sdk/commit/94fdd65e0f5b7901081d847eb619a88a1211402c))
- add Provider interface, use as base for TxSubmitProvider ([e155ed4](https://github.com/input-output-hk/cardano-js-sdk/commit/e155ed4efcd1338a54099d1a9034ccbeddeef1cc))
- add sort stake pools by saturation ([#270](https://github.com/input-output-hk/cardano-js-sdk/issues/270)) ([2a9abff](https://github.com/input-output-hk/cardano-js-sdk/commit/2a9abffae06fc462e1811430c0dc8dfa4520091c))
- add StakePool.status and a few other minor improvements to StakePool types ([1405d05](https://github.com/input-output-hk/cardano-js-sdk/commit/1405d05ca29bac3863178512a73d3a67ee4b7af5))
- add totalResultCount to StakePoolSearch response ([4265f6a](https://github.com/input-output-hk/cardano-js-sdk/commit/4265f6af60a92c93604b93167fd297530b6e01f8))
- add utxo http provider ([a55fcdb](https://github.com/input-output-hk/cardano-js-sdk/commit/a55fcdb08276c37a1852f0c39e5b0a78501ddf0b))
- add WalletProvider.genesisParameters ([1d824fc](https://github.com/input-output-hk/cardano-js-sdk/commit/1d824fc4c7ded176eb045a253b406d6aa31b016a))
- add WalletProvider.queryBlocksByHashes ([f0431b7](https://github.com/input-output-hk/cardano-js-sdk/commit/f0431b7398c9525f50c0b803748cf2fb6195a36f))
- add WalletProvider.rewardsHistory ([d84c980](https://github.com/input-output-hk/cardano-js-sdk/commit/d84c98086a8cb49de47a2ffd78448899cb47036b))
- **blockfrost:** fetch tx metadata, update blockfrost sdk to 2.0.2 ([f5c16a6](https://github.com/input-output-hk/cardano-js-sdk/commit/f5c16a629465df6b4c4db4bb4470420d860b1c7b))
- **cardano-services:** stake pool search http server ([c3dd013](https://github.com/input-output-hk/cardano-js-sdk/commit/c3dd0133843327906535ce2ac623482cf95dd397))
- **core:** add 'activating' stakepool status, change certificate enum values to match type names ([59129b5](https://github.com/input-output-hk/cardano-js-sdk/commit/59129b5101a5c8fdc7face33357939db968b2924))
- **core:** add 'bytesToHex', 'HexBlob' and 'castHexBlob' utils ([dc33f15](https://github.com/input-output-hk/cardano-js-sdk/commit/dc33f153288255b256453209433f08dae1a22291))
- **core:** add BigIntMath.max, export Cardano.RewardAccount type ([bc14ec8](https://github.com/input-output-hk/cardano-js-sdk/commit/bc14ec8d61854f218d861dc01750030d11f8b336))
- **core:** add Bip32PublicKey and Bip32PrivateKey types, export Witness.Signatures type ([999c33f](https://github.com/input-output-hk/cardano-js-sdk/commit/999c33f03e82f302c68ce8b1685bfc6e44e1621e))
- **core:** add coreToCsl.tokenMap ([e864228](https://github.com/input-output-hk/cardano-js-sdk/commit/e86422822faa2d1ddf72d5eed1956b34dcdfef7f))
- **core:** add coreToCsl.txAuxiliaryData ([8686610](https://github.com/input-output-hk/cardano-js-sdk/commit/8686610d776471c96fdc1969b946edd8d26eff23))
- **core:** add coreToCsl.txMint ([16261c6](https://github.com/input-output-hk/cardano-js-sdk/commit/16261c6958dffd59f1cc0c330ffb657ff86e9be3))
- **core:** add cslToCore.txInputs, make ProtocolParamsRequiredByWallet fields required ([d67097e](https://github.com/input-output-hk/cardano-js-sdk/commit/d67097ee1fe4c38bd5b37c40795c4737e9a19f68))
- **core:** add cslToCore.utxo ([d497928](https://github.com/input-output-hk/cardano-js-sdk/commit/d497928628a1aaa980898bccb2da98d2c6a19747))
- **core:** add Date support for serializableObject ([d6dc693](https://github.com/input-output-hk/cardano-js-sdk/commit/d6dc693781202d808becbceacd45dd5e1dba6619))
- **core:** add metadatum parsing utils ([51a57ab](https://github.com/input-output-hk/cardano-js-sdk/commit/51a57ab3aebfb67aec1ed5080912cfc0ed68fe40))
- **core:** add optional 'options' argument to StakePoolSearchProvider.queryStakePools ([6ae18a6](https://github.com/input-output-hk/cardano-js-sdk/commit/6ae18a6915d771baef6d7104dfaf0f1054f93be8))
- **core:** add ProviderFailure.Unhealthy ([98fb4a7](https://github.com/input-output-hk/cardano-js-sdk/commit/98fb4a7ac85b0b1bde8977e1c8b6035e7d484cbf))
- **core:** add ProviderUtil.withProviderErrors ([d5bad75](https://github.com/input-output-hk/cardano-js-sdk/commit/d5bad75a78ea1b5dc1741b30f37d8422298449c8))
- **core:** add serializable obj support for custom transformed field discriminator key ([63cf354](https://github.com/input-output-hk/cardano-js-sdk/commit/63cf3549ad84c59c2561e15d633f9757f4a53016))
- **core:** add SerializationFailures: InvalidType, Overflow ([cd262a7](https://github.com/input-output-hk/cardano-js-sdk/commit/cd262a7ec8b58b3e73771b3677db0788636f66dd))
- **core:** add slot time computation util ([17fc677](https://github.com/input-output-hk/cardano-js-sdk/commit/17fc677e1b75579c8ee08d5c6c4d710b41aa7907))
- **core:** add slotEpochCalc util ([d190853](https://github.com/input-output-hk/cardano-js-sdk/commit/d190853a026bc9dd7d98451e5e8afcd4077e997b))
- **core:** add SlotEpochInfoCalc ([c0d3145](https://github.com/input-output-hk/cardano-js-sdk/commit/c0d3145355561472c616fedcaea34adde6300617))
- **core:** add StakePool.epochRewards and estimateStakePoolAPY util ([ff69031](https://github.com/input-output-hk/cardano-js-sdk/commit/ff69031b19b5d902b8bb54e7440ccd334aa68b71))
- **core:** add TimeSettingsProvider type ([602fa88](https://github.com/input-output-hk/cardano-js-sdk/commit/602fa88d04567fb8b7ea00917ccaea56b438f032))
- **core:** add util to create AssetId from PolicyId and AssetName ([aef3345](https://github.com/input-output-hk/cardano-js-sdk/commit/aef334546d53be746608129a96fc5032d67cd1c0))
- **core:** add utils for custom string types, safer pool id types ([bd430f6](https://github.com/input-output-hk/cardano-js-sdk/commit/bd430f6d1db5ff3c1f3a78317b68811eb4794b6e))
- **core:** added optional close method to Provider ([69b49cc](https://github.com/input-output-hk/cardano-js-sdk/commit/69b49cc6e7730ea4e1387085dbca3c6db8aee309))
- **core:** cslToCore stake delegation certificate ([1703828](https://github.com/input-output-hk/cardano-js-sdk/commit/1703828583ea9c14fcb9aabf7d92590fc0c06b0b))
- **core:** export NativeScriptType ([92707b6](https://github.com/input-output-hk/cardano-js-sdk/commit/92707b680069b96af4c8cebd7aaf5aa32327b300))
- **core:** export TxSubmissionError type and its variants ([d562a61](https://github.com/input-output-hk/cardano-js-sdk/commit/d562a619b97ae3f8b3d5e92f2f4cb3b4bd6a73ca))
- **core:** extend StakePoolQueryOptions with sort ([9a5d3ba](https://github.com/input-output-hk/cardano-js-sdk/commit/9a5d3ba7bd299dbb5a2fed6aa45cbd6497feda2a))
- **core:** hoist computeImplicitCoin from wallet package ([d991f73](https://github.com/input-output-hk/cardano-js-sdk/commit/d991f73982af48f18386077614693a78d2c420bf))
- **core:** initial cslToCore.newTx implementation ([52835f2](https://github.com/input-output-hk/cardano-js-sdk/commit/52835f279381e79422b1a6761cabc3a6b6144961))
- **core:** introduces transaction inspection utility ([a887733](https://github.com/input-output-hk/cardano-js-sdk/commit/a887733267339cfcade9efae9aec240b2f70d388))
- **core:** isAddressWithin + isOutgoing address utils ([65003b5](https://github.com/input-output-hk/cardano-js-sdk/commit/65003b5314900e15f5842bb9518b35a69b6931b8))
- **core:** partial support for legacy base58 addresses ([0f4cb28](https://github.com/input-output-hk/cardano-js-sdk/commit/0f4cb2835efc9baf8a0e2d7921da59fe70fae1d7))
- **core:** partial support for ShelleyGenesis PoolId ([51bcfb6](https://github.com/input-output-hk/cardano-js-sdk/commit/51bcfb6ae4357477735dbaccd6c40d2c18a28d8e))
- **core:** txSubmissionError util ([1f8dc0f](https://github.com/input-output-hk/cardano-js-sdk/commit/1f8dc0f7ebd3219dbcaaef595262b96813ea67bc))
- create InMemoryCache ([a2bfcc6](https://github.com/input-output-hk/cardano-js-sdk/commit/a2bfcc62c25e71d78d07b961267d7ce9679b6cf4))
- extend NetworkInfo interface ([7b40bca](https://github.com/input-output-hk/cardano-js-sdk/commit/7b40bca2a34c80e9f746339939ed5ce9412e52e9))
- rewards data ([5ce2ff0](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce2ff00856d362cf0e423ddadadb15cef764932))
- **wallet:** add signed certificate inspector ([e58ce48](https://github.com/input-output-hk/cardano-js-sdk/commit/e58ce488ac34bde325d2cebacef13b1ac0bdd2d9))

### Bug Fixes

- **blockfrost:** interpret 404s in Blockfrost provider and optimise batching ([a795e4c](https://github.com/input-output-hk/cardano-js-sdk/commit/a795e4c70464ad0bbed714b69e826ee3f11be92c))
- change stakepool metadata extVkey field type to bech32 string ([ec523a7](https://github.com/input-output-hk/cardano-js-sdk/commit/ec523a78e62ba30c4297ccd71eb6070dbd58acc3))
- **core:** add support for base58-encoded addresses ([b3dc768](https://github.com/input-output-hk/cardano-js-sdk/commit/b3dc7680cbc44c2864d4ea6476e28ae9bbbcc9ab))
- **core:** add support to genesis delegate as slot leader ([d1c098c](https://github.com/input-output-hk/cardano-js-sdk/commit/d1c098cc4dcd34421336cc0516d0a2a59ff355e1))
- **core:** consider empty string a hex value ([3d55224](https://github.com/input-output-hk/cardano-js-sdk/commit/3d552242fb7c9fe5fdf35a9d728b53ae16070432))
- **core:** correct metadata length check ([5394bed](https://github.com/input-output-hk/cardano-js-sdk/commit/5394bedc6cf5db819e74a8de98094fc55bc836fd))
- **core:** export Address module from root ([2a1d775](https://github.com/input-output-hk/cardano-js-sdk/commit/2a1d7758d740b1cbea1339fdd25b3b4ac40ba7a3))
- **core:** finalize cslToCore tx metadata conversion ([eb5740f](https://github.com/input-output-hk/cardano-js-sdk/commit/eb5740ff00b288cfcc6769997e911dc150c16d90))
- **core:** finalize cslToCore.newTx ([2cc40aa](https://github.com/input-output-hk/cardano-js-sdk/commit/2cc40aa0cb065513ba195c0bfb256a3fc8eb7162))
- **core:** remove duplicated insert when assets from the same policy are present in the token map ([7466bac](https://github.com/input-output-hk/cardano-js-sdk/commit/7466bacd7b6feadc56fb77fb71ea44db4f9702a8))
- **core:** set tx body scriptIntegrityHash to correct length (32 byte) ([37822ce](https://github.com/input-output-hk/cardano-js-sdk/commit/37822ce14093ee6e7849fe9c72bd70f86d576a79))
- **core:** support T | T[] where appropriate in metadatumToCip25 ([1a873ec](https://github.com/input-output-hk/cardano-js-sdk/commit/1a873ec182c901813feae8244c86c0346bb70022))
- **core:** throw serialization error for invalid metadata fields ([d67debb](https://github.com/input-output-hk/cardano-js-sdk/commit/d67debb96781474eed775e524fabb3ee48827ea3))
- **core:** tx error mapping fix ([#210](https://github.com/input-output-hk/cardano-js-sdk/issues/210)) ([a03edcd](https://github.com/input-output-hk/cardano-js-sdk/commit/a03edcd806b9038d060ac772b35fccc5819a53ac))
- resolve issues preventing to make a delegation tx ([7429f46](https://github.com/input-output-hk/cardano-js-sdk/commit/7429f466763342b08b6bed44f23d3bf24dbf92f2))
- rm imports from @cardano-sdk/_/src/_ ([3fdead3](https://github.com/input-output-hk/cardano-js-sdk/commit/3fdead3ae381a3efb98299b9881c6a964461b7db))
- validate the correct Ed25519KeyHash length (28 bytes) ([0e0b592](https://github.com/input-output-hk/cardano-js-sdk/commit/0e0b592e2b4b0689f592076cd79dfaac88b43c57))

### Miscellaneous Chores

- update ogmios to 5.1.0 ([973bf9e](https://github.com/input-output-hk/cardano-js-sdk/commit/973bf9e6b74f51167f8a1c45560eaabd37bb8525))

### Code Refactoring

- add serializable object key transformation support ([32e422e](https://github.com/input-output-hk/cardano-js-sdk/commit/32e422e83f723a41521193d9cf4206a538fbcb43))
- change MetadatumMap type to allow any metadatum as key ([48c33e5](https://github.com/input-output-hk/cardano-js-sdk/commit/48c33e552406cce35ea19d720451a1ba641ff51b))
- change TimeSettings interface from fn to obj ([bc3b22d](https://github.com/input-output-hk/cardano-js-sdk/commit/bc3b22d55071f85073c54dcf47c535912bedb512))
- **core:** align Tip and PartialBlockHeader types ([a5d5e49](https://github.com/input-output-hk/cardano-js-sdk/commit/a5d5e494cbc65ce61c84decab228acbeb40ef1d5))
- **core:** change type of Asset.name to AssetName ([ced96ed](https://github.com/input-output-hk/cardano-js-sdk/commit/ced96ed100c06afc855ab0bc526180ba5f5152ce))
- **core:** change WalletProvider.rewardsHistory return type to Map ([07ace58](https://github.com/input-output-hk/cardano-js-sdk/commit/07ace5887e9fed02f5ccb8090594022cd3df28d9))
- **core:** changes value sent and received inspectors ([bdecf31](https://github.com/input-output-hk/cardano-js-sdk/commit/bdecf31b5e316c99e526b2555fa3713842258d79))
- **core:** make StakeDelegationCertificate.epoch optional ([3c6155b](https://github.com/input-output-hk/cardano-js-sdk/commit/3c6155b0bc5da5f9724c5604ee19eb9082b4af8f))
- **core:** move StakePool.metadata under PoolParameters ([9a9ac26](https://github.com/input-output-hk/cardano-js-sdk/commit/9a9ac26e3e0cedc10fc80810af11b9d4e0a36467))
- **core:** nest errors under TxSubmissionErrors object ([6e61857](https://github.com/input-output-hk/cardano-js-sdk/commit/6e618570957a655d856f45e4e52d17bf3b164def))
- **core:** remove AssetMintOrBurn.action in favor of using negative qty for burn ([993f53a](https://github.com/input-output-hk/cardano-js-sdk/commit/993f53aed4c192a57ca26526c3ddd879befbd796))
- **core:** remove PoolRegistrationCertificate.poolId ([c73ac29](https://github.com/input-output-hk/cardano-js-sdk/commit/c73ac29e7120cd7fc57a1f262244e20c26cae78a))
- **core:** rm epoch? from core certificate types ([cc904a1](https://github.com/input-output-hk/cardano-js-sdk/commit/cc904a1b2ee5002b71c8f94bddc50db0effb52ad))
- delete nftMetadataProvider and remove it from AssetTracker ([2904cc3](https://github.com/input-output-hk/cardano-js-sdk/commit/2904cc32a60734e2972425c96c67a2a590c7d2cb))
- extract tx submit into own provider ([1d7ac73](https://github.com/input-output-hk/cardano-js-sdk/commit/1d7ac7393fbd669f08b516c4067883d982f2e711))
- makeTxIn.address required, add NewTxIn that has no address ([83cd354](https://github.com/input-output-hk/cardano-js-sdk/commit/83cd3546840f936af5e0cde0e43d54f924602400))
- move asset info type from Cardano to Asset ([212b670](https://github.com/input-output-hk/cardano-js-sdk/commit/212b67041598cbcc2c2cf4f5678928943de7aa29))
- move jsonToMetadatum from blockfrost package to core.ProviderUtil ([adeb02c](https://github.com/input-output-hk/cardano-js-sdk/commit/adeb02cdbb1401ff4e9c43d28263357d6f27b0d6))
- move stakePoolStats from wallet provider to stake pool provider ([52d71a7](https://github.com/input-output-hk/cardano-js-sdk/commit/52d71a70700b05902cca6205fe01a63f811ba5af))
- remove TimeSettingsProvider and NetworkInfo.currentEpoch ([4a8f72f](https://github.com/input-output-hk/cardano-js-sdk/commit/4a8f72f57f699f7c0bf4a9a4b742fc0a3e4aa8ce))
- remove transactions and blocks methods from blockfrost wallet provider ([e4de136](https://github.com/input-output-hk/cardano-js-sdk/commit/e4de13650f0d387b8e7126077e8721f353af8c85))
- rename `StakePoolSearchProvider` to `StakePoolProvider` ([b432103](https://github.com/input-output-hk/cardano-js-sdk/commit/b43210348da7914664733f85f8be8999271a8667))
- rename AssetInfo metadata->tokenMetadata ([f064f37](https://github.com/input-output-hk/cardano-js-sdk/commit/f064f372b3d7273c24d78695ceac7254fa55e51f))
- rename AssetMetadata->TokenMetadata, update fields ([a83b897](https://github.com/input-output-hk/cardano-js-sdk/commit/a83b89748ec7efe7dcdbb849ab4b369dd49e5fcc))
- rename some WalletProvider functions ([72ad875](https://github.com/input-output-hk/cardano-js-sdk/commit/72ad875ca8e9c3b65c23794a95ca4110cf34a034))
- split up WalletProvider.utxoDelegationAndRewards ([18f5a57](https://github.com/input-output-hk/cardano-js-sdk/commit/18f5a571cb9d581007182b39d2c68b38491c70e6))

### 0.1.5 (2021-10-27)

### Features

- add WalletProvider.transactionDetails, add address to TxIn ([889a39b](https://github.com/input-output-hk/cardano-js-sdk/commit/889a39b1feb988144dd2249c6c47f91e8096fd48))
- **cardano-graphql:** generate graphql client from shema+operations ([9632eb4](https://github.com/input-output-hk/cardano-js-sdk/commit/9632eb40263cabc0eea8ff813180be90af63eacb))
- **cardano-graphql:** generate graphql schema from ts code ([a3e90ad](https://github.com/input-output-hk/cardano-js-sdk/commit/a3e90ad8e5c790ea250bc779b7e10f4657cdccbd))
- **cardano-graphql:** implement CardanoGraphQLStakePoolSearchProvider (wip) ([80deda6](https://github.com/input-output-hk/cardano-js-sdk/commit/80deda6963a0c07b2f0b24a0a5465c488305d83c))
- **cardano-graphql:** initial implementation of StakePoolSearchClient ([8f4f72a](https://github.com/input-output-hk/cardano-js-sdk/commit/8f4f72af7f6ca61b025f2d98e2edf24108b6e38c))
- **core:** add cslToOgmios.txIn ([5bb937e](https://github.com/input-output-hk/cardano-js-sdk/commit/5bb937e277e3fd23991db2cff1c1ec574904e048))
- **core:** add cslUtil.bytewiseEquals ([1851eb4](https://github.com/input-output-hk/cardano-js-sdk/commit/1851eb4749f8cc43c11acec30377ea5c2f42671a))
- **core:** add NotImplementedError ([5344969](https://github.com/input-output-hk/cardano-js-sdk/commit/534496926a6034f4cea401efa0bb23622b1cb3e6))
- **core:** isAddress util ([3f53e79](https://github.com/input-output-hk/cardano-js-sdk/commit/3f53e79f08fd0fd10764c3c648e356d368398df5))

### 0.1.3 (2021-10-05)

### 0.1.2 (2021-09-30)

### 0.1.1 (2021-09-30)

### Features

- add CardanoProvider.networkInfo ([1596ac2](https://github.com/input-output-hk/cardano-js-sdk/commit/1596ac27b3fa3494f784db37831f85e06a8e0e03))
- add CardanoProvider.stakePoolStats ([c25e570](https://github.com/input-output-hk/cardano-js-sdk/commit/c25e5704be13a9c259fa399e35a3771caad58d38))
- add core package with Genesis type defs ([d480373](https://github.com/input-output-hk/cardano-js-sdk/commit/d4803733d7e7bd10658e7c95615f6c0a240850ed))
- add maxTxSize to `ProtocolParametersRequiredByWallet` ([a9a5d16](https://github.com/input-output-hk/cardano-js-sdk/commit/a9a5d16db18fbf2a4cbbad1ad1cdf3f42ef891f9))
- add Provider.ledgerTip ([0e7d224](https://github.com/input-output-hk/cardano-js-sdk/commit/0e7d224a8b3315991785a1a6393d60f35b757e6a))
- **blockfrost:** create new provider called blockfrost ([b8bd72f](https://github.com/input-output-hk/cardano-js-sdk/commit/b8bd72ffc91769e525400a898cf8e7a749b7d610))
- **cardano-graphql-provider:** create cardano-graphql-provider package ([096225f](https://github.com/input-output-hk/cardano-js-sdk/commit/096225f571aa1b5def660a2bdccfd5bad3d1ef12))
- **cardano-serialization-lib:** add Ogmios to CardanoWasm translator ([0bb2077](https://github.com/input-output-hk/cardano-js-sdk/commit/0bb2077f8b2c3a90520dd989b667aef88ddcd30f))
- **cip-30:** create cip-30 package ([266e719](https://github.com/input-output-hk/cardano-js-sdk/commit/266e719d8c0b8550e05ff4d8da199a4575c0664e))
- **core|blockfrost:** modify utxo method on provider to return delegations & rewards ([e0a1bf0](https://github.com/input-output-hk/cardano-js-sdk/commit/e0a1bf020c54d66d2c7920e21dc1369cfc912cbf))
- **core:** add `currentWalletProtocolParameters` method to `CardanoProvider` ([af741c0](https://github.com/input-output-hk/cardano-js-sdk/commit/af741c073c48f7f5ad2f065fd50a48af741c133c))
- **core:** add utils originally used in cip2 package ([2314c4f](https://github.com/input-output-hk/cardano-js-sdk/commit/2314c4f4c19bb7ffeadf98ec2a74399cf7722335))
- create in-memory-key-manager package ([a819e5e](https://github.com/input-output-hk/cardano-js-sdk/commit/a819e5e2161a0cd6bd45c61825957efa810530d3))
- **wallet:** createTransactionInternals ([1aa7032](https://github.com/input-output-hk/cardano-js-sdk/commit/1aa7032421940ef85aa9eb3d0251a79caaaa19d8))

### Bug Fixes

- add missing yarn script, and rename ([840135f](https://github.com/input-output-hk/cardano-js-sdk/commit/840135f7d100c9a00ff410147758ee7d02112897))
- **core:** handle values without assets ([e2862b7](https://github.com/input-output-hk/cardano-js-sdk/commit/e2862b7e54ae1ce8eb6b2b2d2e8eb694136ab5ce))
