# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.26.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.26.2...@cardano-sdk/tx-construction@0.26.3) (2025-02-19)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.26.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.26.1...@cardano-sdk/tx-construction@0.26.2) (2025-02-06)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.26.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.26.0...@cardano-sdk/tx-construction@0.26.1) (2025-01-31)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.26.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.25.0...@cardano-sdk/tx-construction@0.26.0) (2025-01-20)

### ⚠ BREAKING CHANGES

* correct return type of RewardAccount.toHash

### Bug Fixes

* correct return type of RewardAccount.toHash ([67765f1](https://github.com/input-output-hk/cardano-js-sdk/commit/67765f1dc9e9f770e06aee60afe11a21122c8f99))

## [0.25.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.24.4...@cardano-sdk/tx-construction@0.25.0) (2025-01-17)

### ⚠ BREAKING CHANGES

* minFee now takes resolvedInputs and ProtocolParametersForInputSelection as arguments
* The package now exports an async `ready` function that must be called before any of crypto related functions can be called
- Bip32PrivateKe async functions are all now sync
- Bip32PublicKey class async functions are all now sync
- Ed25519PrivateKey class async functions are all now sync
- Ed25519PublicKey class async functions are all now sync
- Bip32Ed25519 interface async functions are all now sync
- SodiumBip32Ed25519 cosntructor is now private
- SodiumBip32Ed25519 now has a new async factory method create

### Features

* fee calculation now takes into account reference script size ([33527d5](https://github.com/input-output-hk/cardano-js-sdk/commit/33527d52479b7b520c7bee1f6d9d6a59d5effb71))
* remove async from crypto API ([91b7fa2](https://github.com/input-output-hk/cardano-js-sdk/commit/91b7fa29961cfb11fe7270aef259be19ac215f08))

## [0.24.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.24.3...@cardano-sdk/tx-construction@0.24.4) (2025-01-09)

### Bug Fixes

* **tx-constructor:** txBuilder ctor must be sync to be used with remoteApi ([7772c6c](https://github.com/input-output-hk/cardano-js-sdk/commit/7772c6c9c03eb9729335a1450eaa5e133733c2c2))

## [0.24.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.24.2...@cardano-sdk/tx-construction@0.24.3) (2025-01-09)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.24.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.24.1...@cardano-sdk/tx-construction@0.24.2) (2025-01-02)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.24.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.24.0...@cardano-sdk/tx-construction@0.24.1) (2025-01-02)

### Features

* **tx-construction:** throw when deregistering reward accounts with rewards without drep ([c594937](https://github.com/input-output-hk/cardano-js-sdk/commit/c59493727cd05d0343e6429d00604440b1a3b493))

## [0.24.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.23.0...@cardano-sdk/tx-construction@0.24.0) (2024-12-20)

### ⚠ BREAKING CHANGES

* rename poll props 'provider' to 'sample'

### Code Refactoring

* rename 'coldObservableProvider' util to 'poll' ([9bad2df](https://github.com/input-output-hk/cardano-js-sdk/commit/9bad2df58d48e920881da68adf51c20ee1d7c886))

## [0.23.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.22.0...@cardano-sdk/tx-construction@0.23.0) (2024-12-05)

### ⚠ BREAKING CHANGES

* coldObservableProvider logs errors

### Features

* coldObservableProvider logs errors ([b2caa15](https://github.com/input-output-hk/cardano-js-sdk/commit/b2caa157416747d0e7ad28c941d31dbf55abad78))

## [0.22.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.14...@cardano-sdk/tx-construction@0.22.0) (2024-12-02)

### ⚠ BREAKING CHANGES

* **wallet:** DRepDelegatee type has changed to include DrepInfo
- createRewardsAccountTracker now requires a drepInfo$ dependency.
- BaseWallet requires a DrepProvider as a dependency

### Features

* **wallet:** implement DrepStatusTracker ([6362d83](https://github.com/input-output-hk/cardano-js-sdk/commit/6362d834feda307c4a9eddf32c6069ef66945d92))

## [0.21.14](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.13...@cardano-sdk/tx-construction@0.21.14) (2024-12-02)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.21.13](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.12...@cardano-sdk/tx-construction@0.21.13) (2024-11-23)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.21.12](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.11...@cardano-sdk/tx-construction@0.21.12) (2024-11-20)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.21.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.10...@cardano-sdk/tx-construction@0.21.11) (2024-11-18)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.21.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.9...@cardano-sdk/tx-construction@0.21.10) (2024-10-25)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.21.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.8...@cardano-sdk/tx-construction@0.21.9) (2024-10-11)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.21.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.7...@cardano-sdk/tx-construction@0.21.8) (2024-10-06)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.21.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.6...@cardano-sdk/tx-construction@0.21.7) (2024-10-03)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.21.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.5...@cardano-sdk/tx-construction@0.21.6) (2024-09-27)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.21.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.4...@cardano-sdk/tx-construction@0.21.5) (2024-09-25)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.21.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.3...@cardano-sdk/tx-construction@0.21.4) (2024-09-12)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.21.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.2...@cardano-sdk/tx-construction@0.21.3) (2024-09-10)

### Features

* **tx-construction:** txBuilder skip withdrawals for reward accounts without dRep delegation if major PV is less than 10 ([aad7339](https://github.com/input-output-hk/cardano-js-sdk/commit/aad73398d43295f3a51b39e82a14512c5ac3be1e))

## [0.21.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.1...@cardano-sdk/tx-construction@0.21.2) (2024-09-06)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.21.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.21.0...@cardano-sdk/tx-construction@0.21.1) (2024-09-04)

### Bug Fixes

* update hashScriptData for conway ([d7275ee](https://github.com/input-output-hk/cardano-js-sdk/commit/d7275ee77556b5dcebf9042ea49d828b58116902))

## [0.21.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.20.3...@cardano-sdk/tx-construction@0.21.0) (2024-08-23)

### ⚠ BREAKING CHANGES

* export CIP-20 helper functions as CIP20 module
* move CIP-20 utils to tx-construction package

### Code Refactoring

* export CIP-20 helper functions as CIP20 module ([09aeb2d](https://github.com/input-output-hk/cardano-js-sdk/commit/09aeb2d3603b48dc097466e1097d5cd8bcd86340))
* move CIP-20 utils to tx-construction package ([33422e4](https://github.com/input-output-hk/cardano-js-sdk/commit/33422e423f0530b066545120a16b247938a1884b))

## [0.20.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.20.2...@cardano-sdk/tx-construction@0.20.3) (2024-08-22)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.20.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.20.1...@cardano-sdk/tx-construction@0.20.2) (2024-08-21)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.20.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.20.0...@cardano-sdk/tx-construction@0.20.1) (2024-08-20)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.20.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.19.10...@cardano-sdk/tx-construction@0.20.0) (2024-08-07)

### ⚠ BREAKING CHANGES

* remove Cardano.TransactionId.fromTxBodyCbor
- hoist getAssetNameAsText util to Asset.util namespace
- hoist TxCBOR and TxBodyCBOR under Serialization namespace

### Code Refactoring

* resolve circular references in core package ([87aa26f](https://github.com/input-output-hk/cardano-js-sdk/commit/87aa26f2a2f50df0c7a72aaf4f746df2a466adfb))

## [0.19.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.19.9...@cardano-sdk/tx-construction@0.19.10) (2024-08-01)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.19.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.19.8...@cardano-sdk/tx-construction@0.19.9) (2024-07-31)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.19.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.19.7...@cardano-sdk/tx-construction@0.19.8) (2024-07-25)

### Bug Fixes

* use drep key hash in stubSignTransaction ([af30b6b](https://github.com/input-output-hk/cardano-js-sdk/commit/af30b6b95f57a453080c7d2594df1e7bd7c6a6c9))

## [0.19.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.19.6...@cardano-sdk/tx-construction@0.19.7) (2024-07-22)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.19.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.19.5...@cardano-sdk/tx-construction@0.19.6) (2024-07-11)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.19.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.19.4...@cardano-sdk/tx-construction@0.19.5) (2024-07-10)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.19.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.19.3...@cardano-sdk/tx-construction@0.19.4) (2024-06-26)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.19.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.19.2...@cardano-sdk/tx-construction@0.19.3) (2024-06-20)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.19.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.19.1...@cardano-sdk/tx-construction@0.19.2) (2024-06-17)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.19.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.19.0...@cardano-sdk/tx-construction@0.19.1) (2024-06-14)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.19.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.18.7...@cardano-sdk/tx-construction@0.19.0) (2024-06-05)

### ⚠ BREAKING CHANGES

* Input selectors now return selected inputs in lexicographic order
- new input selection parameter added 'mustSpendUtxo', which force such UTXOs to be part of the selection
- txBuilder now takes a new optional dependency TxEvaluator
- added to the txBuilder the following new methods 'addInput', 'addReferenceInput' and 'addDatum'
- the txBuilder now supports spending from script inputs
- the txBuilder now resolve unknown inputs from on-chain data
- outputBuilder 'datum' function can now take PlutusData as inline datum
- added to the OutputBuilder a new method 'scriptReference'
- walletUtilContext now requires an additional property 'chainHistoryProvider'
- initializeTx now takes the list of redeemerByType and the script versions of the plutus scripts in the transaction

### Features

* tx-builder now supports spending from plutus scripts ([936351e](https://github.com/input-output-hk/cardano-js-sdk/commit/936351e22bea0b673e683333c84cbf9d0e134e19))

### Bug Fixes

* **tx-construction:** tx-builder now computes redeemer indices correctly everytime ([08f0ee0](https://github.com/input-output-hk/cardano-js-sdk/commit/08f0ee0084d1a50d98961b0fb281f27bd0e3ceb7))

## [0.18.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.18.6...@cardano-sdk/tx-construction@0.18.7) (2024-05-20)

### Bug Fixes

* **tx-construction:** fix an issue where the tx-builder was always using greedy input selector for multi delegation wallets ([1995288](https://github.com/input-output-hk/cardano-js-sdk/commit/199528890b574eb8c9bd47bd90af35641d61715b))

## [0.18.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.18.5...@cardano-sdk/tx-construction@0.18.6) (2024-05-02)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.18.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.18.4...@cardano-sdk/tx-construction@0.18.5) (2024-04-26)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.18.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.18.3...@cardano-sdk/tx-construction@0.18.4) (2024-04-23)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.18.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.18.2...@cardano-sdk/tx-construction@0.18.3) (2024-04-15)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.18.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.18.1...@cardano-sdk/tx-construction@0.18.2) (2024-04-03)

### Features

* **tx-construction:** add setValidityInterval to txBuilder ([52102b0](https://github.com/input-output-hk/cardano-js-sdk/commit/52102b0dc3053832b99846dbbd5d87bdd19dd57f))

## [0.18.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.18.0...@cardano-sdk/tx-construction@0.18.1) (2024-03-26)

### Features

* added computeScriptDataHash function ([ae2bbea](https://github.com/input-output-hk/cardano-js-sdk/commit/ae2bbea42a0c2583486f065f39868eb598ed2516))

## [0.18.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.17.13...@cardano-sdk/tx-construction@0.18.0) (2024-03-12)

### ⚠ BREAKING CHANGES

* finalizeTx was added to the Witnesser interface
- the PersonalWallet was renamed BaseWallet
- all code specific to Bip32 wallet have been abstracted out of the BaseWallet
- the PersonalWallet must now be constructed with the createPersonalWallet util function
- the SignedTx type was renamed to WitnessedTx
- the UnsignedTx type was renamed to UnwitnessedTx
- the Witness method from the Witnesser interface now returns a WitnessedTx
- extraSigners was moved from the witness field to the signingOptions in both the wallet FinalizeTxProps and witness signingOptions
- wallet repository script wallets ownSigners type now includes paymentScriptKeyPath and stakingScriptKeyPath
- wallet repository script wallets script field replaced by paymentScript and stakingScript
- stubSignTransaction util function now takes and optional dRepPublicKey as part of the context
* rename RewardAccountInfo keyStatus field to credentialStatus
* bip32Account is now an optional TxBuilder dependency

### Features

* add proposal procedures deposit to compute implicit coins ([21e1863](https://github.com/input-output-hk/cardano-js-sdk/commit/21e18638bee85f1c8f3e43246efa289f63d77662))
* added SharedWallet implementation ([272f392](https://github.com/input-output-hk/cardano-js-sdk/commit/272f3923ac872337cdf1f8647ac07c6a7a78384a))
* finalizeTxDependencies no longer requires a bip32Account, but should provide a dRepPublicKey if available ([eaf01dd](https://github.com/input-output-hk/cardano-js-sdk/commit/eaf01dd4135a37c77295e4c587f9897e9eb50890))

### Code Refactoring

* stakeKeyStatus renamed StakeCredentialStatus ([cf76584](https://github.com/input-output-hk/cardano-js-sdk/commit/cf76584c3531c72c659de13df06a9f4342101f46))

## [0.17.13](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.17.12...@cardano-sdk/tx-construction@0.17.13) (2024-02-29)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.17.12](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.17.11...@cardano-sdk/tx-construction@0.17.12) (2024-02-28)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.17.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.17.10...@cardano-sdk/tx-construction@0.17.11) (2024-02-23)

### Features

* **tx-construction:** add customizeCb to GenericTxBuilder ([87732b6](https://github.com/input-output-hk/cardano-js-sdk/commit/87732b60ec38c9528dde6310bbb608589896870f))

## [0.17.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.17.9...@cardano-sdk/tx-construction@0.17.10) (2024-02-12)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.17.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.17.8...@cardano-sdk/tx-construction@0.17.9) (2024-02-08)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.17.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.17.7...@cardano-sdk/tx-construction@0.17.8) (2024-02-07)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.17.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.17.6...@cardano-sdk/tx-construction@0.17.7) (2024-02-02)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.17.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.17.5...@cardano-sdk/tx-construction@0.17.6) (2024-02-02)

### Features

* use new deposit field when building dereg cert ([659f4f0](https://github.com/input-output-hk/cardano-js-sdk/commit/659f4f053ab0ddc9ae9e713e4367dd427008b10c))

## [0.17.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.17.4...@cardano-sdk/tx-construction@0.17.5) (2024-01-31)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.17.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.17.3...@cardano-sdk/tx-construction@0.17.4) (2024-01-25)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.17.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.17.2...@cardano-sdk/tx-construction@0.17.3) (2024-01-17)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.17.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.17.1...@cardano-sdk/tx-construction@0.17.2) (2024-01-05)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.17.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.17.0...@cardano-sdk/tx-construction@0.17.1) (2023-12-21)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.17.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.16.2...@cardano-sdk/tx-construction@0.17.0) (2023-12-20)

### ⚠ BREAKING CHANGES

* Witnesser witness method now takes a complete serializable Transaction

### Features

* witnesser witness method now takes a complete serializable Transaction ([07a7305](https://github.com/input-output-hk/cardano-js-sdk/commit/07a730536ef9b0cd5a4760e143e35bdca4ce8d8d))

## [0.16.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.16.1...@cardano-sdk/tx-construction@0.16.2) (2023-12-14)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.16.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.16.0...@cardano-sdk/tx-construction@0.16.1) (2023-12-12)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.16.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.15.1...@cardano-sdk/tx-construction@0.16.0) (2023-12-07)

### ⚠ BREAKING CHANGES

* remove KeyAgent.knownAddresses
- remove AsyncKeyAgent.knownAddresses$
- remove LazyWalletUtil and setupWallet utils
- replace KeyAgent dependency on InputResolver with props passed to sign method
- re-purpose AddressManager to Bip32Account: addresses are now stored only by the wallet

### Code Refactoring

* remove indirect KeyAgent dependency on ObservableWallet ([8dcfbc4](https://github.com/input-output-hk/cardano-js-sdk/commit/8dcfbc4ab339fcd8efc7d5f241a501eb210b58d4))

## [0.15.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.15.0...@cardano-sdk/tx-construction@0.15.1) (2023-12-04)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.15.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.14.2...@cardano-sdk/tx-construction@0.15.0) (2023-11-29)

### ⚠ BREAKING CHANGES

* personal wallet now takes a Bip32 address manager and a witnesser instead of key agent
* stake registration and deregistration certificates now take a Credential instead of key hash

### Features

* personal wallet now takes a Bip32 address manager and a witnesser instead of key agent ([8308bf1](https://github.com/input-output-hk/cardano-js-sdk/commit/8308bf1876fd5a0bee215ea598a87ef08bd2f15f))
* stake registration and deregistration certificates now take a Credential instead of key hash ([49612f0](https://github.com/input-output-hk/cardano-js-sdk/commit/49612f0f313f357e7e2a7eed406852cbd2bb3dec))

### Bug Fixes

* **tx-construction:** txBuilder now properly redistributes all outputs to first address after de-registration of all stake keys ([a8b8ea7](https://github.com/input-output-hk/cardano-js-sdk/commit/a8b8ea7b54bbba65d8a0750a9c411468018c8725))

## [0.14.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.14.1...@cardano-sdk/tx-construction@0.14.2) (2023-10-19)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.14.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.14.0...@cardano-sdk/tx-construction@0.14.1) (2023-10-12)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.14.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.13.0...@cardano-sdk/tx-construction@0.14.0) (2023-10-09)

### ⚠ BREAKING CHANGES

* core package no longer exports the CML types

### Features

* core package no longer exports the CML types ([51545ed](https://github.com/input-output-hk/cardano-js-sdk/commit/51545ed82b4abeb795b0a50ad7d299ddb5da4a0d))

## [0.13.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.12.0...@cardano-sdk/tx-construction@0.13.0) (2023-09-29)

### ⚠ BREAKING CHANGES

* - key-management `stubSignTransaction` positional args were replaced by named args,
as defined in `StubSignTransactionProps`.
A new `dRepPublicKey` named arg is part of `StubSignTransactionProps`

### Features

* update for Conway transaction fields ([c32513b](https://github.com/input-output-hk/cardano-js-sdk/commit/c32513bb89d0318dba35227c3509204166a209b2))

## [0.12.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.11.3...@cardano-sdk/tx-construction@0.12.0) (2023-09-20)

### ⚠ BREAKING CHANGES

* delegation distribution portfolio is now persisted on chain and taken into account during change distribution
* remove the CML serialization code from core package
* renamed field handle to handleResolutions
* incompatible with previous revisions of cardano-services
- rename utxo and transactions PouchDB stores
- update type of Tx.witness.redeemers
- update type of Tx.witness.datums
- update type of TxOut.datum
- remove Cardano.Datum type

fix(cardano-services): correct chain history openApi endpoints path url to match version

### Features

* added witness set serialization classes ([132599d](https://github.com/input-output-hk/cardano-js-sdk/commit/132599d104be1e601d5849b716cc503af80a9fbb))
* delegation distribution portfolio is now persisted on chain and taken into account during change distribution ([7573938](https://github.com/input-output-hk/cardano-js-sdk/commit/75739385ea422a0621ded87f2b72c5878e3fcf81))
* remove the CML serialization code from core package ([62f4252](https://github.com/input-output-hk/cardano-js-sdk/commit/62f4252b094938db05b81c928c03c1eecec2be55))
* update core types with deserialized PlutusData ([d8cc93b](https://github.com/input-output-hk/cardano-js-sdk/commit/d8cc93b520177c98224502aad39109a0cb524f3c))

### Code Refactoring

* renamed field handle to handleResolutions ([8b3296e](https://github.com/input-output-hk/cardano-js-sdk/commit/8b3296e19b27815f3a8487479a691483696cc898))

## [0.11.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.11.2...@cardano-sdk/tx-construction@0.11.3) (2023-09-12)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.11.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.11.1...@cardano-sdk/tx-construction@0.11.2) (2023-08-29)

### Features

* **tx-construction:** negative or zero asset qty validation ([0440f4f](https://github.com/input-output-hk/cardano-js-sdk/commit/0440f4ffd0db4a6800c4da9959efc9bff1e536c2))

### Bug Fixes

* **tx-construction:** unneeded greedy input selection ([95e9d16](https://github.com/input-output-hk/cardano-js-sdk/commit/95e9d16be125e20c07238c3eb778c09e6795a702))

## [0.11.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.11.0...@cardano-sdk/tx-construction@0.11.1) (2023-08-21)

**Note:** Version bump only for package @cardano-sdk/tx-construction

## [0.11.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/tx-construction@0.10.0...@cardano-sdk/tx-construction@0.11.0) (2023-08-15)

### ⚠ BREAKING CHANGES

* add HandleProvider.getPolicyIds and utilize it in PersonalWallet also, handles$ resolvedAt is now only set via hydration (provider)

### Features

* add HandleProvider.getPolicyIds and utilize it in PersonalWallet also, handles$ resolvedAt is now only set via hydration (provider) ([af6a8d0](https://github.com/input-output-hk/cardano-js-sdk/commit/af6a8d011bbd2c218aa23e1d75bb25294fc61a27))

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
