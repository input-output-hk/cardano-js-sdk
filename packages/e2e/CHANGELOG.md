# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.13.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.13.0...@cardano-sdk/e2e@0.13.1) (2023-06-06)

**Note:** Version bump only for package @cardano-sdk/e2e

## [0.13.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.12.1...@cardano-sdk/e2e@0.13.0) (2023-06-05)

### ⚠ BREAKING CHANGES

* **wallet:** Added new properties to DelegationTrackerProps
* make stake pool metrics an optional property to handle activating pools
* - rename `rewardsHistoryLimit` stake pool search arg to `apyEpochsBackLimit`
* - remove `epochRewards` and type `StakePoolEpochRewards`
- remove `transactions` and type `StakePoolTransactions`

### Features

* **wallet:** delegation.portfolio$ tracker ([7488d14](https://github.com/input-output-hk/cardano-js-sdk/commit/7488d14008f7aa3d91d7513cfffaeb81e160eb18))

### Code Refactoring

* make stake pool metrics an optional property to handle activating pools ([d33bd07](https://github.com/input-output-hk/cardano-js-sdk/commit/d33bd07ddb873ba40498a95caa860820f38ee687))
* remove unusable fields from StakePool core type ([a7aa17f](https://github.com/input-output-hk/cardano-js-sdk/commit/a7aa17fdd5224437555840d21f56c4660142c351))
* rename rewardsHistoryLimit ([05ccdc6](https://github.com/input-output-hk/cardano-js-sdk/commit/05ccdc6b448f98ddd09894b633521e79fbb6d9c1))

## [0.12.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.12.0...@cardano-sdk/e2e@0.12.1) (2023-06-01)

### Features

* add HandleProvider interface and handle support implementation to TxBuilder ([f209095](https://github.com/input-output-hk/cardano-js-sdk/commit/f2090952c8a0512fc589674b876f3a27be403140))

## [0.12.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.11.0...@cardano-sdk/e2e@0.12.0) (2023-05-24)

### ⚠ BREAKING CHANGES

* the SingleAddressWallet class was renamed to PersonalWallet
* the single address wallet now takes an additional dependency 'AddressDiscovery'

### Features

* the single address wallet now takes an additional dependency 'AddressDiscovery' ([d6d7cff](https://github.com/input-output-hk/cardano-js-sdk/commit/d6d7cffe3a7089af2aff39e78c491f4e0a06c989))

### Code Refactoring

* the SingleAddressWallet class was renamed to PersonalWallet ([1b50183](https://github.com/input-output-hk/cardano-js-sdk/commit/1b50183ea095813b1676571d059c7774f46fb3f3))

## [0.11.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.10.1...@cardano-sdk/e2e@0.11.0) (2023-05-22)

### ⚠ BREAKING CHANGES

* Replace ObservableWalletTxBuilder and buildTx with wallet.createTxBuilder()
- SignedTx type no longer has submit() method.
- TxBuilder no longer has `isSubmitted()`
- Renamed ValidTxBody to UnsignedTx
- Removed ValidTx, InvalidTx, MaybeValidTx
- TxBuilder.build now returns an UnsignedTxPromise.
- TxBuilder.build throws in case of errors instead of returning InvalidTx
- Removed ValidTxOutData, ValidTxOut, InvalidTxOut, MaybeValidTxOut types.
- OutputBuilder.build now returns Cardano.TxOut.
- OutputBuilder.build throws TxOutValidationError in case of errors instead of returning InvalidTxOut
- Replace synchronous builder properties with async inspect()
- Rename some TxBuilder methods for consistency: align with OutputBuilder API,
where 'setters' are not prefixed with 'set'
- Hoist FinalizeTxProps back to 'wallet' package
- Hoist InitializeTxProps.scripts to InitializeTxProps.witness.scripts
- Hoist tx builder output validator arg under 'dependencies' object
- Reject TxBuilder.build.inspect() and sign() with a single error
* hoist createTransactionInternals to tx-construction
- hoist outputValidator to tx-construction
- hoist txBuilder types to tx-construction
- rename ObservableWalletTxOutputBuilder to TxOutputBuilder
- move Delegatee, StakeKeyStatus and RewardAccount types from wallet to tx-construction
- removed PrepareTx, createTxPreparer and PrepareTxDependencies
- OutputValidatorContext was renamed to WalletOutputValidatorContext
* add ledger package with transformations
* - KeyAgentBase deriveAddress method now requires the caller to specify the skate key index

### Features

* add ledger package with transformations ([58f3a22](https://github.com/input-output-hk/cardano-js-sdk/commit/58f3a227d466c0083bcfe9243311ac2bca4e48df))
* add the the pg-boss worker ([561fd50](https://github.com/input-output-hk/cardano-js-sdk/commit/561fd508a4a96307b023b16ce6fed3ce1d7bd536))
* generic tx-builder ([aa4a539](https://github.com/input-output-hk/cardano-js-sdk/commit/aa4a539d6a5ddd75120450e02afeeba9bed6a527))
* key agent now takes an additional parameter stakeKeyDerivationIndex ([cbfd3c1](https://github.com/input-output-hk/cardano-js-sdk/commit/cbfd3c1ea55de4355e38f822868b0a7b6bd3953a))

### Code Refactoring

* move tx build utils from wallet to tx-construction ([48072ce](https://github.com/input-output-hk/cardano-js-sdk/commit/48072ce35968820b10fcf0b9ed4441f00ac6fb8b))

## [0.10.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.10.0...@cardano-sdk/e2e@0.10.1) (2023-05-03)

**Note:** Version bump only for package @cardano-sdk/e2e

## [0.10.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.9.0...@cardano-sdk/e2e@0.10.0) (2023-05-02)

### ⚠ BREAKING CHANGES

- - auxiliaryDataHash is now included in the TxBody core type.

* networkId is now included in the TxBody core type.
* auxiliaryData no longer contains the optional hash field.
* auxiliaryData no longer contains the optional body field.

- **core:** - NFT metadata image is type 'Uri'

* NFT metadata description is type 'string'
* NFT metadata file src is type 'Uri'
* NFT metadata file name is optional

- **web-extension:** WalletManagerWorker now requires an extra dependency: managerStorage
- - renamed `TransactionsTracker.outgoing.confirmed$` to `onChain$`

* renamed `TransactionReemitterProps.transactions.outgoing.confirmed$` to `onChain$`
* renamed web-extension `observableWalletProperties.transactions.outgoing.confirmed$`
  to `onChain$`
* rename ConfirmedTx to OutgoingOnChainTx
* renamed OutgoingOnChainTx.confirmedAt to `slot`

- **wallet:** `AssetsTrackerProps.balanceTracker` was replaced
  by `transactionsTracker`
- rename ObservableWallet assets$ to assetInfo$
- rename AssetInfo 'quantity' to 'supply'
- remove one layer of projection abstraction
- **projection:** convert projectIntoSink into rxjs operator
- simplify projection Sink to be an operator

### Features

- add healthCheck$ to ObservableCardanoNode ([df35035](https://github.com/input-output-hk/cardano-js-sdk/commit/df3503597832939e6dc9c7ec953d24b3d709c723))
- add script to generate addreses ([7cb07ec](https://github.com/input-output-hk/cardano-js-sdk/commit/7cb07ec1b2d5a44e68d48fec33a1bd548a4acdb1))
- adds the sql queries profiling system ([7f972fd](https://github.com/input-output-hk/cardano-js-sdk/commit/7f972fd54073082cc75d2e7b49a92277e47148c1))
- **cardano-services:** add projector service ([5a5b281](https://github.com/input-output-hk/cardano-js-sdk/commit/5a5b281690283995b9a20c61c337c621b919fb3c))
- transaction body core type now includes the auxiliaryDataHash and networkId fields ([8b92b01](https://github.com/input-output-hk/cardano-js-sdk/commit/8b92b0190083a2b956ae1e188121414428f6663b))
- **wallet:** emit historical data on assetInfo$ ([12cac96](https://github.com/input-output-hk/cardano-js-sdk/commit/12cac96852a2591dd27727296d6c3b3fda4e0c56))
- **web-extension:** store and restore last activated wallet props ([1f78d87](https://github.com/input-output-hk/cardano-js-sdk/commit/1f78d87c438c630bf4ee835a387449c667cde319))

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))
- **core:** invalid NFT model and CIP-25 validation ([0d9b77a](https://github.com/input-output-hk/cardano-js-sdk/commit/0d9b77ae1851e5ea1386c94e9e32e3fbdfeed201))

### Code Refactoring

- **projection:** convert projectIntoSink into rxjs operator ([490ca1b](https://github.com/input-output-hk/cardano-js-sdk/commit/490ca1b7f0f92e4fa84179ba3fb265ee68dee735))
- remove one layer of projection abstraction ([6a0eca9](https://github.com/input-output-hk/cardano-js-sdk/commit/6a0eca92d1b6507e7143bfb5a93974b59757d5c5))
- rename AssetInfo 'quantity' to 'supply' ([6e28df4](https://github.com/input-output-hk/cardano-js-sdk/commit/6e28df412797974b8ce6f6deb0c3346ff5938a05))
- rename confirmed$ to onChain$ ([0de59dd](https://github.com/input-output-hk/cardano-js-sdk/commit/0de59dd335d065a85a4467bb501b041d889311b5))
- rename ObservableWallet assets$ to assetInfo$ ([d6b759c](https://github.com/input-output-hk/cardano-js-sdk/commit/d6b759cd2d8db12313a166259277a2c79149e5f9))
- simplify projection Sink to be an operator ([d9c6826](https://github.com/input-output-hk/cardano-js-sdk/commit/d9c68265d63300d26eb73ca93f5ee8be7ff51a12))

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.8.0...@cardano-sdk/e2e@0.9.0) (2023-03-13)

### ⚠ BREAKING CHANGES

- **projection:** replace projectIntoSink 'sinks' prop with 'sinksFactory'
- upgrade resolveInputAddress to resolveInput
- **projection:** replace register/deregister with insert/del for withStakeKeys
- added optional isValid field to Transaction object
- **wallet:** add missing `witness` fields to initializeTx and finalizeTx props
- **cardano-services:** rename http-server to provider-server
- core type for address string reprensetation 'Address' renamed to PaymentAddress

### Features

- added optional isValid field to Transaction object ([f722ae8](https://github.com/input-output-hk/cardano-js-sdk/commit/f722ae8075744a6ca61df1c2c077131cbd0ecf3b))
- adds caching stake pools metric from blockfrost ([d2de0a4](https://github.com/input-output-hk/cardano-js-sdk/commit/d2de0a4efa8f443fb4b63da9a6322eeaa099d09e))
- **e2e:** add new env variable PROJECTION_PG_CONNECTION_STRING ([0ff4e84](https://github.com/input-output-hk/cardano-js-sdk/commit/0ff4e84719975980832ee35b6e98d66da123fdc0))
- **projection-typeorm:** initial implementation ([d0d8ccb](https://github.com/input-output-hk/cardano-js-sdk/commit/d0d8ccbfac6e5732497cd1719c005a4cc241f30c))
- **projection:** replace register/deregister with insert/del for withStakeKeys ([9386990](https://github.com/input-output-hk/cardano-js-sdk/commit/938699076b5ed67fecdb7663c26526ce7e80356a))
- upgrade resolveInputAddress to resolveInput ([fcfa035](https://github.com/input-output-hk/cardano-js-sdk/commit/fcfa035a3498f675945dafcc82b8f05c08318dd8))
- **wallet:** add missing `witness` fields to initializeTx and finalizeTx props ([c34ee2b](https://github.com/input-output-hk/cardano-js-sdk/commit/c34ee2b7cf056a6861523823afff64b70654500b))

### Code Refactoring

- **cardano-services:** rename http-server to provider-server ([7b58748](https://github.com/input-output-hk/cardano-js-sdk/commit/7b587480edda5a9f36796ac577fd56baa6d4ee11))
- core type for address string reprensetation 'Address' renamed to PaymentAddress ([4287463](https://github.com/input-output-hk/cardano-js-sdk/commit/42874633de6069510efdc57323f61140d22ed203))
- **projection:** replace projectIntoSink 'sinks' prop with 'sinksFactory' ([8f15f6f](https://github.com/input-output-hk/cardano-js-sdk/commit/8f15f6f9fa09fea25df7d14ed10a64afcfa234c2))

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.7.0...@cardano-sdk/e2e@0.8.0) (2023-03-01)

### ⚠ BREAKING CHANGES

- **cardano-services:** simplify program args interface

### Bug Fixes

- **e2e:** wallet restoration scenario ([ef8d95c](https://github.com/input-output-hk/cardano-js-sdk/commit/ef8d95c60d6cdfd030eecb185b329da6d260c82f))

### Code Refactoring

- **cardano-services:** simplify program args interface ([eb6ceb3](https://github.com/input-output-hk/cardano-js-sdk/commit/eb6ceb394a2e9525b65933bda1a5800eaa1cc652))

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.6.0...@cardano-sdk/e2e@0.7.0) (2023-02-17)

### ⚠ BREAKING CHANGES

- **wallet:** ObservableWallet.transactions.outgoing.\* types have been updated to emit
  events that no longer contain the entire deserialized Cardano.Tx.
  Instead, it now contains serialized transaction (hex-encoded cbor)
  and deserialized transaction body.

PouchDB stores will re-create the stores of volatileTransactions and inFlightTransactions
with a new db name ('V2' suffix), which means that data in existing stores will be forgotten.

- replaces occurrences of password with passphrase
- **wallet:** return cip30 addresses as cbor instead of bech32
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
- - all provider constructors are updated to use standardized form of deps

### Features

- **e2e:** adds development version of local-network ([6ab352c](https://github.com/input-output-hk/cardano-js-sdk/commit/6ab352c4fc0c4faf4c6acffc569df460a1a99527))
- **e2e:** enhance dev version of local network to include node_packages dir as well ([fb20a7c](https://github.com/input-output-hk/cardano-js-sdk/commit/fb20a7c115368254b3844244f498299480218886))
- update CompactGenesis slotLength type to be Seconds ([82e63d6](https://github.com/input-output-hk/cardano-js-sdk/commit/82e63d6cacedbab5ecf8491dfd37749bfeddbc22))
- **wallet:** manage unspendables after collateral consumption or chain rollbacks ([e600746](https://github.com/input-output-hk/cardano-js-sdk/commit/e6007465e617698954a61774b3c2a461678c322a))
- **wallet:** support foreign transaction submission ([3a116c6](https://github.com/input-output-hk/cardano-js-sdk/commit/3a116c637f88f37cae302a477ca5375fca65f088))

### Bug Fixes

- fixes a minor bug in stake pool query sort by name ([5eb3aa5](https://github.com/input-output-hk/cardano-js-sdk/commit/5eb3aa52faed5add00fa63f74094033a8fb28fa0))
- **wallet:** return cip30 addresses as cbor instead of bech32 ([cae6081](https://github.com/input-output-hk/cardano-js-sdk/commit/cae6081e672d2f4678762ca20be432765be5eeae))

### Code Refactoring

- hoist Opaque types, hexBlob, Base64Blob and related utils ([391a8f2](https://github.com/input-output-hk/cardano-js-sdk/commit/391a8f20d60607c4fb6ce8586b97ae96841f759b))
- refactor the SDK to use the new crypto package ([3b41320](https://github.com/input-output-hk/cardano-js-sdk/commit/3b41320e7971a231d50785733ff4cd0793418d3d))
- replaces occurrences of password with passphrase ([0c0ec5f](https://github.com/input-output-hk/cardano-js-sdk/commit/0c0ec5fba7a0f7595dbca5b2ab1c66e58ac49e36))
- standardize provider dependencies ([05b37e6](https://github.com/input-output-hk/cardano-js-sdk/commit/05b37e6383a906152df457143c5a27341a11c341))

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.5.0...@cardano-sdk/e2e@0.6.0) (2022-12-22)

### ⚠ BREAKING CHANGES

- **walletManager:** use a unique walletId with walletManager
- - replace KeyAgent.networkId with KeyAgent.chainId

* remove CardanoNetworkId type
* rename CardanoNetworkMagic->NetworkMagics
* add 'logger' to KeyAgentDependencies
* setupWallet now requires a Logger

- use titlecase for mainnet/testnet in NetworkId
- - BlockSize is now an OpaqueNumber rather than a type alias for number

* BlockNo is now an OpaqueNumber rather than a type alias for number
* EpochNo is now an OpaqueNumber rather than a type alias for number
* Slot is now an OpaqueNumber rather than a type alias for number
* Percentage is now an OpaqueNumber rather than a type alias for number

- rename era-specific types in core
- Even if the value of DB_CACHE_TTL was already interpreted in seconds
  rather than in minutes (despite the error in the description), it's default value is
  changed
- remote api wallet manager

### Features

- add opaque numeric types to core package ([9ead8bd](https://github.com/input-output-hk/cardano-js-sdk/commit/9ead8bdb34b7ffc57c32f9ab18a6c6ca14af3fda))
- **e2e:** add artillery to perform stress tests ([0fd40cb](https://github.com/input-output-hk/cardano-js-sdk/commit/0fd40cbf154a8b900720a800dd5436ffc8540cd0))
- remote api wallet manager ([043f1df](https://github.com/input-output-hk/cardano-js-sdk/commit/043f1dff7ed85b43e489d972dc5158712c43ee68))
- rename era-specific types in core ([c4955b1](https://github.com/input-output-hk/cardano-js-sdk/commit/c4955b1f3ae0992bb55b1c1461a1e449be0b6ef2))
- replace KeyAgent.networkId with KeyAgent.chainId ([e44dee0](https://github.com/input-output-hk/cardano-js-sdk/commit/e44dee054611636f34b0a66e27d7971af01e0296))
- **walletManager:** use a unique walletId with walletManager ([55df794](https://github.com/input-output-hk/cardano-js-sdk/commit/55df794239f7b11fe3e6ea23ca36130e6db6c5eb))

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
- fixed an issue that was preveting TxOuts with byron addresses to be deserialized correctly ([65356d5](https://github.com/input-output-hk/cardano-js-sdk/commit/65356d5d07375f5b90c25aca4f1965e35edee747))
- ttl validation now uses seconds and no longer minutes as the cache itself ([f0eb80f](https://github.com/input-output-hk/cardano-js-sdk/commit/f0eb80f73e61ea48f10809fb3c329fb5c4022e6b))

### Code Refactoring

- use titlecase for mainnet/testnet in NetworkId ([252c589](https://github.com/input-output-hk/cardano-js-sdk/commit/252c589480d3e422b9021ea66a67af978fb80264))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/e2e@0.4.0...@cardano-sdk/e2e@0.5.0) (2022-11-04)

### ⚠ BREAKING CHANGES

- **web-extension:** `ExposeApiProps` `api` has changed to observable `api$`.
  Users can use rxjs `of` function to create an observable: `api$: of(api)` to
  adapt existing code to this change.
- free CSL resources using freeable util
- **wallet:** add inFlightTransactions store dependency to TransactionReemitterProps

Resubmit transactions that don't get confirmed for too long:

- **wallet:** add inFlight$ dependency to TransactionsReemitter
- **dapp-connector:** renamed cip30 package to dapp-connector
- add pagination in 'transactionsByAddresses'
- **input-selection:** renamed cip2 package to input-selection
- hoist Cardano.util.{deserializeTx,metadatum}
- buildTx() requires positional params and mandatory logger
- TxBuilder.delegate returns synchronously. No await needed anymore.
- lift key management and governance concepts to new packages
- rework all provider signatures args from positional to a single object
- convert boolean args to support ENV counterparts, parse as booleans
- consolidate cli & run entrypoints
- logger is now required
- rename pouchdb->pouchDb
- hoist stake$ and lovelaceSupply$ out of ObservableWallet
- update min utxo computation to be Babbage-compatible

### Features

- add pagination in 'transactionsByAddresses' ([fc88afa](https://github.com/input-output-hk/cardano-js-sdk/commit/fc88afa9f006e9fc7b50b5a98665058a0d563e31))
- added signing options with extra signers to the transaction finalize method ([514b718](https://github.com/input-output-hk/cardano-js-sdk/commit/514b718825af93965739ec5f890f6be2aacf4f48))
- buildTx added logger ([2831a2a](https://github.com/input-output-hk/cardano-js-sdk/commit/2831a2ac99909fa6f2641f27c633932a4cbdb588))
- **e2e:** export utils as a library ([3ee8496](https://github.com/input-output-hk/cardano-js-sdk/commit/3ee8496177f4719449c869d09d9ea7a47fc38a22))
- **e2e:** update some tests to use txBuilder ([c38d52d](https://github.com/input-output-hk/cardano-js-sdk/commit/c38d52daef9d48fe2c59a383469fa7de57fa6e20))
- outputBuilder txOut method returns snapshot ([d07a89a](https://github.com/input-output-hk/cardano-js-sdk/commit/d07a89a7cb5610768daccc92058595906ea344d2))
- txBuilder deregister stake key cert ([b0d3358](https://github.com/input-output-hk/cardano-js-sdk/commit/b0d335861e2fa2274740f34240dba041e295fef2))
- txBuilder postpone adding certificates until build ([431cf51](https://github.com/input-output-hk/cardano-js-sdk/commit/431cf51a1903eaf7ece50228c587ebea4ccd5fc9))
- **wallet:** resubmit recoverable transactions ([fa8aa85](https://github.com/input-output-hk/cardano-js-sdk/commit/fa8aa850d8afacf5fe1a524c29dd94bc20033a63))
- **web-extension:** enhance remoteApi to allow changing observed api object ([6245b90](https://github.com/input-output-hk/cardano-js-sdk/commit/6245b908d33aa14a2736f110add4605d3ce3ab4e))

### Bug Fixes

- convert boolean args to support ENV counterparts, parse as booleans ([d14bd9d](https://github.com/input-output-hk/cardano-js-sdk/commit/d14bd9d8aeec64f04aab094e0aceb8dc5b803926))
- **e2e:** fix a bug preventing get wallet to be parallelized and make required its logger parameter ([2a67e89](https://github.com/input-output-hk/cardano-js-sdk/commit/2a67e89720e396cc393fc70728590ba333068a2e))
- **e2e:** patch wallet to respect epoch boundary ([6fe2bfe](https://github.com/input-output-hk/cardano-js-sdk/commit/6fe2bfe59fdbbd29671e9bc55e43405844a10fd6))
- free CSL resources using freeable util ([5ce0056](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce0056fb108f7bccfbd9f8ef562b82277f3c613))
- malformed string and add missing service to Docker defaults ([b40edf6](https://github.com/input-output-hk/cardano-js-sdk/commit/b40edf6f2aec7d654206725e38c88ab1f60d8222))
- update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))

### Code Refactoring

- consolidate cli & run entrypoints ([1452bfb](https://github.com/input-output-hk/cardano-js-sdk/commit/1452bfb4935129a37dbd83680d623dca081f3948))
- **dapp-connector:** renamed cip30 package to dapp-connector ([cb4411d](https://github.com/input-output-hk/cardano-js-sdk/commit/cb4411da916b263ad8a6d85e0bdaffcfe21646c5))
- hoist Cardano.util.{deserializeTx,metadatum} ([a1d0754](https://github.com/input-output-hk/cardano-js-sdk/commit/a1d07549e7a5fccd36b9f75b9f713c0def8cb97f))
- hoist stake$ and lovelaceSupply$ out of ObservableWallet ([3bf1720](https://github.com/input-output-hk/cardano-js-sdk/commit/3bf17200c8bae46b02817c16e5138d3678cfa3f5))
- **input-selection:** renamed cip2 package to input-selection ([f4d6632](https://github.com/input-output-hk/cardano-js-sdk/commit/f4d6632d61c5b63bc15a64ec3962425f9ad2d6eb))
- lift key management and governance concepts to new packages ([15cde5f](https://github.com/input-output-hk/cardano-js-sdk/commit/15cde5f9becff94dac17278cb45e3adcaac763b5))
- logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))
- rename pouchdb->pouchDb ([c58ccf9](https://github.com/input-output-hk/cardano-js-sdk/commit/c58ccf9f7a8f701dce87e2f6ddc2f28c0aa68745))
- rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))

## 0.4.0 (2022-08-30)

### ⚠ BREAKING CHANGES

- consolidate cli & run entrypoints
- logger is now required
- rename pouchdb->pouchDb
- hoist stake$ and lovelaceSupply$ out of ObservableWallet
- update min utxo computation to be Babbage-compatible
- hoist KeyAgent's InputResolver dependency to constructor

### Bug Fixes

- **e2e:** fix a bug preventing get wallet to be parallelized and make required its logger parameter ([2a67e89](https://github.com/input-output-hk/cardano-js-sdk/commit/2a67e89720e396cc393fc70728590ba333068a2e))
- malformed string and add missing service to Docker defaults ([b40edf6](https://github.com/input-output-hk/cardano-js-sdk/commit/b40edf6f2aec7d654206725e38c88ab1f60d8222))
- update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))

### Code Refactoring

- consolidate cli & run entrypoints ([1452bfb](https://github.com/input-output-hk/cardano-js-sdk/commit/1452bfb4935129a37dbd83680d623dca081f3948))
- hoist KeyAgent's InputResolver dependency to constructor ([759dc09](https://github.com/input-output-hk/cardano-js-sdk/commit/759dc09b427831cb193f1c0a545901abd4d50254))
- hoist stake$ and lovelaceSupply$ out of ObservableWallet ([3bf1720](https://github.com/input-output-hk/cardano-js-sdk/commit/3bf17200c8bae46b02817c16e5138d3678cfa3f5))
- logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))
- rename pouchdb->pouchDb ([c58ccf9](https://github.com/input-output-hk/cardano-js-sdk/commit/c58ccf9f7a8f701dce87e2f6ddc2f28c0aa68745))

## [0.3.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/e2e@0.3.0) (2022-07-25)

### ⚠ BREAKING CHANGES

- update min utxo computation to be Babbage-compatible
- hoist KeyAgent's InputResolver dependency to constructor

### Bug Fixes

- update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))

### Code Refactoring

- hoist KeyAgent's InputResolver dependency to constructor ([759dc09](https://github.com/input-output-hk/cardano-js-sdk/commit/759dc09b427831cb193f1c0a545901abd4d50254))
