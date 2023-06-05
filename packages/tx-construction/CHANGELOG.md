# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

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
