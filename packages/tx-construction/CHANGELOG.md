# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.10.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.9.4...@cardano-sdk/tx-construction@0.10.0) (2023-08-11)

### ⚠ BREAKING CHANGES

* the serialization classes in Core package are now exported under the alias Serialization

### Code Refactoring

* the serialization classes in Core package are now exported under the alias Serialization ([06f78bb](https://github.com/input-output-hk/cardano-js-sdk/commit/06f78bb98943c306572c32f5817425ef1ff6fc51))

## [0.9.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.9.3...@cardano-sdk/tx-construction@0.9.4) (2023-07-31)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.9.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.9.2...@cardano-sdk/tx-construction@0.9.3) (2023-07-26)

### Bug Fixes

* **tx-construction:** removed resolved handle from addOutput in TxBuilder ([b185932](https://github.com/input-output-hk/cardano-js-sdk/commit/b185932ffb591277dafde20f05c93ee6e8674358))

## [0.9.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.9.1...@cardano-sdk/tx-construction@0.9.2) (2023-07-13)

### Bug Fixes

* **tx-construction:** rm redundant circular dependency on 'wallet' package ([b048475](https://github.com/input-output-hk/cardano-js-sdk/commit/b0484758bd1e1feee9750b86e5fc777f78494e86))
* wallet finalizeTx and CIP30 requiresForeignSignatures now wait for at least one known address ([b5fde00](https://github.com/input-output-hk/cardano-js-sdk/commit/b5fde0038dde4082d3cd5eac3bbb8141733ec5b6))

## [0.9.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.9.0...@cardano-sdk/tx-construction@0.9.1) (2023-07-05)

### Bug Fixes

* **tx-construction:** builder now awaits for non-empty knownAddresses$ before building the tx ([e8f4296](https://github.com/input-output-hk/cardano-js-sdk/commit/e8f42960fe020cca35b54b4d3eedc35280d28049))

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.8.4...@cardano-sdk/tx-construction@0.9.0) (2023-07-04)

### ⚠ BREAKING CHANGES

* added change address resolver to the round robin input selector

### Features

* added change address resolver to the round robin input selector ([ef654ca](https://github.com/input-output-hk/cardano-js-sdk/commit/ef654ca7a7c3217b68360e1d4bee3296e5fc4f0e))

## [0.8.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.8.3...@cardano-sdk/tx-construction@0.8.4) (2023-07-03)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.8.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.8.2...@cardano-sdk/tx-construction@0.8.3) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.8.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.8.1...@cardano-sdk/tx-construction@0.8.2) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.8.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.8.0...@cardano-sdk/tx-construction@0.8.1) (2023-06-28)

### Features

* adds cardanoAddress type in HandleResolution interface ([2ee31c9](https://github.com/input-output-hk/cardano-js-sdk/commit/2ee31c9f0b61fc5e67385128448225d2d1d85617))

### Bug Fixes

* **tx-construction:** wait for new stakeKeys in rewardAccounts ([a74b665](https://github.com/input-output-hk/cardano-js-sdk/commit/a74b66505e19681d21d547e6418f0980b112b070))

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.7.2...@cardano-sdk/tx-construction@0.8.0) (2023-06-23)

### ⚠ BREAKING CHANGES

* txBuilder delegate is replaced by delegatePortfolio.
* TxBuilderProviders.rewardAccounts expects RewardAccountWithPoolId type,
  instead of Omit<RewardAccount, 'delegatee'>

### Features

* remove txBuilder.delegate method ([f21c93b](https://github.com/input-output-hk/cardano-js-sdk/commit/f21c93b251f1bd67f47edd488d9df47c2abf3e0c))
* **tx-construction:** use GreedyInputSelection for multi delegation ([5462936](https://github.com/input-output-hk/cardano-js-sdk/commit/54629367b14fe26f13f9c17483bdf98c451b8d89))
* txBuilder delegatePortfolio ([ec0860e](https://github.com/input-output-hk/cardano-js-sdk/commit/ec0860e37835edbce3c911d6fe65c21b73683de7))

## [0.7.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.7.1...@cardano-sdk/tx-construction@0.7.2) (2023-06-20)

### Features

* new pool delegation and stake registration factory methods added to core package ([82d95af](https://github.com/input-output-hk/cardano-js-sdk/commit/82d95af3f68eb06cb58bd2bec5209d93c2aa6c34))

## [0.7.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.7.0...@cardano-sdk/tx-construction@0.7.1) (2023-06-13)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.6.0...@cardano-sdk/tx-construction@0.7.0) (2023-06-12)

### ⚠ BREAKING CHANGES

* SignedTx.ctx now renamed to context

### Features

* add context to txSubmit ([57589ec](https://github.com/input-output-hk/cardano-js-sdk/commit/57589ecd3120573a0cea7e718291454e9b6f9f3b))

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.5.3...@cardano-sdk/tx-construction@0.6.0) (2023-06-06)

### ⚠ BREAKING CHANGES

* input selectors now return a lis of UTXOs instead of values as change

### Features

* input selectors now return a lis of UTXOs instead of values as change ([954745c](https://github.com/input-output-hk/cardano-js-sdk/commit/954745c03b6a2ebdd16797917e2d85b7cb639789))

## [0.5.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.5.2...@cardano-sdk/tx-construction@0.5.3) (2023-06-05)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.5.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.5.1...@cardano-sdk/tx-construction@0.5.2) (2023-06-01)

### Features

* add HandleProvider interface and handle support implementation to TxBuilder ([f209095](https://github.com/input-output-hk/cardano-js-sdk/commit/f2090952c8a0512fc589674b876f3a27be403140))

## [0.5.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.5.0...@cardano-sdk/tx-construction@0.5.1) (2023-05-24)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.4.0...@cardano-sdk/tx-construction@0.5.0) (2023-05-22)

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

### Features

* generic tx-builder ([aa4a539](https://github.com/input-output-hk/cardano-js-sdk/commit/aa4a539d6a5ddd75120450e02afeeba9bed6a527))
* **util-dev:** add stubProviders ([6d5d99c](https://github.com/input-output-hk/cardano-js-sdk/commit/6d5d99c80894a4b126647272f490d9e2c472d818))

### Code Refactoring

* move tx build utils from wallet to tx-construction ([48072ce](https://github.com/input-output-hk/cardano-js-sdk/commit/48072ce35968820b10fcf0b9ed4441f00ac6fb8b))

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.3.0...@cardano-sdk/tx-construction@0.4.0) (2023-05-02)

### ⚠ BREAKING CHANGES

- - auxiliaryDataHash is now included in the TxBody core type.

* networkId is now included in the TxBody core type.
* auxiliaryData no longer contains the optional hash field.
* auxiliaryData no longer contains the optional body field.

### Features

- added new Transaction class that can convert between CBOR and the Core Tx type ([cc9a80c](https://github.com/input-output-hk/cardano-js-sdk/commit/cc9a80c17f1c0f46124b0c04c597a7ff96e517d3))
- transaction body core type now includes the auxiliaryDataHash and networkId fields ([8b92b01](https://github.com/input-output-hk/cardano-js-sdk/commit/8b92b0190083a2b956ae1e188121414428f6663b))

### Bug Fixes

- circular deps check in CI ([070f5e9](https://github.com/input-output-hk/cardano-js-sdk/commit/070f5e9f199c8a3b823f80aa98b35a4df7dbe532))

## [0.3.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.2.1...@cardano-sdk/tx-construction@0.3.0) (2023-03-13)

### ⚠ BREAKING CHANGES

- core type for address string reprensetation 'Address' renamed to PaymentAddress

### Code Refactoring

- core type for address string reprensetation 'Address' renamed to PaymentAddress ([4287463](https://github.com/input-output-hk/cardano-js-sdk/commit/42874633de6069510efdc57323f61140d22ed203))

## [0.2.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.2.0...@cardano-sdk/tx-construction@0.2.1) (2023-03-01)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## 0.2.0 (2023-02-17)

### ⚠ BREAKING CHANGES

- - The default input selection constraints were moved from input-selection package to tx-construction package.

### Features

- new tx construction package added ([45c0c75](https://github.com/input-output-hk/cardano-js-sdk/commit/45c0c75b20f766a069af45cec636a1756a3fc0da))
