# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.21.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.20.1...@cardano-sdk/wallet@0.21.0) (2023-08-21)

### ⚠ BREAKING CHANGES

* update Transaction.fromTxCbor arg type to TxCBOR

### Bug Fixes

* **wallet:** address key statuses are now updated properly when changes are detected ([1720650](https://github.com/input-output-hk/cardano-js-sdk/commit/1720650f8438442b207d273ba838582dee022b29))
* **wallet:** do not re-serialize tx when computing id ([4e49204](https://github.com/input-output-hk/cardano-js-sdk/commit/4e492041b76f0bb6943f5c6b134e0ae7ae6ab5cb))
* **wallet:** remove tx from inFlight$ when loading by the time it's already on-chain ([56eb6d2](https://github.com/input-output-hk/cardano-js-sdk/commit/56eb6d21c339cf7aae0b68bfe92cd6b9f9036a6d))

### Code Refactoring

* update Transaction.fromTxCbor arg type to TxCBOR ([89dcfde](https://github.com/input-output-hk/cardano-js-sdk/commit/89dcfdec0f42c570d36a92a504eca493658f24e3))

## [0.20.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.20.0...@cardano-sdk/wallet@0.20.1) (2023-08-16)

### Bug Fixes

* **wallet:** do not prevent internal tx re-submission (broken by [#861](https://github.com/input-output-hk/cardano-js-sdk/issues/861)) ([63ce773](https://github.com/input-output-hk/cardano-js-sdk/commit/63ce77327ea0e04ca9a58c7e184ffcdac491dad1))

## [0.20.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.19.0...@cardano-sdk/wallet@0.20.0) (2023-08-15)

### ⚠ BREAKING CHANGES

* add HandleProvider.getPolicyIds and utilize it in PersonalWallet also, handles$ resolvedAt is now only set via hydration (provider)
* updated MIR certificate interface to match the CDDL specification

### Features

* add HandleProvider.getPolicyIds and utilize it in PersonalWallet also, handles$ resolvedAt is now only set via hydration (provider) ([af6a8d0](https://github.com/input-output-hk/cardano-js-sdk/commit/af6a8d011bbd2c218aa23e1d75bb25294fc61a27))
* updated MIR certificate interface to match the CDDL specification ([03d5079](https://github.com/input-output-hk/cardano-js-sdk/commit/03d507951ff310a4019f5ec2f1871fdad77939ee))
* **wallet:** filter out duplicate utxo ([47888ae](https://github.com/input-output-hk/cardano-js-sdk/commit/47888aeeb236e7ab239aa8174068148074744c1a))

## [0.19.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.18.5...@cardano-sdk/wallet@0.19.0) (2023-08-11)

### ⚠ BREAKING CHANGES

* EpochRewards renamed to Reward
- The pool the stake address was delegated to when the reward is earned is now
included in the EpochRewards (Will be null for payments from the treasury or the reserves)
- Reward no longer coalesce rewards from the same epoch
* rename AddressEntity.stakingCredentialHash -> stakeCredentialHash
- rename BaseAddress.getStakingCredential -> getStakeCredential
* the serialization classes in Core package are now exported under the alias Serialization
* **wallet:** add optional callback for getCollateral

### Features

* epoch rewards now includes the pool id of the pool that generated the reward ([96fd72b](https://github.com/input-output-hk/cardano-js-sdk/commit/96fd72bba7b087a74eb2080f0cc6ed7c1c2a7329))
* **wallet:** add optional callback for getCollateral ([9c5ce22](https://github.com/input-output-hk/cardano-js-sdk/commit/9c5ce22da5b842c7233f6e5ee0351d6b8c98d991))

### Bug Fixes

* **wallet:** make PersonalWallet.submitTx idempotent ([babe6a5](https://github.com/input-output-hk/cardano-js-sdk/commit/babe6a5cbb834adafe90fa23714cc74822601eca))

### Code Refactoring

* rename/replace occurences of 'staking' with 'stake' where appropriate ([05fc4c4](https://github.com/input-output-hk/cardano-js-sdk/commit/05fc4c4d83137eb3137583ca0bb443825eac1445))
* the serialization classes in Core package are now exported under the alias Serialization ([06f78bb](https://github.com/input-output-hk/cardano-js-sdk/commit/06f78bb98943c306572c32f5817425ef1ff6fc51))

## [0.18.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.18.4...@cardano-sdk/wallet@0.18.5) (2023-07-31)

**Note:** Version bump only for package @cardano-sdk/wallet

## [0.18.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.18.3...@cardano-sdk/wallet@0.18.4) (2023-07-26)

**Note:** Version bump only for package @cardano-sdk/wallet

## [0.18.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.18.2...@cardano-sdk/wallet@0.18.3) (2023-07-17)

**Note:** Version bump only for package @cardano-sdk/wallet

## [0.18.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.18.1...@cardano-sdk/wallet@0.18.2) (2023-07-13)

### Bug Fixes

* wallet finalizeTx and CIP30 requiresForeignSignatures now wait for at least one known address ([b5fde00](https://github.com/input-output-hk/cardano-js-sdk/commit/b5fde0038dde4082d3cd5eac3bbb8141733ec5b6))
* **wallet:** cip30 getUsedAddresses now returns all known addresses ([18c5df9](https://github.com/input-output-hk/cardano-js-sdk/commit/18c5df9ffbe0a2cce8746d8db916e47975b2ea93))

## [0.18.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.18.0...@cardano-sdk/wallet@0.18.1) (2023-07-05)

### Bug Fixes

* **wallet:** discovery should search for 1/0 too ([cdf79cb](https://github.com/input-output-hk/cardano-js-sdk/commit/cdf79cbaf8925e72e52ad859ef78a0a112729b81))

## [0.18.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.17.3...@cardano-sdk/wallet@0.18.0) (2023-07-04)

### ⚠ BREAKING CHANGES

* added change address resolver to the round robin input selector

### Features

* added change address resolver to the round robin input selector ([ef654ca](https://github.com/input-output-hk/cardano-js-sdk/commit/ef654ca7a7c3217b68360e1d4bee3296e5fc4f0e))

## [0.17.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.17.2...@cardano-sdk/wallet@0.17.3) (2023-07-03)

**Note:** Version bump only for package @cardano-sdk/wallet

## [0.17.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.17.1...@cardano-sdk/wallet@0.17.2) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/wallet

## [0.17.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.17.0...@cardano-sdk/wallet@0.17.1) (2023-06-29)

### Features

* **wallet:** manage cip 67 encoded asset names ([1d2abc7](https://github.com/input-output-hk/cardano-js-sdk/commit/1d2abc739b3cc619fbe3d93257bf547cd8ef1a68))
* **wallet:** resolve handles inside PersonalWallet.handles$ with HandleProvider ([2afe254](https://github.com/input-output-hk/cardano-js-sdk/commit/2afe2540830f3d43344a34313469211e11b4a573))

## [0.17.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.16.3...@cardano-sdk/wallet@0.17.0) (2023-06-28)

### ⚠ BREAKING CHANGES

* move coldObservableProvider to util-rxjs package
* moved strictEquals, sameArrayItems, shallowArrayEquals to util package

### Features

* adds cardanoAddress type in HandleResolution interface ([2ee31c9](https://github.com/input-output-hk/cardano-js-sdk/commit/2ee31c9f0b61fc5e67385128448225d2d1d85617))
* implement verification and presubmission checks on handles in OgmiosTxProvider ([0f18042](https://github.com/input-output-hk/cardano-js-sdk/commit/0f1804287672968614e8aa6bf2f095b0e9a88b22))

### Bug Fixes

* **wallet:** accept tagged 'amount' in getCollateral ([dbc0a37](https://github.com/input-output-hk/cardano-js-sdk/commit/dbc0a37c1649c9b139b83605475d91e93c9e5a50))

### Code Refactoring

* move coldObservableProvider to util-rxjs package ([3522d0c](https://github.com/input-output-hk/cardano-js-sdk/commit/3522d0cbbde21c59e483d769cee14ffee4648972))
* move generic equals methods to util package ([6b5dbd3](https://github.com/input-output-hk/cardano-js-sdk/commit/6b5dbd3382eda3fb58901619438caf946a559715))

## [0.16.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.16.2...@cardano-sdk/wallet@0.16.3) (2023-06-23)

**Note:** Version bump only for package @cardano-sdk/wallet

## [0.16.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.16.1...@cardano-sdk/wallet@0.16.2) (2023-06-20)

### Bug Fixes

* the transaction id computation now accounts for serialization round trip errors ([#771](https://github.com/input-output-hk/cardano-js-sdk/issues/771)) ([55e96c0](https://github.com/input-output-hk/cardano-js-sdk/commit/55e96c0a59d2e254476f089e4eba6cc34fbdba26))
* **wallet:** rewardAccounts duplicates HD wallet ([93fbd73](https://github.com/input-output-hk/cardano-js-sdk/commit/93fbd73e1f7951220c8589f5ea4bdd098d903a02))

## [0.16.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.16.0...@cardano-sdk/wallet@0.16.1) (2023-06-13)

### Bug Fixes

* correct ledger mapping canonical asset and asset group ordering ([2095877](https://github.com/input-output-hk/cardano-js-sdk/commit/20958773d2885ee3e1934363dce96b4e8cea96a7))

## [0.16.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.15.0...@cardano-sdk/wallet@0.16.0) (2023-06-12)

### ⚠ BREAKING CHANGES

* **wallet:** Remove obsolete 'stakeKeyIndexLimit' HDSequantialDiscovery
constructor argument.
* SignedTx.ctx now renamed to context

### Features

* add context to txSubmit ([57589ec](https://github.com/input-output-hk/cardano-js-sdk/commit/57589ecd3120573a0cea7e718291454e9b6f9f3b))
* **wallet:** discover used stake keys ([b63f709](https://github.com/input-output-hk/cardano-js-sdk/commit/b63f7098b28fc835f1f09bc7a92392bc5be7e912))

## [0.15.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.14.0...@cardano-sdk/wallet@0.15.0) (2023-06-06)

### ⚠ BREAKING CHANGES

* **wallet:** rename arrayEquals->sameArrayItems
* input selectors now return a lis of UTXOs instead of values as change

### Features

* add ObservableWallet.handles$ that emits own handles ([1c3b532](https://github.com/input-output-hk/cardano-js-sdk/commit/1c3b532c9b9f4fe48ba1555749b21faa27648c1a))
* input selectors now return a lis of UTXOs instead of values as change ([954745c](https://github.com/input-output-hk/cardano-js-sdk/commit/954745c03b6a2ebdd16797917e2d85b7cb639789))

### Code Refactoring

* **wallet:** rename arrayEquals->sameArrayItems ([8a8b8b6](https://github.com/input-output-hk/cardano-js-sdk/commit/8a8b8b6db82ce6dcb0e05fd4da20d995eb9b44fa))

## [0.14.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.13.1...@cardano-sdk/wallet@0.14.0) (2023-06-05)

### ⚠ BREAKING CHANGES

* **wallet:** Added new properties to DelegationTrackerProps

### Features

* **wallet:** delegation.portfolio$ tracker ([7488d14](https://github.com/input-output-hk/cardano-js-sdk/commit/7488d14008f7aa3d91d7513cfffaeb81e160eb18))
* **wallet:** util to track utxo balance by address ([72f724a](https://github.com/input-output-hk/cardano-js-sdk/commit/72f724ab9c20690e385e2278896d90173e258e9d))

## [0.13.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.13.0...@cardano-sdk/wallet@0.13.1) (2023-06-01)

### Features

* add HandleProvider interface and handle support implementation to TxBuilder ([f209095](https://github.com/input-output-hk/cardano-js-sdk/commit/f2090952c8a0512fc589674b876f3a27be403140))

## [0.13.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.12.0...@cardano-sdk/wallet@0.13.0) (2023-05-24)

### ⚠ BREAKING CHANGES

* the SingleAddressWallet class was renamed to PersonalWallet
* the single address wallet now takes an additional dependency 'AddressDiscovery'

### Features

* the single address wallet now takes an additional dependency 'AddressDiscovery' ([d6d7cff](https://github.com/input-output-hk/cardano-js-sdk/commit/d6d7cffe3a7089af2aff39e78c491f4e0a06c989))

### Code Refactoring

* the SingleAddressWallet class was renamed to PersonalWallet ([1b50183](https://github.com/input-output-hk/cardano-js-sdk/commit/1b50183ea095813b1676571d059c7774f46fb3f3))

## [0.12.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.11.0...@cardano-sdk/wallet@0.12.0) (2023-05-22)

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
* added two new utility functions to extract policy id and asset name from asset id ([b4af015](https://github.com/input-output-hk/cardano-js-sdk/commit/b4af015d26b7c08c8b295ffcba6142caca49f6a8))
* generic tx-builder ([aa4a539](https://github.com/input-output-hk/cardano-js-sdk/commit/aa4a539d6a5ddd75120450e02afeeba9bed6a527))
* key agent now takes an additional parameter stakeKeyDerivationIndex ([cbfd3c1](https://github.com/input-output-hk/cardano-js-sdk/commit/cbfd3c1ea55de4355e38f822868b0a7b6bd3953a))
* **util-dev:** add stubProviders ([6d5d99c](https://github.com/input-output-hk/cardano-js-sdk/commit/6d5d99c80894a4b126647272f490d9e2c472d818))

### Code Refactoring

* move tx build utils from wallet to tx-construction ([48072ce](https://github.com/input-output-hk/cardano-js-sdk/commit/48072ce35968820b10fcf0b9ed4441f00ac6fb8b))

## [0.11.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.10.0...@cardano-sdk/wallet@0.11.0) (2023-05-02)

### ⚠ BREAKING CHANGES

- update WalletApi.getUtxos return type from `undefined` to `null`
- - auxiliaryDataHash is now included in the TxBody core type.

* networkId is now included in the TxBody core type.
* auxiliaryData no longer contains the optional hash field.
* auxiliaryData no longer contains the optional body field.

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
- - `TokenMetadata` has new mandatory property `assetId`

* `DbSyncAssetProvider` constructor requires new
  `DbSyncAssetProviderProp` object as first positional argument
* `createAssetsService` accepts an array of assetIds instead of a
  single assetId

- **wallet:** logger prop is now required in OutputBuilderProps

### Features

- added new Transaction class that can convert between CBOR and the Core Tx type ([cc9a80c](https://github.com/input-output-hk/cardano-js-sdk/commit/cc9a80c17f1c0f46124b0c04c597a7ff96e517d3))
- support assets fetching by ids ([8ed208a](https://github.com/input-output-hk/cardano-js-sdk/commit/8ed208a7a060c6999294c1f53266d6452adb278d))
- transaction body core type now includes the auxiliaryDataHash and networkId fields ([8b92b01](https://github.com/input-output-hk/cardano-js-sdk/commit/8b92b0190083a2b956ae1e188121414428f6663b))
- **wallet:** emit historical data on assetInfo$ ([12cac96](https://github.com/input-output-hk/cardano-js-sdk/commit/12cac96852a2591dd27727296d6c3b3fda4e0c56))
- **wallet:** logger prop is now required in OutputBuilderProps ([d01c1d9](https://github.com/input-output-hk/cardano-js-sdk/commit/d01c1d966ead7aceff0689b228e29a614517c1f5))

### Bug Fixes

- cip30 getUtxos(amount) now returns `null` when wallet has insufficient balance ([9b550eb](https://github.com/input-output-hk/cardano-js-sdk/commit/9b550eb4e9ef4f7a1432defb155bebe4b2ec2c34))
- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))
- **wallet:** add support for cip30 getUtxos 'paginate' when 'amount' is also specified ([13694fe](https://github.com/input-output-hk/cardano-js-sdk/commit/13694fe258eefa0f7262a84048b05accc153e6ad))
- **wallet:** adjust time to wait before resubmit ([32777a7](https://github.com/input-output-hk/cardano-js-sdk/commit/32777a7a7fe452a18c29f423b48b211e760f6051))

### Code Refactoring

- rename AssetInfo 'quantity' to 'supply' ([6e28df4](https://github.com/input-output-hk/cardano-js-sdk/commit/6e28df412797974b8ce6f6deb0c3346ff5938a05))
- rename confirmed$ to onChain$ ([0de59dd](https://github.com/input-output-hk/cardano-js-sdk/commit/0de59dd335d065a85a4467bb501b041d889311b5))
- rename ObservableWallet assets$ to assetInfo$ ([d6b759c](https://github.com/input-output-hk/cardano-js-sdk/commit/d6b759cd2d8db12313a166259277a2c79149e5f9))

## [0.10.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.9.0...@cardano-sdk/wallet@0.10.0) (2023-03-13)

### ⚠ BREAKING CHANGES

- upgrade resolveInputAddress to resolveInput
- added optional isValid field to Transaction object
- **wallet:** add missing `witness` fields to initializeTx and finalizeTx props
- add new Address types that implement CIP-19 natively
- core type for address string reprensetation 'Address' renamed to PaymentAddress

### Features

- add inputSource in transactions ([7ed99d5](https://github.com/input-output-hk/cardano-js-sdk/commit/7ed99d5a12cf8667114c76ecde0cbdc3cfbc3887))
- add new Address types that implement CIP-19 natively ([a892176](https://github.com/input-output-hk/cardano-js-sdk/commit/a8921760b714b090bb6c15d6b4696e2dd0b2fdc5))
- added optional isValid field to Transaction object ([f722ae8](https://github.com/input-output-hk/cardano-js-sdk/commit/f722ae8075744a6ca61df1c2c077131cbd0ecf3b))
- send phase2 validation failed transactions as failed$ ([ef25825](https://github.com/input-output-hk/cardano-js-sdk/commit/ef2582532677aeee4b19e84adf1957f09631dd72))
- upgrade resolveInputAddress to resolveInput ([fcfa035](https://github.com/input-output-hk/cardano-js-sdk/commit/fcfa035a3498f675945dafcc82b8f05c08318dd8))
- **wallet:** add missing `witness` fields to initializeTx and finalizeTx props ([c34ee2b](https://github.com/input-output-hk/cardano-js-sdk/commit/c34ee2b7cf056a6861523823afff64b70654500b))

### Bug Fixes

- **wallet:** cip30 interface now throws ProofGeneration error if it cant sign the tx as specified ([81d9c9c](https://github.com/input-output-hk/cardano-js-sdk/commit/81d9c9cb32dc05d2f579d285fa58a638041dd3d1))
- **wallet:** map tx submission errors to TxSendError in cip30 submitTx ([4522ef3](https://github.com/input-output-hk/cardano-js-sdk/commit/4522ef3f4ee0eb636bcc799fe29f43725ab6726c))

### Code Refactoring

- core type for address string reprensetation 'Address' renamed to PaymentAddress ([4287463](https://github.com/input-output-hk/cardano-js-sdk/commit/42874633de6069510efdc57323f61140d22ed203))

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.8.0...@cardano-sdk/wallet@0.9.0) (2023-03-01)

### Bug Fixes

- **wallet:** undefined invalidHereafter causes failed tx to go undetected ([08daba5](https://github.com/input-output-hk/cardano-js-sdk/commit/08daba51bc4f930ca7b5e1ee23e28b9169b16e15))

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.7.0...@cardano-sdk/wallet@0.8.0) (2023-02-17)

### ⚠ BREAKING CHANGES

- **wallet:** convert SingleAddressWallet.setUnspendable to async
- **wallet:** update ObservableWallet.submitTx signature to return transaction ID
- **wallet:** ObservableWallet.transactions.outgoing.\* types have been updated to emit
  events that no longer contain the entire deserialized Cardano.Tx.
  Instead, it now contains serialized transaction (hex-encoded cbor)
  and deserialized transaction body.

PouchDB stores will re-create the stores of volatileTransactions and inFlightTransactions
with a new db name ('V2' suffix), which means that data in existing stores will be forgotten.

- replaces occurrences of password with passphrase
- **wallet:** return cip30 addresses as cbor instead of bech32
- - The default input selection constraints were moved from input-selection package to tx-construction package.
- **input-selection:** - The ProtocolParametersForInputSelection type now includes the field
  'prices' from the protocol parameters.
- **wallet:** `createTransactionReemitter` returns a
  `TransactionReemiter` object instead of an `Observable<Cardano.NewTxAlonzo>`
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
- **wallet:** ensureValidityInterval now requires slotLength property from Cardano.CompactGenesis
- CompactGenesis.slotLength type changed
  from `number` to `Seconds`

### Features

- expose setUnspendable on ObservableWallet interface ([729e5d7](https://github.com/input-output-hk/cardano-js-sdk/commit/729e5d7c63447837a4196f2e19fb306939873a69))
- **input-selection:** input selection now requires execution unit prices ([680845f](https://github.com/input-output-hk/cardano-js-sdk/commit/680845f5763194a1d6b18bebd8af543fcd5f47e4))
- new tx construction package added ([45c0c75](https://github.com/input-output-hk/cardano-js-sdk/commit/45c0c75b20f766a069af45cec636a1756a3fc0da))
- update CompactGenesis slotLength type to be Seconds ([82e63d6](https://github.com/input-output-hk/cardano-js-sdk/commit/82e63d6cacedbab5ecf8491dfd37749bfeddbc22))
- **wallet:** convert static TTL to be based on slotLength ([7f6df55](https://github.com/input-output-hk/cardano-js-sdk/commit/7f6df557dedb8e2ea4dc393d950d2e895325328d))
- **wallet:** emit failed rollbacks from createTransactionReemitter ([2a64ee5](https://github.com/input-output-hk/cardano-js-sdk/commit/2a64ee58e50d740666491d0e7fb12c97a4f7e1d4))
- **wallet:** manage unspendables after collateral consumption or chain rollbacks ([e600746](https://github.com/input-output-hk/cardano-js-sdk/commit/e6007465e617698954a61774b3c2a461678c322a))
- **wallet:** reemit failures are merged with transactionTracker failure ([2dd9c3d](https://github.com/input-output-hk/cardano-js-sdk/commit/2dd9c3dd7fc3dbf34dd160e022d5c6d3c2713e66))
- **wallet:** support foreign transaction submission ([3a116c6](https://github.com/input-output-hk/cardano-js-sdk/commit/3a116c637f88f37cae302a477ca5375fca65f088))
- **wallet:** update ObservableWallet.submitTx signature to return transaction ID ([0e6c6f1](https://github.com/input-output-hk/cardano-js-sdk/commit/0e6c6f15c1ec21c816680aa257731a069df7ee51))

### Bug Fixes

- **key-management:** correct ledger tx mapping validityIntervalStart prop name ([4627230](https://github.com/input-output-hk/cardano-js-sdk/commit/4627230ff0eb26a473cf3dc1c4c544d5bee8bb09))
- **wallet:** cip30 getCollateral return null on missing utxo ([fbfce69](https://github.com/input-output-hk/cardano-js-sdk/commit/fbfce697c7bc5c3829a25b2254f87ee8afcc0026))
- **wallet:** reject with ApiError(InvalidRequest) when trying to submit invalid tx ([865c8b9](https://github.com/input-output-hk/cardano-js-sdk/commit/865c8b91914638416f8ce79925fa8d3a000fb3fb))
- **wallet:** remove serialization round-trip from CIP-30 submitTx mapping ([8f062e5](https://github.com/input-output-hk/cardano-js-sdk/commit/8f062e5f8dd2ee503f1c63ab7151767470bb3788))
- **wallet:** replace misleading 'nope' errors ([d63dea1](https://github.com/input-output-hk/cardano-js-sdk/commit/d63dea1b0cbb46ba6df4f4988f6b295ac09e01ae))
- **wallet:** return cip30 addresses as cbor instead of bech32 ([cae6081](https://github.com/input-output-hk/cardano-js-sdk/commit/cae6081e672d2f4678762ca20be432765be5eeae))
- **wallet:** standard error codes in getChangeAddress ([b79cb99](https://github.com/input-output-hk/cardano-js-sdk/commit/b79cb99b2671c2a4fe68028b11b330a5fb631611))

### Code Refactoring

- hoist Opaque types, hexBlob, Base64Blob and related utils ([391a8f2](https://github.com/input-output-hk/cardano-js-sdk/commit/391a8f20d60607c4fb6ce8586b97ae96841f759b))
- refactor the SDK to use the new crypto package ([3b41320](https://github.com/input-output-hk/cardano-js-sdk/commit/3b41320e7971a231d50785733ff4cd0793418d3d))
- replaces occurrences of password with passphrase ([0c0ec5f](https://github.com/input-output-hk/cardano-js-sdk/commit/0c0ec5fba7a0f7595dbca5b2ab1c66e58ac49e36))
- reworks stake pool epoch rewards fields to be ledger compliant ([a9ff583](https://github.com/input-output-hk/cardano-js-sdk/commit/a9ff583d26fe427c2816ab286bb3ae4aeacc9301))
- **wallet:** convert SingleAddressWallet.setUnspendable to async ([b5689b1](https://github.com/input-output-hk/cardano-js-sdk/commit/b5689b18c51d6e7db509f4223ad27944e050cb1d))

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.6.0...@cardano-sdk/wallet@0.7.0) (2022-12-22)

### ⚠ BREAKING CHANGES

- Alonzo transaction outputs will now contain a datumHash field, carrying the datum hash digest. However, they will also contain a datum field with the exact same value for backward compatibility reason. In Babbage however, transaction outputs will carry either datum or datumHash depending on the case; and datum will only contain inline datums.
- - replace KeyAgent.networkId with KeyAgent.chainId

* remove CardanoNetworkId type
* rename CardanoNetworkMagic->NetworkMagics
* add 'logger' to KeyAgentDependencies
* setupWallet now requires a Logger

- use titlecase for mainnet/testnet in NetworkId
- moved testnetEraSummaries to util-dev package
- - make `TxBodyAlonzo.validityInterval` an optional field aligned with Ogmios schema
- - BlockSize is now an OpaqueNumber rather than a type alias for number

* BlockNo is now an OpaqueNumber rather than a type alias for number
* EpochNo is now an OpaqueNumber rather than a type alias for number
* Slot is now an OpaqueNumber rather than a type alias for number
* Percentage is now an OpaqueNumber rather than a type alias for number

- rename era-specific types in core
- create a new CML scope for every call of BuildTx in selection constraints
- rename block types

* CompactBlock -> BlockInfo
* Block -> ExtendedBlockInfo

- hoist ogmiosToCore to ogmios package
- classify TxSubmission errors as variant of CardanoNode error
- remote api wallet manager

### Features

- add opaque numeric types to core package ([9ead8bd](https://github.com/input-output-hk/cardano-js-sdk/commit/9ead8bdb34b7ffc57c32f9ab18a6c6ca14af3fda))
- added new babbage era types in Transactions and Outputs ([0b1f2ff](https://github.com/input-output-hk/cardano-js-sdk/commit/0b1f2ffaad2edec281d206a6865cd1e6053d9826))
- adds a retry strategy to single address wallet ([7d01ee9](https://github.com/input-output-hk/cardano-js-sdk/commit/7d01ee931dba467ddd6ec8882d8777c6d289d890))
- implement ogmiosToCore certificates mapping ([aef2e8d](https://github.com/input-output-hk/cardano-js-sdk/commit/aef2e8d64da9352c6aab206034950d64f44e9559))
- remote api wallet manager ([043f1df](https://github.com/input-output-hk/cardano-js-sdk/commit/043f1dff7ed85b43e489d972dc5158712c43ee68))
- rename era-specific types in core ([c4955b1](https://github.com/input-output-hk/cardano-js-sdk/commit/c4955b1f3ae0992bb55b1c1461a1e449be0b6ef2))
- replace KeyAgent.networkId with KeyAgent.chainId ([e44dee0](https://github.com/input-output-hk/cardano-js-sdk/commit/e44dee054611636f34b0a66e27d7971af01e0296))
- type GroupedAddress now includes key derivation paths ([8ac0125](https://github.com/input-output-hk/cardano-js-sdk/commit/8ac0125152fa2f3eb95c3e4c32bee077d2df722f))
- **wallet:** enable pouchdb auto-compaction ([5c24ebc](https://github.com/input-output-hk/cardano-js-sdk/commit/5c24ebc5a27b2c58ff8287a62eee23a6aed6e87b))

### Bug Fixes

- add sideEffects=false to package.json ([a1cb8f8](https://github.com/input-output-hk/cardano-js-sdk/commit/a1cb8f807e8d5947d0c512e0918713ff97d5d48e))
- cip30 wallet has to accept hex encoded address ([d5a748a](https://github.com/input-output-hk/cardano-js-sdk/commit/d5a748a74289c7ec703066a8eca11637e3a84734))
- create a new CML scope for every call of BuildTx in selection constraints ([6818ae4](https://github.com/input-output-hk/cardano-js-sdk/commit/6818ae443dd53ac4786ce161f02aef5635433678))
- **wallet:** assetsTracker never emits ([a0f33b5](https://github.com/input-output-hk/cardano-js-sdk/commit/a0f33b516b74f747dddcb36ea4b9bcbb0c7b65ad))
- **wallet:** rewards amount formula ([9d187ab](https://github.com/input-output-hk/cardano-js-sdk/commit/9d187ab885e5c6d9f2b9c270ba284bb37d4892d1))
- **wallet:** sign entire transaction in cip30 mapping instead of transaction body ([c446d2d](https://github.com/input-output-hk/cardano-js-sdk/commit/c446d2dc6d6d23203864f3a802f04b579aa2a766))
- **wallet:** the SingleAddressWallet now shuts down the RewardsProvider on shutdown ([c1bc43b](https://github.com/input-output-hk/cardano-js-sdk/commit/c1bc43b492457fb5c16a8435be428e241859a7d1))

### Code Refactoring

- classify TxSubmission errors as variant of CardanoNode error ([234305e](https://github.com/input-output-hk/cardano-js-sdk/commit/234305e28aefd3d9bd1736315bdf89ca31f7556f))
- make tx validityInterval an optional ([fa1c487](https://github.com/input-output-hk/cardano-js-sdk/commit/fa1c4877bb64f0e2584950a27861cf16e727cadd))
- moved testnetEraSummaries to util-dev package ([5ad0514](https://github.com/input-output-hk/cardano-js-sdk/commit/5ad0514846dd2d186eb04c29821d987c6409a5c2))
- use titlecase for mainnet/testnet in NetworkId ([252c589](https://github.com/input-output-hk/cardano-js-sdk/commit/252c589480d3e422b9021ea66a67af978fb80264))

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.5.0...@cardano-sdk/wallet@0.6.0) (2022-11-04)

### ⚠ BREAKING CHANGES

- support the complete set of protocol parameters
- free CSL resources using freeable util
- make stake pools pagination a required arg
- **wallet:** add inFlightTransactions store dependency to TransactionReemitterProps

Resubmit transactions that don't get confirmed for too long:

- **wallet:** add inFlight$ dependency to TransactionsReemitter
- **wallet:** group some TransactionReemitter props under TransactionsTracker-compatible obj
- **dapp-connector:** renamed cip30 package to dapp-connector
- add pagination in 'transactionsByAddresses'
- **input-selection:** renamed cip2 package to input-selection
- hoist Cardano.util.{deserializeTx,metadatum}
- hoist core Address namespace to Cardano.util
- hoist some core.Cardano.util._ to core._
- **wallet:** removed `withdrawals` property from `InitializeTxProps`
- **wallet:** compute stability window slots count
- buildTx() requires positional params and mandatory logger
- TxBuilder.delegate returns synchronously. No await needed anymore.
- rename `TxInternals` to `TxBodyWithHash`
- lift key management and governance concepts to new packages
- lift deepEquals to util package in preparation for further wallet decomposition
- hoist InputResolver types to core package, in preparation for lifting key management
- hoist TxInternals to core package, in preparation for lifting key management
- rework TxSubmitProvider to submit transactions as hex string instead of Buffer
- rework all provider signatures args from positional to a single object

### Features

- add pagination in 'transactionsByAddresses' ([fc88afa](https://github.com/input-output-hk/cardano-js-sdk/commit/fc88afa9f006e9fc7b50b5a98665058a0d563e31))
- added signing options with extra signers to the transaction finalize method ([514b718](https://github.com/input-output-hk/cardano-js-sdk/commit/514b718825af93965739ec5f890f6be2aacf4f48))
- buildTx added logger ([2831a2a](https://github.com/input-output-hk/cardano-js-sdk/commit/2831a2ac99909fa6f2641f27c633932a4cbdb588))
- make stake pools pagination a required arg ([6cf8206](https://github.com/input-output-hk/cardano-js-sdk/commit/6cf8206be2162db7196794f7252e5cbb84b65c77))
- outputBuilder txOut method returns snapshot ([d07a89a](https://github.com/input-output-hk/cardano-js-sdk/commit/d07a89a7cb5610768daccc92058595906ea344d2))
- support the complete set of protocol parameters ([46d7aa9](https://github.com/input-output-hk/cardano-js-sdk/commit/46d7aa97230a666ca119c7de5ed0cf70b742d2a2))
- txBuilder deregister stake key cert ([b0d3358](https://github.com/input-output-hk/cardano-js-sdk/commit/b0d335861e2fa2274740f34240dba041e295fef2))
- txBuilder postpone adding certificates until build ([431cf51](https://github.com/input-output-hk/cardano-js-sdk/commit/431cf51a1903eaf7ece50228c587ebea4ccd5fc9))
- **wallet:** add SmartTxSubmitProvider ([7739122](https://github.com/input-output-hk/cardano-js-sdk/commit/773912224db6630e4a1e8ae6e2c1c493eb7a7ad8))
- **wallet:** added a new type of error (proof generation error) ([61ae63f](https://github.com/input-output-hk/cardano-js-sdk/commit/61ae63f8f993e6f26c652b90747534ebff912e41))
- **wallet:** added polling option in coldObservable ([2800f9c](https://github.com/input-output-hk/cardano-js-sdk/commit/2800f9c26c56ae376bcf1fdc78882e1f760a9bb4))
- **wallet:** assets to mint are now being taken into account during input selection ([5ffa4f8](https://github.com/input-output-hk/cardano-js-sdk/commit/5ffa4f84db1c39cf53ca8803750b144acc621b84))
- **wallet:** attempt to re-fetch tokenMetadata/nftMetadata if provider returns it as 'undefined' ([760b449](https://github.com/input-output-hk/cardano-js-sdk/commit/760b449d55d4c6db2f27f18aaa9e1c72e8c2762f))
- **wallet:** compute stability window slots count ([34b77d3](https://github.com/input-output-hk/cardano-js-sdk/commit/34b77d3379d41ac701214970e70656296136526e))
- **wallet:** export default polling interval ([b33c3de](https://github.com/input-output-hk/cardano-js-sdk/commit/b33c3dec145cc9c68aa0b62cabae3b77778b97f7))
- **wallet:** resubmit recoverable transactions ([fa8aa85](https://github.com/input-output-hk/cardano-js-sdk/commit/fa8aa850d8afacf5fe1a524c29dd94bc20033a63))
- **wallet:** transaction building with TxBuilder ([bbc0574](https://github.com/input-output-hk/cardano-js-sdk/commit/bbc0574c21c69e324f351edefad84e317c7f46f7))
- **wallet:** tx builder returns inputSelection and hash on build ([466275e](https://github.com/input-output-hk/cardano-js-sdk/commit/466275eb9048099eb6fb4ce4b0402a65e2418aae))
- **wallet:** txBuilder disable after submit ([169d79b](https://github.com/input-output-hk/cardano-js-sdk/commit/169d79b1749f882aaa667c5cae5fe0fe65c2d639))
- **wallet:** withdraw rewards on every transaction ([45ddc69](https://github.com/input-output-hk/cardano-js-sdk/commit/45ddc69065edea8d1f4681996a356bbe2cc6c400))

### Bug Fixes

- added missing contraints ([7b351ca](https://github.com/input-output-hk/cardano-js-sdk/commit/7b351cada06b9c5ae2f379d02614e05259f7147a))
- free CSL resources using freeable util ([5ce0056](https://github.com/input-output-hk/cardano-js-sdk/commit/5ce0056fb108f7bccfbd9f8ef562b82277f3c613))
- **key-management:** tx that has withdrawals is now signed with stake key ([972a064](https://github.com/input-output-hk/cardano-js-sdk/commit/972a0640970bd140c4f54df8ff9d1b38858aa4ab))
- **wallet:** await for updated rewards after tx confirmation ([60bd426](https://github.com/input-output-hk/cardano-js-sdk/commit/60bd42671a6b0913b9a7902ae5b8a76a35c2bc67))
- **wallet:** await for wallet state to settle before initializeTx ([671be3f](https://github.com/input-output-hk/cardano-js-sdk/commit/671be3fa3aac20ddc36862a955782dd7130adf1f))
- **wallet:** coldObservable retry backoff should recreate observable ([696e815](https://github.com/input-output-hk/cardano-js-sdk/commit/696e815cac6545a83df1f7b312c0680a82ef54f0))
- **wallet:** exclude submitTx reqs when determining wallet sync status ([cf8f10d](https://github.com/input-output-hk/cardano-js-sdk/commit/cf8f10d15f0ca405a55352328b1b2e005f3d0985))
- **wallet:** fail transactions that use utxo produced in a rolled back tx ([5b38895](https://github.com/input-output-hk/cardano-js-sdk/commit/5b38895a598610a195262237366d3c552c6f1944))
- **wallet:** re-submit 'Unknown' tx submission errors ([0d1447f](https://github.com/input-output-hk/cardano-js-sdk/commit/0d1447f5838368f7da223cfb532f2b040bb162f1))
- **wallet:** set correct context for utxo and assets tracker loggers ([7eaea77](https://github.com/input-output-hk/cardano-js-sdk/commit/7eaea77b8e3a6cc5342e5e8486e965fdb1f3ad99))
- **wallet:** tx build: automatic withdrawals amount now take part in implicit coins computation ([2de8e38](https://github.com/input-output-hk/cardano-js-sdk/commit/2de8e387e287051828e411ee55ed91055975411e))

### Code Refactoring

- **dapp-connector:** renamed cip30 package to dapp-connector ([cb4411d](https://github.com/input-output-hk/cardano-js-sdk/commit/cb4411da916b263ad8a6d85e0bdaffcfe21646c5))
- hoist Cardano.util.{deserializeTx,metadatum} ([a1d0754](https://github.com/input-output-hk/cardano-js-sdk/commit/a1d07549e7a5fccd36b9f75b9f713c0def8cb97f))
- hoist core Address namespace to Cardano.util ([c0af6c3](https://github.com/input-output-hk/cardano-js-sdk/commit/c0af6c333420b4305f021a50bbdf25317b85554f))
- hoist InputResolver types to core package, in preparation for lifting key management ([aaf430e](https://github.com/input-output-hk/cardano-js-sdk/commit/aaf430efefcc5c87f1acfaf227f4aec11fc8db8a))
- hoist some core.Cardano.util._ to core._ ([5c18c7b](https://github.com/input-output-hk/cardano-js-sdk/commit/5c18c7be146578991753c081ab4da0adae9b3f88))
- hoist TxInternals to core package, in preparation for lifting key management ([f5510f3](https://github.com/input-output-hk/cardano-js-sdk/commit/f5510f340d592998b3194dd303bd14b184a0a3e3))
- **input-selection:** renamed cip2 package to input-selection ([f4d6632](https://github.com/input-output-hk/cardano-js-sdk/commit/f4d6632d61c5b63bc15a64ec3962425f9ad2d6eb))
- lift deepEquals to util package in preparation for further wallet decomposition ([c935a77](https://github.com/input-output-hk/cardano-js-sdk/commit/c935a77c0bb895ee85b885e8da57ed7de3786e36))
- lift key management and governance concepts to new packages ([15cde5f](https://github.com/input-output-hk/cardano-js-sdk/commit/15cde5f9becff94dac17278cb45e3adcaac763b5))
- rename `TxInternals` to `TxBodyWithHash` ([77567aa](https://github.com/input-output-hk/cardano-js-sdk/commit/77567aab56395ded6d9b0ba7488aacc2d3f856a0))
- rework all provider signatures args from positional to a single object ([dee30b5](https://github.com/input-output-hk/cardano-js-sdk/commit/dee30b52af5edc1241142a2c06708266a1ae7fa4))
- rework TxSubmitProvider to submit transactions as hex string instead of Buffer ([032a1b7](https://github.com/input-output-hk/cardano-js-sdk/commit/032a1b7a11941d52b5baf0d447b615c58a294068))
- **wallet:** group some TransactionReemitter props under TransactionsTracker-compatible obj ([8bba3a4](https://github.com/input-output-hk/cardano-js-sdk/commit/8bba3a4c0b947a3812b39310214bf11c90a54ce2))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/wallet@0.4.0...@cardano-sdk/wallet@0.5.0) (2022-08-30)

### ⚠ BREAKING CHANGES

- rename InputSelectionParameters implicitCoin->implicitValue.coin
- rm TxAlonzo.implicitCoin
- removed Ogmios schema package dependency
- **wallet:** SingleAddressWallet debug logs
- **wallet:** named instead of positional args for createAddressTransactionsProvider
- replace `NetworkInfoProvider.timeSettings` with `eraSummaries`
- logger is now required
- rename pouchdb->pouchDb
- hoist stake$ and lovelaceSupply$ out of ObservableWallet
- - (web-extension) observableWalletProperties has new `transactions.rollback$` property

* (wallet) createAddressTransactionsProvider returns an object with two observables
  `{rollback$, transactionsSource$}`, instead of only the transactionsSource$ observable
* (wallet) TransactionsTracker interface contains new `rollback$` property
* (wallet) TransactionsTracker interface `$confirmed` Observable emits `NewTxAlonzoWithSlot`
  object instead of NewTxAlonzo

- update min utxo computation to be Babbage-compatible

### Features

- implement cip30 getCollateral ([878f021](https://github.com/input-output-hk/cardano-js-sdk/commit/878f021d3620a4842a1629b442ae12a2acd1bf94))
- replace `NetworkInfoProvider.timeSettings` with `eraSummaries` ([58f6fc7](https://github.com/input-output-hk/cardano-js-sdk/commit/58f6fc7c5ace703583c36f95d3d6962483ad924d))
- resubmit rollback transactions ([2a4ccb0](https://github.com/input-output-hk/cardano-js-sdk/commit/2a4ccb0abead34481e817f807850d29e77d7340a))

### Bug Fixes

- update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))
- **wallet:** create contextLogger with non-undefined 'name' ([7f07d35](https://github.com/input-output-hk/cardano-js-sdk/commit/7f07d3514ef4a7d9f74b2ead5a4ed6c9dc1e3724))
- **wallet:** prevent rollback$ from being completed after the first round of rollbacks ([a6cacaa](https://github.com/input-output-hk/cardano-js-sdk/commit/a6cacaa24f2094dcc244072a6611bff2699d6c36))
- **wallet:** replace ApiError hardcoded numbers per APIErroCode enum ([9f5b2c2](https://github.com/input-output-hk/cardano-js-sdk/commit/9f5b2c2533bd1a3e41a9b4f891fab3729c54a7b7))
- **wallet:** stop querying the `StakePoolProvider` for all pools when no delegation certs found ([336f597](https://github.com/input-output-hk/cardano-js-sdk/commit/336f59708234dbf00df41d79b5547765ab7ce894))

### Performance Improvements

- **wallet:** fetch time settings only when epoch changes (ADP-1682) ([8dc7aab](https://github.com/input-output-hk/cardano-js-sdk/commit/8dc7aab8b616f3b9f8f44283a00f77b1271c62f0))

### Code Refactoring

- hoist stake$ and lovelaceSupply$ out of ObservableWallet ([3bf1720](https://github.com/input-output-hk/cardano-js-sdk/commit/3bf17200c8bae46b02817c16e5138d3678cfa3f5))
- logger is now required ([cc82bc2](https://github.com/input-output-hk/cardano-js-sdk/commit/cc82bc27539e3ff07f7c2d5816fa7e70c32d06ac))
- removed Ogmios schema package dependency ([4ed2408](https://github.com/input-output-hk/cardano-js-sdk/commit/4ed24087aa5646c6f68ba31c42fc3f8a317df3b9))
- rename InputSelectionParameters implicitCoin->implicitValue.coin ([3242a0d](https://github.com/input-output-hk/cardano-js-sdk/commit/3242a0dc63da0e59c4f8536d16758ea19f58a2c0))
- rename pouchdb->pouchDb ([c58ccf9](https://github.com/input-output-hk/cardano-js-sdk/commit/c58ccf9f7a8f701dce87e2f6ddc2f28c0aa68745))
- rm TxAlonzo.implicitCoin ([167d205](https://github.com/input-output-hk/cardano-js-sdk/commit/167d205dd15c857b229f968ab53a6e52e5504d3f))
- **wallet:** named instead of positional args for createAddressTransactionsProvider ([3852644](https://github.com/input-output-hk/cardano-js-sdk/commit/3852644daf887098222aeafc2eaa373af83af81b))
- **wallet:** SingleAddressWallet debug logs ([8f5cd0d](https://github.com/input-output-hk/cardano-js-sdk/commit/8f5cd0d24be34d89659a7745c4ef17489a4cbeb8))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/0.3.0...@cardano-sdk/wallet@0.4.0) (2022-07-25)

### ⚠ BREAKING CHANGES

- update min utxo computation to be Babbage-compatible
- hoist KeyAgent's InputResolver dependency to constructor
- **wallet:** tipTracker replaces more generic SyncableIntervalPersistentDocumentTrackerSubject
- **wallet:** - coldObservableProvider expects an object of type
  ColdObservableProviderProps instead of positional args

### Features

- add cip36 metadataBuilder ([0632dc5](https://github.com/input-output-hk/cardano-js-sdk/commit/0632dc508e6be7bc37024e5f8128337ba64a9f47))
- **wallet:** add createLazyWalletUtil ([8a5ec35](https://github.com/input-output-hk/cardano-js-sdk/commit/8a5ec35cd1af283b15a494d8b25911543252d1b8))
- **wallet:** add missing Alonzo-era tx body fields ([69d3db4](https://github.com/input-output-hk/cardano-js-sdk/commit/69d3db4750d40bb816441b6490e604030c3d7540))
- **wallet:** polling strategy uses new connection status tracker ([03603d8](https://github.com/input-output-hk/cardano-js-sdk/commit/03603d82bddf03bee0fe181c11adb02660fc195d))

### Bug Fixes

- update min utxo computation to be Babbage-compatible ([51ca1d5](https://github.com/input-output-hk/cardano-js-sdk/commit/51ca1d5716b62b47d211475aba1be4a6d5782397))
- **wallet:** in memory store name typo ([d63d3fb](https://github.com/input-output-hk/cardano-js-sdk/commit/d63d3fbccb414cc75dad8d4a5a43cc611798c281))
- **wallet:** remove assets no longer available in total balance ([fef65d0](https://github.com/input-output-hk/cardano-js-sdk/commit/fef65d0da9413a2f4631736240ddb88d1de7a86b))

### Performance Improvements

- **wallet:** fetch time settings only when epoch changes (ADP-1682) ([8dc7aab](https://github.com/input-output-hk/cardano-js-sdk/commit/8dc7aab8b616f3b9f8f44283a00f77b1271c62f0))

### Code Refactoring

- hoist KeyAgent's InputResolver dependency to constructor ([759dc09](https://github.com/input-output-hk/cardano-js-sdk/commit/759dc09b427831cb193f1c0a545901abd4d50254))
- **wallet:** replace positional with named params in coldObservableProvider ([4361cb0](https://github.com/input-output-hk/cardano-js-sdk/commit/4361cb0ff5c2c587668c20e3824bf9c2a8a2ff76))
- **wallet:** tipTracker replaces more generic SyncableIntervalPersistentDocumentTrackerSubject ([311a437](https://github.com/input-output-hk/cardano-js-sdk/commit/311a43708f0468d9810a454bf10f265cd104e857))

## 0.3.0 (2022-06-24)

### ⚠ BREAKING CHANGES

- **wallet:** - `store` property in TransactionsTrackerProps interface was renamed to `transactionsHistoryStore`

* new property `inFlightTransactionsStore` is required for TransactionsTrackerProps interface

- improve ObservableWallet.balance interface
- **wallet:** observable wallet supports only async properties
- remove transactions and blocks methods from blockfrost wallet provider
- move stakePoolStats from wallet provider to stake pool provider
- rename `StakePoolSearchProvider` to `StakePoolProvider`
- **wallet:** replace SingleAddressWallet KeyAgent dep with AsyncKeyAgent
- rm ObservableWallet.networkId (to be resolved via networkInfo$)
- revert 7076fc2ae987948e2c52b696666842ddb67af5d7
- **wallet:** clean up ObservableWallet interface so it can be easily exposed remotely
- hoist cip30 mapping of ObservableWallet to cip30 pkg
- **wallet:** rename Wallet interface to ObservableWallet
- **wallet:** rm obsolete cip30.initialize
- delete nftMetadataProvider and remove it from AssetTracker
- **wallet:** removes history all$, outgoing$ and incoming$ from transactions tracker
- **wallet:** changes transactions.history.all$ type from DirectionalTransaction to TxAlonzo
- remove TimeSettingsProvider and NetworkInfo.currentEpoch
- **wallet:** move output validation under Wallet.util
- split up WalletProvider.utxoDelegationAndRewards
- rename some WalletProvider functions
- makeTxIn.address required, add NewTxIn that has no address
- rename uiWallet->webExtensionWalletClient
- validate the correct Ed25519KeyHash length (28 bytes)
- **wallet:** convert Wallet.syncStatus$ into an object
- **wallet:** getExtendedAccountPublicKey -> extendedAccountPublicKey
- **wallet:** change Wallet.assets$ behavior to not emit empty obj while loading
- **wallet:** update stores interface to complete instead of emitting null/empty result
- make blockfrost API instance a parameter of the providers
- Given transaction submission is really an independent behaviour,
  as evidenced by microservices such as the HTTP submission API,
  it's more flexible modelled as an independent provider.
- **wallet:** remove SingleAddressWallet.address
- **wallet:** use HexBlob type from core
- change MetadatumMap type to allow any metadatum as key
- move asset info type from Cardano to Asset
- **wallet:** move cachedGetPassword under KeyManagement.util
- **wallet:** track known/derived addresses in KeyAgent
- **wallet:** rename KeyManagement types, improve test coverage
- **wallet:** use emip3 key encryption, refactor KeyManager to support hw wallets (wip)

### Features

- add cip30 getCollateral method (not implemented) ([2f20255](https://github.com/input-output-hk/cardano-js-sdk/commit/2f202550d8187a5e053afac6490d76df7bffa3f5))
- add Provider interface, use as base for TxSubmitProvider ([e155ed4](https://github.com/input-output-hk/cardano-js-sdk/commit/e155ed4efcd1338a54099d1a9034ccbeddeef1cc))
- add totalResultCount to StakePoolSearch response ([4265f6a](https://github.com/input-output-hk/cardano-js-sdk/commit/4265f6af60a92c93604b93167fd297530b6e01f8))
- add WalletProvider.rewardsHistory ([d84c980](https://github.com/input-output-hk/cardano-js-sdk/commit/d84c98086a8cb49de47a2ffd78448899cb47036b))
- **cip30:** add tests for multi-dapp connections, update mapping tests ([8119511](https://github.com/input-output-hk/cardano-js-sdk/commit/81195110f31dff1c9cb62dab03f139cc6e04fe8c))
- **cip30:** initial wallet mapping to cip30api ([66aa6d5](https://github.com/input-output-hk/cardano-js-sdk/commit/66aa6d5b7cc5836dfa6f947af3df86e62318960c))
- **core:** initial cslToCore.newTx implementation ([52835f2](https://github.com/input-output-hk/cardano-js-sdk/commit/52835f279381e79422b1a6761cabc3a6b6144961))
- **wallet:** 2nd-factor mnemonic encryption ([7ddac7a](https://github.com/input-output-hk/cardano-js-sdk/commit/7ddac7ad731e9f2dfb2fbc9f5a2a9cc18b6ab852))
- **wallet:** add 'inputSelection' to initializeTx result ([15a28b3](https://github.com/input-output-hk/cardano-js-sdk/commit/15a28b3ad3f37f433c2acf43266ee0957b4a645a))
- **wallet:** add AsyncKeyAgent ([b4856d3](https://github.com/input-output-hk/cardano-js-sdk/commit/b4856d3adfd55d13147215d8e9ec7af0eb1b370b))
- **wallet:** add Balance.deposit and Wallet.delegation.rewardAccounts$ ([7a47d26](https://github.com/input-output-hk/cardano-js-sdk/commit/7a47d26a724d7670e5b4d3c54552491274c0d829))
- **wallet:** add destroy() to clear resources of the stores ([8a1fc09](https://github.com/input-output-hk/cardano-js-sdk/commit/8a1fc09dcdfc42258fd128eabea76a4ac5c5946f))
- **wallet:** add emip3 encryption util ([7ceee7a](https://github.com/input-output-hk/cardano-js-sdk/commit/7ceee7a469905e6faf070c6dde4aa748b10b5649))
- **wallet:** add KeyManagement.cachedGetPassword util ([0594492](https://github.com/input-output-hk/cardano-js-sdk/commit/0594492a4489ac12115a6437e5256e6c7c82dcab))
- **wallet:** add KeyManagement.util.ownSignaturePaths ([26ca7ce](https://github.com/input-output-hk/cardano-js-sdk/commit/26ca7ce42dac87f4f184cd8a3b564c511632389f))
- **wallet:** add KeyManager.derivePublicKey and KeyManager.extendedAccountPublicKey ([f3a53b0](https://github.com/input-output-hk/cardano-js-sdk/commit/f3a53b07d83e601d45f5113899f0ed68a4227177))
- **wallet:** add KeyManager.rewardAccount ([5107afd](https://github.com/input-output-hk/cardano-js-sdk/commit/5107afdc4f5fdbe08abf1c0ccc73376e65121dee))
- **wallet:** Add NodeHID support and HW tests using it ([522669f](https://github.com/input-output-hk/cardano-js-sdk/commit/522669f40833db63031e4c16284e75123ac43c78))
- **wallet:** add optional NFT metadata to Wallet.assets$ ([6671f7e](https://github.com/input-output-hk/cardano-js-sdk/commit/6671f7eb308e460d74e9ce79ac2b63f24f3dd760))
- **wallet:** add restoreLedgerKeyAgent ([2049b48](https://github.com/input-output-hk/cardano-js-sdk/commit/2049b488b2323d088a29c655fa43fa1c8e9e0d43))
- **wallet:** add static method to create agent with device and change accessing xpub method ([726b29f](https://github.com/input-output-hk/cardano-js-sdk/commit/726b29fb72fdaf4d0f460ad54a194a316c29fb96))
- **wallet:** add support for building tx with metadata ([28d0e67](https://github.com/input-output-hk/cardano-js-sdk/commit/28d0e670f9023d5f98fbe7a7840273fc5e0dd20d))
- **wallet:** add types for NFT metadata ([913c217](https://github.com/input-output-hk/cardano-js-sdk/commit/913c217a6da706f8acd3d60d556092bef7447415))
- **wallet:** add unspendable utxo observable and store ([e7d743e](https://github.com/input-output-hk/cardano-js-sdk/commit/e7d743e0fa68e56efe86ce24cc5d83cdb82d0395))
- **wallet:** add util to convert metadatum into cip25-typed object ([2609d0d](https://github.com/input-output-hk/cardano-js-sdk/commit/2609d0d6c32f217110ccf85d6f09a92a9ee4e184))
- **wallet:** add Wallet.assets$ ([351b8e7](https://github.com/input-output-hk/cardano-js-sdk/commit/351b8e7a82ab925ec75c90edc293afc9ef9c47d4))
- **wallet:** add Wallet.delegation.delegatee$ ([83f4782](https://github.com/input-output-hk/cardano-js-sdk/commit/83f478237af0397a42b05d5e2ec6bb4e79b97f76))
- **wallet:** add Wallet.delegation.rewardsHistory$ ([8b8a355](https://github.com/input-output-hk/cardano-js-sdk/commit/8b8a355825ae00b7bd1c95a7e925b32066d22ded))
- **wallet:** add Wallet.genesisParameters$ ([381ef6a](https://github.com/input-output-hk/cardano-js-sdk/commit/381ef6ae03bbec0115e4c836f6d9a9da90fa5bb6))
- **wallet:** add Wallet.networkInfo$ ([7c46ce5](https://github.com/input-output-hk/cardano-js-sdk/commit/7c46ce5807c04f1dd4daa6d217d9699514b713d9))
- **wallet:** add Wallet.syncStatus$ ([06d8805](https://github.com/input-output-hk/cardano-js-sdk/commit/06d8805b6bb2da836c3455374a28d772b31774f0))
- **wallet:** add Wallet.timeSettings$ ([001d447](https://github.com/input-output-hk/cardano-js-sdk/commit/001d4477862bafa7435e96ef01c30edd1f72425e))
- **wallet:** add Wallet.validateTx ([a752da3](https://github.com/input-output-hk/cardano-js-sdk/commit/a752da3af5e82c9a1fe83701925bc4db44fe10cf))
- **wallet:** change Address type to include additional info ([7a5807e](https://github.com/input-output-hk/cardano-js-sdk/commit/7a5807ef944a8a8abc233ede68ed65002fa4cfb7))
- **wallet:** do not re-fetch transactions already in store ([39cd288](https://github.com/input-output-hk/cardano-js-sdk/commit/39cd288de3201d24d9bfeb509c24d45e7a26d3a4))
- **wallet:** enable LedgerKeyAgent for e2e ([1595cb2](https://github.com/input-output-hk/cardano-js-sdk/commit/1595cb20ce6ea734d5836266bed631ef2269e246))
- **wallet:** implement data signing ([ef0632f](https://github.com/input-output-hk/cardano-js-sdk/commit/ef0632f4f811158ef648883c92231f3919731512))
- **wallet:** implement generic PouchDB stores ([9e46fee](https://github.com/input-output-hk/cardano-js-sdk/commit/9e46fee1ca51df5e20985a44643adf99eb254d86))
- **wallet:** implement pouchdbWalletStores ([6f03cd3](https://github.com/input-output-hk/cardano-js-sdk/commit/6f03cd3428a5655319f032f3ba929d87ec183217))
- **wallet:** implement SingleAddressWallet storage and restoration ([6ff3dc7](https://github.com/input-output-hk/cardano-js-sdk/commit/6ff3dc799f28e773f1e1d75c3260200e6abe92d0))
- **wallet:** implement tx chaining (pending change outputs available as utxo) ([95c2671](https://github.com/input-output-hk/cardano-js-sdk/commit/95c2671055627a7c6cb334adc1a05b6b43bcb738))
- **wallet:** implemented cip30 callbacks ([da7aea2](https://github.com/input-output-hk/cardano-js-sdk/commit/da7aea24b40aea07205a2206f4f562c73a15b0e6))
- **wallet:** include TxSubmissionError in Wallet.transactions.outgoing.failed$ ([1c0a86d](https://github.com/input-output-hk/cardano-js-sdk/commit/1c0a86db0f425561467cd0f05d9b5ed80b90f431))
- **wallet:** introduce LedgerKeyAgent ([cb5cf81](https://github.com/input-output-hk/cardano-js-sdk/commit/cb5cf810a31e35c6db825022b89c576613955d8a))
- **wallet:** introduce TrezorKeyAgent ([beef3de](https://github.com/input-output-hk/cardano-js-sdk/commit/beef3dec60c55cfc3a657ea81221f8cadfdd9167))
- **wallet:** introduce TrezorKeyAgent transaction signing ([08402bd](https://github.com/input-output-hk/cardano-js-sdk/commit/08402bd9f1a9c4d984979040e73f19e287e37de3))
- **wallet:** ledger hardware wallet transaction signing ([9d7d2ff](https://github.com/input-output-hk/cardano-js-sdk/commit/9d7d2ff20e565a9b24dbb38b6b6f5d7129f687e1))
- **wallet:** observable interface & tx tracker ([dd1312b](https://github.com/input-output-hk/cardano-js-sdk/commit/dd1312b45b123f9f3fc7d52cae7f45e9205c406e))
- **wallet:** persistence types and in-memory implementation ([bd50044](https://github.com/input-output-hk/cardano-js-sdk/commit/bd50044b0dc669a1e4c7b15d322d90f2fc213d58))
- **wallet:** re-export rxjs utils to primisify observables ([34e877d](https://github.com/input-output-hk/cardano-js-sdk/commit/34e877dd96833d7374b00e3b0651a06d7836d8ed))
- **wallet:** support loading without KeyAgent being available ([5fb0b46](https://github.com/input-output-hk/cardano-js-sdk/commit/5fb0b46b1ad3d5fbfabe3ab54688dfd2aeb9f1a3))
- **wallet:** track known/derived addresses in KeyAgent ([9ac12c5](https://github.com/input-output-hk/cardano-js-sdk/commit/9ac12c5e391ad8e028f9e0b299b300ccdfcadd71))
- **wallet:** use block$ and epoch$ to reduce # of provider requests ([0568290](https://github.com/input-output-hk/cardano-js-sdk/commit/0568290debcb0f7561b0b955c7c0c7a6ed667ba8))
- **wallet:** use emip3 key encryption, refactor KeyManager to support hw wallets (wip) ([961ac26](https://github.com/input-output-hk/cardano-js-sdk/commit/961ac2682c436cf894b401f7d1939e26574f9a6f))

### Bug Fixes

- add missing UTXO_PROVIDER and WALLET_PROVIDER envs to blockfrost instatiation condition ([3773a69](https://github.com/input-output-hk/cardano-js-sdk/commit/3773a69a609a81f5c2541b2c2c21125ae6464cdf))
- **blockfrost:** interpret 404s in Blockfrost provider and optimise batching ([a795e4c](https://github.com/input-output-hk/cardano-js-sdk/commit/a795e4c70464ad0bbed714b69e826ee3f11be92c))
- check walletName in cip30 messages ([966b362](https://github.com/input-output-hk/cardano-js-sdk/commit/966b36233c7946ee13418100c7d96bf156e3c526))
- correct cip30 getUtxos return type ([9ddc5af](https://github.com/input-output-hk/cardano-js-sdk/commit/9ddc5afb57dc0d74b7c11a350c948c4fdd4b06e7))
- resolve issues preventing to make a delegation tx ([7429f46](https://github.com/input-output-hk/cardano-js-sdk/commit/7429f466763342b08b6bed44f23d3bf24dbf92f2))
- rm imports from @cardano-sdk/_/src/_ ([3fdead3](https://github.com/input-output-hk/cardano-js-sdk/commit/3fdead3ae381a3efb98299b9881c6a964461b7db))
- **test:** updated nft.test.ts ([8a71c1c](https://github.com/input-output-hk/cardano-js-sdk/commit/8a71c1c5b51a640d48394900bb7c7cd3e50259b5))
- validate the correct Ed25519KeyHash length (28 bytes) ([0e0b592](https://github.com/input-output-hk/cardano-js-sdk/commit/0e0b592e2b4b0689f592076cd79dfaac88b43c57))
- **wallet:** add communicationType arg to ledger getHidDeviceList ([7ea7f8c](https://github.com/input-output-hk/cardano-js-sdk/commit/7ea7f8c2f755f2bf7ce4e24c7aebea5ca8cfe955))
- **wallet:** add missing argument in ObservableWallet interface ([e4fefec](https://github.com/input-output-hk/cardano-js-sdk/commit/e4fefec9584a6ed1042c69b80a4d4fe74425f401))
- **wallet:** add missing cleanup for SingleAddressWallet ([083fec9](https://github.com/input-output-hk/cardano-js-sdk/commit/083fec965814f02fefb73bf96d668a7cd024cea2))
- **wallet:** added utxoProvider to e2e tests ([1277aae](https://github.com/input-output-hk/cardano-js-sdk/commit/1277aae60c6674044c4e0befb6a5542a1c85dbdd))
- **wallet:** always initialize chacha with Buffer (for polyfilled browser usage) ([cdb5a3a](https://github.com/input-output-hk/cardano-js-sdk/commit/cdb5a3a057798c3edb0226a5be01fbc0996726c9))
- **wallet:** cache cachedGetPassword calls to getPassword instead of result ([fa67b9e](https://github.com/input-output-hk/cardano-js-sdk/commit/fa67b9e6ddcba788c3e13f850f7d31f6b1bba7d9))
- **wallet:** change Wallet.assets$ behavior to not emit empty obj while loading ([e9cad4a](https://github.com/input-output-hk/cardano-js-sdk/commit/e9cad4a7dc2d2822a697c26834b32484a7a41158))
- **wallet:** consume chained tx outputs ([f051351](https://github.com/input-output-hk/cardano-js-sdk/commit/f05135197f11de9bedf45944d5eeff7c7ed58531))
- **wallet:** correct pouchdb stores implementation ([154cba7](https://github.com/input-output-hk/cardano-js-sdk/commit/154cba7bc0cd62d18bc21d054b62a352f4519e5a))
- **wallet:** correctly load upcoming epoch delegatee ([24001f6](https://github.com/input-output-hk/cardano-js-sdk/commit/24001f65443eff346d61853b5c391924b8da9b5f))
- **wallet:** delegation changes reflect at end of cuurrent epoch + 2 ([ee0ee2b](https://github.com/input-output-hk/cardano-js-sdk/commit/ee0ee2bc38ce0bac0970848d07364f981bbc5dfd))
- **wallet:** do not decrypt private key on InMemoryKeyAgent restoration ([1316d4b](https://github.com/input-output-hk/cardano-js-sdk/commit/1316d4b03ee857cc1db9487a6214c339c3d3687d))
- **wallet:** do not emit provider data until it changes ([5f74cdd](https://github.com/input-output-hk/cardano-js-sdk/commit/5f74cdd30a66027173ba094e471ed59b2c627ffc))
- **wallet:** do not mutate previously emitted inFlight transactions ([dcc5dce](https://github.com/input-output-hk/cardano-js-sdk/commit/dcc5dcecef1b06db85641a9dc57f1e03bed612af))
- **wallet:** do not re-derive addresses with same type and index ([11947af](https://github.com/input-output-hk/cardano-js-sdk/commit/11947af71a2d02814f8f156e6d17359e8b8365a3))
- **wallet:** don't classify transaction as incoming if it has change output, add some tests ([64b363f](https://github.com/input-output-hk/cardano-js-sdk/commit/64b363f540860de9caa303ca880a7c3ad9479ce2))
- **wallet:** emit ObservableWallet.addresses$ only when it changes ([c6ae4ae](https://github.com/input-output-hk/cardano-js-sdk/commit/c6ae4aefe6c09312f23050bdae02ec95309ebb61))
- **wallet:** ensure transactions are loaded once at any time ([d367eb7](https://github.com/input-output-hk/cardano-js-sdk/commit/d367eb7c0db42ceef1f581e31b95f6577eafbca6))
- **wallet:** filter own delegation certificates when detecting new delegations ([52d22e2](https://github.com/input-output-hk/cardano-js-sdk/commit/52d22e2767b3bbce0c7ec5293ecc621251c59df4))
- **wallet:** fix cachedGetPassword timeout type ([1e9df2f](https://github.com/input-output-hk/cardano-js-sdk/commit/1e9df2f6a04b813da5e6a54a418623a5d4091622))
- **wallet:** fix emip3decrypt to work in browsers (Uint8Array incompatibility) ([dda9e58](https://github.com/input-output-hk/cardano-js-sdk/commit/dda9e58a9b1342d5e27d242e95a92101f107b69e))
- **wallet:** fix hardware test setup - webextension-mock ([ac234bf](https://github.com/input-output-hk/cardano-js-sdk/commit/ac234bf88e28f9679626e57a0462d53fc83bd38e))
- **wallet:** fix ledger tx signing with acc index greater than [#0](https://github.com/input-output-hk/cardano-js-sdk/issues/0) ([c7286e5](https://github.com/input-output-hk/cardano-js-sdk/commit/c7286e54788a4175f3df6c28d34b781e7af5934c))
- **wallet:** forward extraData in TrackedAssetProvider.getAsset ([f877396](https://github.com/input-output-hk/cardano-js-sdk/commit/f8773965b437f8506a30129d97e9ffb33477fa67))
- **wallet:** handle failures when tracking requests for Wallet.syncStatus$ ([6d5b1fd](https://github.com/input-output-hk/cardano-js-sdk/commit/6d5b1fda27bee505a696b5760567dc7d362ab672))
- **wallet:** map doc to serializable in PouchdbCollectionStore.setAll ([0c52c17](https://github.com/input-output-hk/cardano-js-sdk/commit/0c52c177507e7f6b10b7486ba06bb82db7f6e3aa))
- **wallet:** omit rewards for UtxoTracker query, add e2e balance test ([a54f9e0](https://github.com/input-output-hk/cardano-js-sdk/commit/a54f9e05a4fd47b9fde0263316050c92e37bd7c6))
- **wallet:** optimize polling by not making some redundant requests ([213f1aa](https://github.com/input-output-hk/cardano-js-sdk/commit/213f1aaee3355cc3dd7a745f6e3b2873f030553a))
- **wallet:** overwrite existing pouchdb docs ([32b743a](https://github.com/input-output-hk/cardano-js-sdk/commit/32b743a2f8783e250e01fb9438c8a0fb4d81c47c))
- **wallet:** pass through pouchdb stores logger ([68ec0a1](https://github.com/input-output-hk/cardano-js-sdk/commit/68ec0a1cae6026ac8f043b468eae7c8c30f641da))
- **wallet:** pouchdb stores support for objects with keys starting with \_ ([0ed546a](https://github.com/input-output-hk/cardano-js-sdk/commit/0ed546a3919bf9ec78644a147002d16a9d5ace0d))
- **wallet:** queue pouchdb writes ([36ed98d](https://github.com/input-output-hk/cardano-js-sdk/commit/36ed98dc40e8a6ce8a6a85e7311ec1e68836d4f0))
- **wallet:** set TrackedAssetProvider as initialized ([473a467](https://github.com/input-output-hk/cardano-js-sdk/commit/473a467d663ccb16ea99b0de578e9c0e5e975a9f))
- **wallet:** store keeps track of in flight transactions ([7b55b8e](https://github.com/input-output-hk/cardano-js-sdk/commit/7b55b8effe5480bdc7212cc072de42bfa3066613))
- **wallet:** stub sign for input selection constraints ([edbc6d4](https://github.com/input-output-hk/cardano-js-sdk/commit/edbc6d499efc2c61f6925e09288ded0d75aaacfc))
- **wallet:** subscribing after initial fetch of tip will no longer wait for new block to emit ([c00d9a7](https://github.com/input-output-hk/cardano-js-sdk/commit/c00d9a778dcef073770e9976f030ccd012a1cd8e))
- **wallet:** subscribing to confirmed$ and failed$ after tx submission ([1e651bc](https://github.com/input-output-hk/cardano-js-sdk/commit/1e651bcc256f2ee43866ccc42b968055fe920f30))
- **wallet:** support TrackerSubject source observables that instantly complete ([811e4c3](https://github.com/input-output-hk/cardano-js-sdk/commit/811e4c3e392c05b34b02bd5849ff288adea3973a))
- **wallet:** track missing providers ([d441f92](https://github.com/input-output-hk/cardano-js-sdk/commit/d441f9210d6676b98b735044d71a011043a9569d))
- **wallet:** use custom serializableObj type key option ([e531fc2](https://github.com/input-output-hk/cardano-js-sdk/commit/e531fc2f26d7574a4a6bfcd88b2b4f6d0642bd78))
- **wallet:** use keyManager.rewardAccount where bech32 stake address is expected ([f769594](https://github.com/input-output-hk/cardano-js-sdk/commit/f7695945c834ceee9859a5069dcd543616c3ce35))

### Performance Improvements

- **wallet:** share submitting$ subscription within TransactionsTracker ([ebc446b](https://github.com/input-output-hk/cardano-js-sdk/commit/ebc446b6d10344153639ce97ede11ee3ef49fa98))

### Code Refactoring

- change MetadatumMap type to allow any metadatum as key ([48c33e5](https://github.com/input-output-hk/cardano-js-sdk/commit/48c33e552406cce35ea19d720451a1ba641ff51b))
- delete nftMetadataProvider and remove it from AssetTracker ([2904cc3](https://github.com/input-output-hk/cardano-js-sdk/commit/2904cc32a60734e2972425c96c67a2a590c7d2cb))
- extract tx submit into own provider ([1d7ac73](https://github.com/input-output-hk/cardano-js-sdk/commit/1d7ac7393fbd669f08b516c4067883d982f2e711))
- hoist cip30 mapping of ObservableWallet to cip30 pkg ([7076fc2](https://github.com/input-output-hk/cardano-js-sdk/commit/7076fc2ae987948e2c52b696666842ddb67af5d7))
- improve ObservableWallet.balance interface ([b8371f9](https://github.com/input-output-hk/cardano-js-sdk/commit/b8371f97e151c2e9cb18e0ac431e9703fe490d26))
- make blockfrost API instance a parameter of the providers ([52b2bda](https://github.com/input-output-hk/cardano-js-sdk/commit/52b2bda4574cb9c7cacf2e3e02ced5ada2c58dd3))
- makeTxIn.address required, add NewTxIn that has no address ([83cd354](https://github.com/input-output-hk/cardano-js-sdk/commit/83cd3546840f936af5e0cde0e43d54f924602400))
- move asset info type from Cardano to Asset ([212b670](https://github.com/input-output-hk/cardano-js-sdk/commit/212b67041598cbcc2c2cf4f5678928943de7aa29))
- move stakePoolStats from wallet provider to stake pool provider ([52d71a7](https://github.com/input-output-hk/cardano-js-sdk/commit/52d71a70700b05902cca6205fe01a63f811ba5af))
- remove TimeSettingsProvider and NetworkInfo.currentEpoch ([4a8f72f](https://github.com/input-output-hk/cardano-js-sdk/commit/4a8f72f57f699f7c0bf4a9a4b742fc0a3e4aa8ce))
- remove transactions and blocks methods from blockfrost wallet provider ([e4de136](https://github.com/input-output-hk/cardano-js-sdk/commit/e4de13650f0d387b8e7126077e8721f353af8c85))
- rename `StakePoolSearchProvider` to `StakePoolProvider` ([b432103](https://github.com/input-output-hk/cardano-js-sdk/commit/b43210348da7914664733f85f8be8999271a8667))
- rename some WalletProvider functions ([72ad875](https://github.com/input-output-hk/cardano-js-sdk/commit/72ad875ca8e9c3b65c23794a95ca4110cf34a034))
- rename uiWallet->webExtensionWalletClient ([c4ebdea](https://github.com/input-output-hk/cardano-js-sdk/commit/c4ebdeab881be7f6cfd0ff3d3428bcb8e04529a7))
- revert 7076fc2ae987948e2c52b696666842ddb67af5d7 ([b30183e](https://github.com/input-output-hk/cardano-js-sdk/commit/b30183e4852606e38c1d5b55dd9dc51ed138fc29))
- rm ObservableWallet.networkId (to be resolved via networkInfo$) ([72be7d7](https://github.com/input-output-hk/cardano-js-sdk/commit/72be7d7fc9dfd1bd12593ab572d9b6734d789822))
- split up WalletProvider.utxoDelegationAndRewards ([18f5a57](https://github.com/input-output-hk/cardano-js-sdk/commit/18f5a571cb9d581007182b39d2c68b38491c70e6))
- **wallet:** changes transactions.history.all$ type from DirectionalTransaction to TxAlonzo ([256a034](https://github.com/input-output-hk/cardano-js-sdk/commit/256a0344971f5366bd2659b5317267b08a714fb9))
- **wallet:** clean up ObservableWallet interface so it can be easily exposed remotely ([249b5b0](https://github.com/input-output-hk/cardano-js-sdk/commit/249b5b0ac12a0c8d8dbca00e11f9b288ba7aaf0a))
- **wallet:** convert Wallet.syncStatus$ into an object ([7662e2b](https://github.com/input-output-hk/cardano-js-sdk/commit/7662e2b71dc1e47b0b1966113ce5bef0d293b92c))
- **wallet:** getExtendedAccountPublicKey -> extendedAccountPublicKey ([8cbe1cc](https://github.com/input-output-hk/cardano-js-sdk/commit/8cbe1cc1c71bd2c93eae7857cfbd41c35531f56b))
- **wallet:** move cachedGetPassword under KeyManagement.util ([e34c0a4](https://github.com/input-output-hk/cardano-js-sdk/commit/e34c0a49a86ffff15afd135820a129767681b24d))
- **wallet:** move output validation under Wallet.util ([d2b2330](https://github.com/input-output-hk/cardano-js-sdk/commit/d2b2330e2bcea0bc3adc64c12d21da3fe7b644d4))
- **wallet:** observable wallet supports only async properties ([f5f3526](https://github.com/input-output-hk/cardano-js-sdk/commit/f5f3526c1662765f48695b54984305e09c8d28b8))
- **wallet:** remove SingleAddressWallet.address ([4344a76](https://github.com/input-output-hk/cardano-js-sdk/commit/4344a7662a59a4b16edaae0a63b13856dea5a863))
- **wallet:** removes history all$, outgoing$ and incoming$ from transactions tracker ([9d400d2](https://github.com/input-output-hk/cardano-js-sdk/commit/9d400d2b14b2c19bb86402a504f5701446d0a680))
- **wallet:** rename KeyManagement types, improve test coverage ([2742eca](https://github.com/input-output-hk/cardano-js-sdk/commit/2742ecab0643fa1badf1e7df2dfede2617c60635))
- **wallet:** rename Wallet interface to ObservableWallet ([555e56f](https://github.com/input-output-hk/cardano-js-sdk/commit/555e56f78010e68f98eafa2cadf6972437f6cbbd))
- **wallet:** replace SingleAddressWallet KeyAgent dep with AsyncKeyAgent ([5517d81](https://github.com/input-output-hk/cardano-js-sdk/commit/5517d81eb7294cdbfa4cc8cc6f8d5fcebf4660e6))
- **wallet:** rm obsolete cip30.initialize ([5deb87a](https://github.com/input-output-hk/cardano-js-sdk/commit/5deb87a4de5529b0a913e24f2ca2d5df3f492576))
- **wallet:** update stores interface to complete instead of emitting null/empty result ([444ff1d](https://github.com/input-output-hk/cardano-js-sdk/commit/444ff1d4da4493e633be53d5f0d3b4791893b91a))
- **wallet:** use HexBlob type from core ([662656f](https://github.com/input-output-hk/cardano-js-sdk/commit/662656f96b2bb1161673d4ec0ae060cdfe5a1dec))

### 0.1.5 (2021-10-27)

### Features

- add WalletProvider.transactionDetails, add address to TxIn ([889a39b](https://github.com/input-output-hk/cardano-js-sdk/commit/889a39b1feb988144dd2249c6c47f91e8096fd48))
- **cardano-graphql:** implement CardanoGraphQLStakePoolSearchProvider (wip) ([80deda6](https://github.com/input-output-hk/cardano-js-sdk/commit/80deda6963a0c07b2f0b24a0a5465c488305d83c))
- **wallet:** add balance interface ([48a820f](https://github.com/input-output-hk/cardano-js-sdk/commit/48a820f57d50ec320d2f80ce236371e95ae5aeff))
- **wallet:** add SingleAddressWallet.balance ([01cda8f](https://github.com/input-output-hk/cardano-js-sdk/commit/01cda8fa6c6ba611a571cc5184a2cb8684f3941c))
- **wallet:** add support for transaction certs and withdrawals ([d8842b0](https://github.com/input-output-hk/cardano-js-sdk/commit/d8842b0ff2f64b0f6899113d4d61d2aefda569ad))
- **wallet:** add utility to create withdrawal ([c49f782](https://github.com/input-output-hk/cardano-js-sdk/commit/c49f7822b58c25a6d7d928f19790d4e45730ef60))
- **wallet:** add UtxoRepository.availableRewards and fix availableUtxo sync ([4f9b13f](https://github.com/input-output-hk/cardano-js-sdk/commit/4f9b13fe043d2c700db4f454bb6454dd4e5e62f4))
- **wallet:** add UtxoRepositoryEvent.Changed ([42e0753](https://github.com/input-output-hk/cardano-js-sdk/commit/42e07535fd6c3f4d1adbe38ee41edfc04a13865c))
- **wallet:** implement BalanceTracker, refactor tests: move all test mocks under ./mocks ([28746ca](https://github.com/input-output-hk/cardano-js-sdk/commit/28746ca214a485bbceb0aae932e6ce3e156eb849))
- **wallet:** implement UTxO lock/unlock functionality, fix utxo sync ([3b6a935](https://github.com/input-output-hk/cardano-js-sdk/commit/3b6a935a440beb961ea6b555bce753ed05a92cdd))
- **wallet:** utilities to create pool certificates, pass implicit coin to input selection ([b5bfbc8](https://github.com/input-output-hk/cardano-js-sdk/commit/b5bfbc8dd850bae20f104df1f5d440dd3940ebb6))

### Bug Fixes

- **wallet:** lock utxo right after submitting, run input selection with availableUtxo set ([0008368](https://github.com/input-output-hk/cardano-js-sdk/commit/0008368293f9dac705fdcbd7e240e0e88046f7e8))
- **wallet:** make txTracker not optional to ensure it's the same as UtxoRepository uses ([653b8d9](https://github.com/input-output-hk/cardano-js-sdk/commit/653b8d90409e79e6624f01368ebb73f61aac1aeb))

### 0.1.3 (2021-10-05)

### Features

- **wallet:** add SingleAddressWallet.name ([7eb4e78](https://github.com/input-output-hk/cardano-js-sdk/commit/7eb4e78cb557c92da038d91b3e4507d873d46818))

### 0.1.2 (2021-09-30)

### Bug Fixes

- add missing dependencies ([2d3bfbc](https://github.com/input-output-hk/cardano-js-sdk/commit/2d3bfbc3f8d5fdce3be64835c57304b540e05811))

### 0.1.1 (2021-09-30)

### Features

- add `deriveAddress` and `stakeKey` to the `KeyManager` ([b5ae13b](https://github.com/input-output-hk/cardano-js-sdk/commit/b5ae13b8472519b5a1dde5d9cfa0c64ad7638d07))
- add CardanoProvider.networkInfo ([1596ac2](https://github.com/input-output-hk/cardano-js-sdk/commit/1596ac27b3fa3494f784db37831f85e06a8e0e03))
- create in-memory-key-manager package ([a819e5e](https://github.com/input-output-hk/cardano-js-sdk/commit/a819e5e2161a0cd6bd45c61825957efa810530d3))
- **wallet:** add SingleAddressWallet ([5021dde](https://github.com/input-output-hk/cardano-js-sdk/commit/5021dde20e3dbf08c2fa5dff6f244400a9e7dfa3))
- **wallet:** add UTxO repository and in-memory implementation ([1dc98c3](https://github.com/input-output-hk/cardano-js-sdk/commit/1dc98c3da4660b7f1fa58475948f8cf0f98566e3))
- **wallet:** createTransactionInternals ([1aa7032](https://github.com/input-output-hk/cardano-js-sdk/commit/1aa7032421940ef85aa9eb3d0251a79caaaa19d8))

### Bug Fixes

- add missing yarn script, and rename ([840135f](https://github.com/input-output-hk/cardano-js-sdk/commit/840135f7d100c9a00ff410147758ee7d02112897))
- use isomorphic CSL in InMemoryKeyManager ([7db40cb](https://github.com/input-output-hk/cardano-js-sdk/commit/7db40cb9664659f0c123dfe4da40d06942860483))
- **wallet:** add tx outputs for change, refactor to use update cip2 interface ([3f07d5c](https://github.com/input-output-hk/cardano-js-sdk/commit/3f07d5c7c716ce3e928596c4736be59ca55d4b11))
