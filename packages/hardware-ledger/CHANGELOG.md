# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## [0.12.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.12.10...@cardano-sdk/hardware-ledger@0.12.11) (2024-11-18)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.12.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.12.9...@cardano-sdk/hardware-ledger@0.12.10) (2024-10-25)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.12.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.12.8...@cardano-sdk/hardware-ledger@0.12.9) (2024-10-11)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.12.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.12.7...@cardano-sdk/hardware-ledger@0.12.8) (2024-10-07)

### Features

* **hardware-ledger:** the Ledger key agent now picks the first avaialble device if possible ([b993dc6](https://github.com/input-output-hk/cardano-js-sdk/commit/b993dc62eb1ae559b1840b5bb7346aee203fce0d))

## [0.12.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.12.6...@cardano-sdk/hardware-ledger@0.12.7) (2024-10-06)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.12.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.12.5...@cardano-sdk/hardware-ledger@0.12.6) (2024-10-03)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.12.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.12.4...@cardano-sdk/hardware-ledger@0.12.5) (2024-09-27)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.12.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.12.3...@cardano-sdk/hardware-ledger@0.12.4) (2024-09-25)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.12.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.12.2...@cardano-sdk/hardware-ledger@0.12.3) (2024-09-12)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.12.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.12.1...@cardano-sdk/hardware-ledger@0.12.2) (2024-09-10)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.12.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.12.0...@cardano-sdk/hardware-ledger@0.12.1) (2024-09-06)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.12.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.11.5...@cardano-sdk/hardware-ledger@0.12.0) (2024-09-04)

### ⚠ BREAKING CHANGES

* keyAgent signTransaction now takes Serialization.TransactionBody instead of Core.TxBodyWithHash

### Bug Fixes

* **hardware-ledger:** ledgerKeyAgent now conditionally instructs hw to use tagged CBOR sets ([644c32c](https://github.com/input-output-hk/cardano-js-sdk/commit/644c32c730bc74e3c60e70cab376b308b6ee468f))

### Code Refactoring

* keyAgent signTransaction now takes Serialization.TransactionBody ([a0fa7c7](https://github.com/input-output-hk/cardano-js-sdk/commit/a0fa7c71512104384755061010e9f8a31da0d415))

## [0.11.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.11.4...@cardano-sdk/hardware-ledger@0.11.5) (2024-08-23)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.11.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.11.3...@cardano-sdk/hardware-ledger@0.11.4) (2024-08-22)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.11.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.11.2...@cardano-sdk/hardware-ledger@0.11.3) (2024-08-21)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.11.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.11.1...@cardano-sdk/hardware-ledger@0.11.2) (2024-08-20)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.11.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.11.0...@cardano-sdk/hardware-ledger@0.11.1) (2024-08-07)

### Bug Fixes

* **hardware-ledger:** delegate vote drep is a hash not key path ([938b36a](https://github.com/input-output-hk/cardano-js-sdk/commit/938b36a5d3825f8e7ffbfbdf61a80316dec0cc7a))

## [0.11.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.10.2...@cardano-sdk/hardware-ledger@0.11.0) (2024-08-01)

### ⚠ BREAKING CHANGES

* replace signBlob with signCip8Data in witnesser interface
- keyAgents are now required to implement the signCip8Data function
- cip08 message construction hoisted from baseWallet to inMemoryKeyAgent signCip8Data function

### Features

* implement signCip8Data for LedgerKeyAgent and InMemoryKeyAgent ([a04cb75](https://github.com/input-output-hk/cardano-js-sdk/commit/a04cb753e4276a710f3336892e92c8f1bc7cee82))

## [0.10.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.10.1...@cardano-sdk/hardware-ledger@0.10.2) (2024-07-31)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.10.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.10.0...@cardano-sdk/hardware-ledger@0.10.1) (2024-07-25)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.10.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.9.13...@cardano-sdk/hardware-ledger@0.10.0) (2024-07-22)

### ⚠ BREAKING CHANGES

* **hardware-ledger:** mapVotingProcedures, toVotingProcedure and
toVoter all require passing the LedgerTxTransformerContext as
a parameter
* **hardware-ledger:** SignTransactionContext.dRepPublicKey was
changed to dRepKeyHashHex of type Crypto.Ed25519KeyHashHex

### Bug Fixes

* **hardware-ledger:** sign voting procedure with drep keypath ([efa7c9c](https://github.com/input-output-hk/cardano-js-sdk/commit/efa7c9cfbf34f04464d1d37ee0a5b356991ef9d8))

### Code Refactoring

* **hardware-ledger:** async not needed for certificate mapping ([77d29d7](https://github.com/input-output-hk/cardano-js-sdk/commit/77d29d701f19287720e4655c3464c39ea1009c71))

## [0.9.13](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.9.12...@cardano-sdk/hardware-ledger@0.9.13) (2024-07-11)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.9.12](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.9.11...@cardano-sdk/hardware-ledger@0.9.12) (2024-07-10)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.9.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.9.10...@cardano-sdk/hardware-ledger@0.9.11) (2024-06-26)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.9.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.9.9...@cardano-sdk/hardware-ledger@0.9.10) (2024-06-20)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.9.9](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.9.8...@cardano-sdk/hardware-ledger@0.9.9) (2024-06-18)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.9.8](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.9.7...@cardano-sdk/hardware-ledger@0.9.8) (2024-06-17)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.9.7](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.9.6...@cardano-sdk/hardware-ledger@0.9.7) (2024-06-14)

### Features

* key agents now can take optional coin purpose ([e6861d7](https://github.com/input-output-hk/cardano-js-sdk/commit/e6861d7008addb7cc736a44e7823ce062c7131d6))

## [0.9.6](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.9.5...@cardano-sdk/hardware-ledger@0.9.6) (2024-06-05)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.9.5](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.9.4...@cardano-sdk/hardware-ledger@0.9.5) (2024-05-20)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.9.4](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.9.3...@cardano-sdk/hardware-ledger@0.9.4) (2024-05-02)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.9.3](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.9.2...@cardano-sdk/hardware-ledger@0.9.3) (2024-04-26)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.9.2](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.9.1...@cardano-sdk/hardware-ledger@0.9.2) (2024-04-23)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.9.1](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.9.0...@cardano-sdk/hardware-ledger@0.9.1) (2024-04-15)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.9.0](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.19...@cardano-sdk/hardware-ledger@0.9.0) (2024-04-04)

### ⚠ BREAKING CHANGES

* **hardware-ledger:** replace LedgerKeyAgent webhid transport with webusb
- make some of the LedgerKeyAgent methods private
- remove activeTransport parameter from the LedgerKeyAgent.createTransport method

### Features

* **hardware-ledger:** enable LedgerKeyAgent to accept a device to establish connection with ([f084f42](https://github.com/input-output-hk/cardano-js-sdk/commit/f084f4203240a25f9680d200e13dc27a47c1f439))

## [0.8.19](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.18...@cardano-sdk/hardware-ledger@0.8.19) (2024-04-03)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.18](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.17...@cardano-sdk/hardware-ledger@0.8.18) (2024-03-26)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.17](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.16...@cardano-sdk/hardware-ledger@0.8.17) (2024-03-12)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.16](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.15...@cardano-sdk/hardware-ledger@0.8.16) (2024-02-29)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.15](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.14...@cardano-sdk/hardware-ledger@0.8.15) (2024-02-28)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.14](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.13...@cardano-sdk/hardware-ledger@0.8.14) (2024-02-23)

### Bug Fixes

* **hardware-ledger:** correctly map error when device is already open ([7f6151d](https://github.com/input-output-hk/cardano-js-sdk/commit/7f6151d60fe9980bf65a321f7d92382cc3bb50e3))

## [0.8.13](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.12...@cardano-sdk/hardware-ledger@0.8.13) (2024-02-12)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.12](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.11...@cardano-sdk/hardware-ledger@0.8.12) (2024-02-08)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.11](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.10...@cardano-sdk/hardware-ledger@0.8.11) (2024-02-07)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

## [0.8.10](https://github.com/input-output-hk/cardano-js-sdk/compare/@cardano-sdk/hardware-ledger@0.8.9...@cardano-sdk/hardware-ledger@0.8.10) (2024-02-02)

**Note:** Version bump only for package @cardano-sdk/hardware-ledger

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
