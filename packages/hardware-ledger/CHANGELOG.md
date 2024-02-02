# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.8.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.8...@cardano-sdk/hardware-ledger@0.8.9) (2024-02-02)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.7...@cardano-sdk/hardware-ledger@0.8.8) (2024-01-31)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.6...@cardano-sdk/hardware-ledger@0.8.7) (2024-01-25)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.5...@cardano-sdk/hardware-ledger@0.8.6) (2024-01-17)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.4...@cardano-sdk/hardware-ledger@0.8.5) (2024-01-05)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.3...@cardano-sdk/hardware-ledger@0.8.4) (2023-12-21)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.2...@cardano-sdk/hardware-ledger@0.8.3) (2023-12-20)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.1...@cardano-sdk/hardware-ledger@0.8.2) (2023-12-14)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.0...@cardano-sdk/hardware-ledger@0.8.1) (2023-12-12)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.7.1...@cardano-sdk/hardware-ledger@0.8.0) (2023-12-07)

### ⚠ BREAKING CHANGES

* remove KeyAgent.knownAddresses
- remove AsyncKeyAgent.knownAddresses$
- remove LazyWalletUtil and setupWallet utils
- replace KeyAgent dependency on InputResolver with props passed to sign method
- re-purpose AddressManager to Bip32Account: addresses are now stored only by the wallet

### Code Refactoring

* remove indirect KeyAgent dependency on ObservableWallet ([8dcfbc4](https://github.com/input-output-hk/cardano-js-sdk/commit/8dcfbc4ab339fcd8efc7d5f241a501eb210b58d4))

## [0.7.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.7.0...@cardano-sdk/hardware-ledger@0.7.1) (2023-12-04)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.7.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.6.1...@cardano-sdk/hardware-ledger@0.7.0) (2023-11-29)

### ⚠ BREAKING CHANGES

* stake registration and deregistration certificates now take a Credential instead of key hash

### Features

* stake registration and deregistration certificates now take a Credential instead of key hash ([49612f0](https://github.com/input-output-hk/cardano-js-sdk/commit/49612f0f313f357e7e2a7eed406852cbd2bb3dec))

## [0.6.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.6.0...@cardano-sdk/hardware-ledger@0.6.1) (2023-10-19)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.6.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.5.0...@cardano-sdk/hardware-ledger@0.6.0) (2023-10-12)

### ⚠ BREAKING CHANGES

* the TrezorKeyAgent class was moved from `key-management` to `hardware-trezor` package

### Features

* add dedicated Trezor package ([2a1b075](https://github.com/input-output-hk/cardano-js-sdk/commit/2a1b0754adfd29f1ef2f820b59f91f950cddb4d9))

## [0.5.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.4.1...@cardano-sdk/hardware-ledger@0.5.0) (2023-10-09)

### ⚠ BREAKING CHANGES

* core package no longer exports the CML types

### Features

* core package no longer exports the CML types ([51545ed](https://github.com/input-output-hk/cardano-js-sdk/commit/51545ed82b4abeb795b0a50ad7d299ddb5da4a0d))

## [0.4.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.4.0...@cardano-sdk/hardware-ledger@0.4.1) (2023-09-29)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.4.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.3.4...@cardano-sdk/hardware-ledger@0.4.0) (2023-09-20)

### ⚠ BREAKING CHANGES

* remove the CML serialization code from core package
* incompatible with previous revisions of cardano-services
- rename utxo and transactions PouchDB stores
- update type of Tx.witness.redeemers
- update type of Tx.witness.datums
- update type of TxOut.datum
- remove Cardano.Datum type

fix(cardano-services): correct chain history openApi endpoints path url to match version

### Features

* remove the CML serialization code from core package ([62f4252](https://github.com/input-output-hk/cardano-js-sdk/commit/62f4252b094938db05b81c928c03c1eecec2be55))
* update core types with deserialized PlutusData ([d8cc93b](https://github.com/input-output-hk/cardano-js-sdk/commit/d8cc93b520177c98224502aad39109a0cb524f3c))

## [0.3.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.3.3...@cardano-sdk/hardware-ledger@0.3.4) (2023-09-12)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.3.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.3.2...@cardano-sdk/hardware-ledger@0.3.3) (2023-08-29)

### Features

* **hardware-ledger:** return existing connection if available ([40527d3](https://github.com/input-output-hk/cardano-js-sdk/commit/40527d3b4da3f3c6ae6ad44963dce3048ecd5c0d))

### Bug Fixes

* **hardware-ledger:** workaround lace build issue ([ef5011a](https://github.com/input-output-hk/cardano-js-sdk/commit/ef5011adf7472cfceda2f861407c5bdac11ff76e))

## [0.3.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.3.1...@cardano-sdk/hardware-ledger@0.3.2) (2023-08-21)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.3.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.3.0...@cardano-sdk/hardware-ledger@0.3.1) (2023-08-15)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.3.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.17...@cardano-sdk/hardware-ledger@0.3.0) (2023-08-11)

### ⚠ BREAKING CHANGES

* rename AddressEntity.stakingCredentialHash -> stakeCredentialHash
- rename BaseAddress.getStakingCredential -> getStakeCredential
* the serialization classes in Core package are now exported under the alias Serialization

### Code Refactoring

* rename/replace occurences of 'staking' with 'stake' where appropriate ([05fc4c4](https://github.com/input-output-hk/cardano-js-sdk/commit/05fc4c4d83137eb3137583ca0bb443825eac1445))
* the serialization classes in Core package are now exported under the alias Serialization ([06f78bb](https://github.com/input-output-hk/cardano-js-sdk/commit/06f78bb98943c306572c32f5817425ef1ff6fc51))

## [0.2.17](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.16...@cardano-sdk/hardware-ledger@0.2.17) (2023-07-31)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.2.16](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.15...@cardano-sdk/hardware-ledger@0.2.16) (2023-07-26)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.2.15](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.14...@cardano-sdk/hardware-ledger@0.2.15) (2023-07-13)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.2.14](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.13...@cardano-sdk/hardware-ledger@0.2.14) (2023-07-05)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.2.13](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.12...@cardano-sdk/hardware-ledger@0.2.13) (2023-07-04)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.2.12](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.11...@cardano-sdk/hardware-ledger@0.2.12) (2023-07-03)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.2.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.10...@cardano-sdk/hardware-ledger@0.2.11) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.2.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.9...@cardano-sdk/hardware-ledger@0.2.10) (2023-06-29)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.2.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.8...@cardano-sdk/hardware-ledger@0.2.9) (2023-06-28)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.2.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.7...@cardano-sdk/hardware-ledger@0.2.8) (2023-06-23)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.2.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.6...@cardano-sdk/hardware-ledger@0.2.7) (2023-06-20)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.2.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.5...@cardano-sdk/hardware-ledger@0.2.6) (2023-06-13)

### Bug Fixes

* correct ledger mapping canonical asset and asset group ordering ([2095877](https://github.com/input-output-hk/cardano-js-sdk/commit/20958773d2885ee3e1934363dce96b4e8cea96a7))

## [0.2.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.4...@cardano-sdk/hardware-ledger@0.2.5) (2023-06-12)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.2.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.3...@cardano-sdk/hardware-ledger@0.2.4) (2023-06-06)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.2.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.2...@cardano-sdk/hardware-ledger@0.2.3) (2023-06-05)

### Bug Fixes

* **hardware-ledger:** stake key hashes in the requiredSigners field are now mapped correctly ([8e857ec](https://github.com/input-output-hk/cardano-js-sdk/commit/8e857ec022c03cd86e6c247d8333b68765fb0f2e))

## [0.2.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.1...@cardano-sdk/hardware-ledger@0.2.2) (2023-06-01)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.2.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.2.0...@cardano-sdk/hardware-ledger@0.2.1) (2023-05-24)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## 0.2.0 (2023-05-22)

### ⚠ BREAKING CHANGES

* add ledger package with transformations

### Features

* add ledger package with transformations ([58f3a22](https://github.com/input-output-hk/cardano-js-sdk/commit/58f3a227d466c0083bcfe9243311ac2bca4e48df))
